import 'dart:async';
import 'package:enough_mail/enough_mail.dart';
import 'logger_service.dart';
import 'storage_service.dart';

class EmailService {
  final String email;
  final String password;
  final String imapServer;
  final int imapPort;
  final String smtpServer;
  final int smtpPort;
  final bool smtpUseTls; // Использовать TLS сразу (465) или STARTTLS (587)

  ImapClient? _imapClient;
  bool _isIdleRunning = false;
  bool _isFetching = false;
  int _lastKnownExists = 0;
  int _lastUidNext = 0; // Как в Delta Chat - отслеживаем UIDNEXT
  int _uidValidity = 0; // Для проверки что ящик не пересоздан
  
  // Callback для уведомления о новых сообщениях (вызывается из IDLE)
  final List<Function()> _callbacks = []; // Список всех callback'ов
  bool _callbackPending = false; // Флаг что callback уже вызван, ждём завершения fetch
  
  // Обработчик сообщений (устанавливается извне)
  Future<void> Function()? _messageProcessor;

  EmailService({
    required this.email,
    required this.password,
    this.imapServer = 'imap.mail.ru',
    this.imapPort = 993,
    this.smtpServer = 'smtp.mail.ru',
    this.smtpPort = 465, // Используем 465 (TLS) вместо 587 (STARTTLS)
    this.smtpUseTls = true, // TLS сразу, без STARTTLS 
  });
  
  // Подключение к IMAP
  Future<void> connectImap() async {
    try {
      _imapClient = ImapClient(isLogEnabled: false);
      await _imapClient!.connectToServer(imapServer, imapPort, isSecure: true);
      await _imapClient!.login(email, password);
      final mailbox = await _imapClient!.selectInbox();
      
      _lastKnownExists = mailbox.messagesExists;
      // НЕ устанавливаем _lastUidNext здесь! Он должен браться из БД через lastSeenUid
      // _lastUidNext будет обновлён в fetchNewMessages() после успешного fetch
      _uidValidity = mailbox.uidValidity ?? 0;
      
      LoggerService.log('IMAP: Connected, EXISTS=$_lastKnownExists, UIDNEXT=${mailbox.uidNext}, UIDVALIDITY=$_uidValidity');
      
      // Запускаем IDLE только если ещё не запущен
      if (!_isIdleRunning) {
        LoggerService.log('IMAP: Starting IDLE loop');
        _startIdleLoop();
      } else {
        LoggerService.log('IMAP: IDLE already running, skipping start');
      }
      
      // Запускаем фоновый fetch loop (как Delta Chat) - backup каждые 5 минут
      _startBackgroundFetchLoop();
    } catch (e) {
      _imapClient = null;
      rethrow;
    }
  }

  // Устанавливаем callback для уведомлений о новых сообщениях
  void setNewMessageCallback(Function() callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
      LoggerService.log('EmailService: Callback registered (total: ${_callbacks.length})');
    }
  }
  
  // Устанавливаем обработчик сообщений (вызывается ДО уведомления экранов)
  void setMessageProcessor(Future<void> Function() processor) {
    _messageProcessor = processor;
    LoggerService.log('EmailService: Message processor registered');
  }
  
  // Удаляем callback
  void removeNewMessageCallback(Function() callback) {
    _callbacks.remove(callback);
    LoggerService.log('EmailService: Callback removed (total: ${_callbacks.length})');
  }

  // Уведомляем callbacks БЕЗ fetch (для read receipts и т.д.)
  void notifyCallbacks() {
    LoggerService.log('EmailService: Notifying ${_callbacks.length} callbacks (no fetch)');
    for (int i = 0; i < _callbacks.length; i++) {
      try {
        _callbacks[i]();
      } catch (e) {
        LoggerService.log('EmailService: Callback #${i + 1} error: $e');
      }
    }
  }

  // Фоновый fetch loop (как Delta Chat) - работает независимо от UI
  // Это BACKUP на случай если IDLE не сработал
  void _startBackgroundFetchLoop() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_imapClient == null || _isFetching) return;
      
      try {
        LoggerService.log('Background fetch: Periodic check (backup)...');
        
        // Вызываем обработчик сообщений (он сам fetch'ит и уведомляет UI)
        if (_messageProcessor != null) {
          await _messageProcessor!();
        }
      } catch (e) {
        LoggerService.log('Background fetch error: $e');
      }
    });
  }

  void _startIdleLoop() async {
    if (_isIdleRunning) {
      LoggerService.log('IDLE: Already running, skipping');
      return;
    }
    _isIdleRunning = true;
    LoggerService.log('IDLE: Loop started');

    while (_isIdleRunning) {
      try {
        if (_imapClient == null) {
          LoggerService.log('IDLE: IMAP client is null, reconnecting in 10 seconds...');
          await Future.delayed(const Duration(seconds: 10));
          
          try {
            await connectImap();
            LoggerService.log('IDLE: Reconnected successfully');
          } catch (e) {
            LoggerService.log('IDLE: Reconnect failed: $e, will retry...');
            continue; // Попробуем снова в следующей итерации
          }
        }

        if (!_imapClient!.serverInfo.supportsIdle) {
          LoggerService.log('ERROR: Server does not support IDLE');
          await Future.delayed(const Duration(seconds: 30));
          continue;
        }

        LoggerService.log('IDLE: Starting (EXISTS=$_lastKnownExists)');
        
        // Слушаем события
        StreamSubscription<ImapEvent>? subscription;
        final completer = Completer<void>();
        int newExists = _lastKnownExists;
        bool hadEvent = false;
        
        subscription = _imapClient!.eventBus!.on<ImapEvent>().listen((event) {
          if (event is ImapMessagesExistEvent) {
            newExists = event.newMessagesExists;
            
            // Уведомляем только если УВЕЛИЧИЛОСЬ
            if (newExists > _lastKnownExists) {
              final now = DateTime.now();
              LoggerService.log('IDLE: New message! $_lastKnownExists -> $newExists at ${now.hour}:${now.minute}:${now.second}.${now.millisecond}');
              hadEvent = true;
              if (!completer.isCompleted) {
                completer.complete();
              }
            }
          }
        });
        
        // Запускаем IDLE
        await _imapClient!.idleStart();
        LoggerService.log('IDLE: Active');
        
        // Ждём 29 минут или события (как Delta Chat - RFC рекомендует до 30 мин)
        await Future.any([
          completer.future,
          Future.delayed(const Duration(minutes: 29)),
        ]);
        
        await subscription.cancel();
        
        // Останавливаем IDLE
        try {
          final stopwatch = Stopwatch()..start();
          await _imapClient!.idleDone();
          // NOOP для проверки соединения (как Delta Chat)
          await _imapClient!.noop();
          stopwatch.stop();
          LoggerService.log('IDLE: Done + NOOP ok (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          LoggerService.log('IDLE: Done/NOOP error: $e');
          _imapClient = null;
          continue;
        }
        
        // Обновляем EXISTS
        if (newExists > _lastKnownExists) {
          _lastKnownExists = newExists;
        }
        
        // КАК DELTA CHAT: Всегда уведомляем после IDLE
        LoggerService.log('IDLE: Notifying (had event: $hadEvent, EXISTS: $_lastKnownExists, pending: $_callbackPending)');
        
        // Уведомляем через callback ТОЛЬКО если не ждём предыдущий
        if (!_callbackPending) {
          _callbackPending = true; // Блокируем повторные вызовы
          
          try {
            // ВАЖНО: Вызываем обработчик сообщений
            // Он сам обработает сообщения И уведомит UI
            LoggerService.log('IDLE: Processing new messages...');
            if (_messageProcessor != null) {
              await _messageProcessor!();
              LoggerService.log('IDLE: Messages processed and UI notified!');
            }
          } catch (e) {
            LoggerService.log('IDLE: Processing error: $e');
          } finally {
            _callbackPending = false;
          }
        } else {
          LoggerService.log('IDLE: Callback already pending, skipping');
        }
        
        // Сразу перезапускаем IDLE (как Delta Chat - не ждём)
        await Future.delayed(const Duration(milliseconds: 50));
        
      } catch (e) {
        LoggerService.log('IDLE error: $e');
        _imapClient = null;
        await Future.delayed(const Duration(seconds: 5));
      }
    }
    
    LoggerService.log('IDLE: Loop ended');
  }

  // Получение текущего UIDNEXT без fetch (для первого запуска)
  Future<int> getCurrentUidNext() async {
    try {
      if (_imapClient == null) {
        await connectImap();
      }
      
      final mailbox = await _imapClient!.selectInbox();
      return mailbox.uidNext ?? 0;
    } catch (e) {
      LoggerService.log('getCurrentUidNext error: $e');
      return 0;
    }
  }

  // Получение новых сообщений (как Delta Chat - используем UIDNEXT)
  Future<List<MimeMessage>> fetchNewMessages({int lastSeenUid = 0}) async {
    if (_isFetching) {
      LoggerService.log('EmailService: Already fetching, returning empty');
      return [];
    }
    
    _isFetching = true;
    final fetchStopwatch = Stopwatch()..start();
    
    try {
      if (_imapClient == null) {
        LoggerService.log('IMAP not connected, reconnecting...');
        await connectImap();
      }

      // Проверяем UIDVALIDITY - если изменился, ящик пересоздан
      final mailbox = await _imapClient!.selectInbox();
      final currentUidValidity = mailbox.uidValidity ?? 0;
      
      if (_uidValidity != 0 && currentUidValidity != _uidValidity) {
        LoggerService.log('UIDVALIDITY changed! Mailbox was recreated. Resetting.');
        _uidValidity = currentUidValidity;
        // Нужно пересинхронизировать всё, но пока просто сбрасываем
        return [];
      }
      
      _uidValidity = currentUidValidity;
      final currentUidNext = mailbox.uidNext ?? 0;
      
      // ВАЖНО: Используем lastSeenUid из БД, а НЕ _lastUidNext!
      // _lastUidNext используется только для IDLE событий
      final startUid = lastSeenUid + 1;
      
      // Если нет новых сообщений (startUid > currentUidNext)
      if (startUid > currentUidNext) {
        LoggerService.log('No new messages (lastSeenUid=$lastSeenUid, startUid=$startUid, UIDNEXT=$currentUidNext)');
        return [];
      }
      
      LoggerService.log('New messages detected! lastSeenUid=$lastSeenUid, UIDNEXT=$currentUidNext');
      
      // Батчинг: fetch по 50 писем за раз (как Delta Chat, но проще)
      final totalNew = currentUidNext - startUid;
      final messages = <MimeMessage>[];
      
      LoggerService.log('fetch_new_msg_batch(INBOX): UIDVALIDITY=$_uidValidity, UIDNEXT=$currentUidNext');
      
      if (totalNew > 50) {
        LoggerService.log('Batching: $totalNew messages, fetching in batches of 50');
        
        // Fetch батчами
        for (int batchStart = startUid; batchStart < currentUidNext; batchStart += 50) {
          final batchEnd = (batchStart + 49 < currentUidNext) ? batchStart + 49 : currentUidNext - 1;
          
          LoggerService.log('Batch: UID $batchStart:$batchEnd');
          
          final sequence = MessageSequence.fromRange(batchStart, batchEnd);
          final fetchResult = await _imapClient!.uidFetchMessages(
            sequence,
            'BODY.PEEK[]',
          );
          
          messages.addAll(_filterChatMessages(fetchResult.messages, lastSeenUid));
          
          // Пауза между батчами
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } else {
        // Обычный fetch если писем мало
        final endUid = currentUidNext - 1;
        final uidFetchStopwatch = Stopwatch()..start();
        LoggerService.log('Starting UID FETCH of message set "$startUid:$endUid"');
        
        final sequence = MessageSequence.fromRange(startUid, endUid);
        final fetchResult = await _imapClient!.uidFetchMessages(
          sequence,
          'BODY.PEEK[]',
        );
        
        uidFetchStopwatch.stop();
        LoggerService.log('Successfully received ${fetchResult.messages.length} messages in ${uidFetchStopwatch.elapsedMilliseconds}ms.');
        messages.addAll(_filterChatMessages(fetchResult.messages, lastSeenUid));
      }
      
      // Обновляем _lastUidNext для IDLE (чтобы знать что уже обработали)
      _lastUidNext = currentUidNext;
      
      fetchStopwatch.stop();
      LoggerService.log('${messages.length} mails read from "INBOX" in ${fetchStopwatch.elapsedMilliseconds}ms.');
      LoggerService.log('Fetched ${messages.length} new chat messages');
      
      // Сбрасываем флаг pending - fetch завершён
      _callbackPending = false;
      
      return messages;
      
    } catch (e) {
      LoggerService.log('fetchNewMessages error: $e');
      _callbackPending = false; // Сбрасываем при ошибке
      if (e.toString().contains('Connection') || e.toString().contains('Socket')) {
        _imapClient = null;
        _isIdleRunning = false;
      }
      rethrow;
    } finally {
      _isFetching = false;
    }
  }

  // Helper: фильтрация chat сообщений
  List<MimeMessage> _filterChatMessages(List<MimeMessage> messages, int lastSeenUid) {
    final filtered = <MimeMessage>[];
    
    for (final msg in messages) {
      final uid = msg.uid ?? 0;
      final subject = msg.decodeSubject() ?? '';
      final from = msg.from?.first?.email ?? '';
      
      // Фильтруем только [chat] письма
      if (!subject.contains('[chat]')) {
        LoggerService.log('UID=$uid: Not a chat message, skipping');
        continue;
      }
      
      // Пропускаем уже обработанные
      if (uid <= lastSeenUid) {
        LoggerService.log('UID=$uid: Already processed');
        continue;
      }
      
      // ВАЖНО: Пропускаем BCC копии своих сообщений
      if (from == email) {
        LoggerService.log('UID=$uid: BCC copy from myself, skipping');
        continue;
      }
      
      LoggerService.log('UID=$uid: New chat message from $from');
      filtered.add(msg);
    }
    
    return filtered;
  }

  // Помечаем письмо как прочитанное
  Future<void> markMessageAsSeen(int uid) async {
    try {
      if (_imapClient == null) return;
      
      await _imapClient!.store(
        MessageSequence.fromId(uid),
        [r'\Seen'],
        action: StoreAction.add,
      );
      
      LoggerService.log('Marked message $uid in folder INBOX as seen.');
    } catch (e) {
      LoggerService.log('markMessageAsSeen error: $e');
    }
  }

  // Отправка сообщения (возвращает Message-ID для дедупликации)
  Future<String> sendMessage({
    required String toEmail,
    required String encryptedPayload,
    bool bccToSelf = true,
  }) async {
    final startTime = DateTime.now();
    LoggerService.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    LoggerService.log('SMTP: Starting send to $toEmail');
    LoggerService.log('SMTP: Payload size: ${encryptedPayload.length} bytes');
    
    SmtpClient? client;
    
    try {
      // 1. Создание клиента
      LoggerService.log('SMTP [1/9]: Creating SmtpClient instance');
      client = SmtpClient('enough_mail', isLogEnabled: false);
      LoggerService.log('SMTP [1/9]: ✓ Client created');
      
      // 2. Подключение
      LoggerService.log('SMTP [2/9]: Connecting to $smtpServer:$smtpPort (TLS: $smtpUseTls)');
      try {
        await client.connectToServer(smtpServer, smtpPort, isSecure: smtpUseTls);
        LoggerService.log('SMTP [2/9]: ✓ Connected');
      } catch (e) {
        LoggerService.log('SMTP [2/9]: ✗ Connection failed: $e');
        LoggerService.log('SMTP [2/9]: Error type: ${e.runtimeType}');
        rethrow;
      }
      
      // 3. EHLO
      LoggerService.log('SMTP [3/9]: Sending EHLO');
      try {
        await client.ehlo();
        LoggerService.log('SMTP [3/9]: ✓ EHLO accepted');
        LoggerService.log('SMTP [3/9]: Server capabilities: ${client.serverInfo.capabilities}');
      } catch (e) {
        LoggerService.log('SMTP [3/9]: ✗ EHLO failed: $e');
        rethrow;
      }
      
      // 4. STARTTLS (только если не используем TLS сразу)
      if (!smtpUseTls) {
        LoggerService.log('SMTP [4/9]: Starting TLS upgrade');
        try {
          await client.startTls();
          LoggerService.log('SMTP [4/9]: ✓ TLS established');
        } catch (e) {
          LoggerService.log('SMTP [4/9]: ✗ STARTTLS failed: $e');
          rethrow;
        }
      } else {
        LoggerService.log('SMTP [4/9]: Skipping STARTTLS (already using TLS)');
      }
      
      // 5. Аутентификация
      LoggerService.log('SMTP [5/9]: Authenticating as $email');
      try {
        if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
          LoggerService.log('SMTP [5/9]: Using AUTH PLAIN');
          await client.authenticate(email, password, AuthMechanism.plain);
        } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
          LoggerService.log('SMTP [5/9]: Using AUTH LOGIN');
          await client.authenticate(email, password, AuthMechanism.login);
        } else {
          LoggerService.log('SMTP [5/9]: ✗ No supported auth mechanism');
          throw Exception('No supported auth mechanism');
        }
        LoggerService.log('SMTP [5/9]: ✓ Authenticated');
      } catch (e) {
        LoggerService.log('SMTP [5/9]: ✗ Auth failed: $e');
        rethrow;
      }

      // 6. Генерация Message-ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = DateTime.now().microsecond;
      final messageId = '<$timestamp.$random@${email.split('@')[1]}>';
      LoggerService.log('SMTP [6/9]: Generated Message-ID: $messageId');
      
      // 7. Построение сообщения
      LoggerService.log('SMTP [7/9]: Building MIME message');
      try {
        final builder = MessageBuilder()
          ..from = [MailAddress('', email)]
          ..to = [MailAddress('', toEmail)]
          ..subject = '[chat]'
          ..text = encryptedPayload;
        
        if (bccToSelf) {
          builder.bcc = [MailAddress('', email)];
          LoggerService.log('SMTP [7/9]: BCC to self enabled');
        }
        
        builder.setHeader('Message-ID', messageId);
        final message = builder.buildMimeMessage();
        LoggerService.log('SMTP [7/9]: ✓ Message built (${message.toString().length} bytes)');
        
        // 8. Отправка
        LoggerService.log('SMTP [8/9]: Sending message via SMTP');
        try {
          await client.sendMessage(message);
          LoggerService.log('SMTP [8/9]: ✓ Message sent');
        } catch (e) {
          LoggerService.log('SMTP [8/9]: ✗ Send failed: $e');
          LoggerService.log('SMTP [8/9]: Error type: ${e.runtimeType}');
          LoggerService.log('SMTP [8/9]: Stack trace: ${StackTrace.current}');
          rethrow;
        }
        
        // 9. QUIT
        LoggerService.log('SMTP [9/9]: Sending QUIT');
        try {
          await client.quit();
          LoggerService.log('SMTP [9/9]: ✓ QUIT accepted');
        } catch (e) {
          LoggerService.log('SMTP [9/9]: ✗ QUIT failed (non-critical): $e');
          // Не бросаем ошибку - сообщение уже отправлено
        }
        
        final duration = DateTime.now().difference(startTime);
        LoggerService.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        LoggerService.log('SMTP: ✅ SUCCESS in ${duration.inMilliseconds}ms');
        LoggerService.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        return messageId;
        
      } catch (e) {
        LoggerService.log('SMTP [7/9]: ✗ Message build failed: $e');
        rethrow;
      }
      
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      LoggerService.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      LoggerService.log('SMTP: ❌ FAILED after ${duration.inMilliseconds}ms');
      LoggerService.log('SMTP: Error: $e');
      LoggerService.log('SMTP: Type: ${e.runtimeType}');
      LoggerService.log('SMTP: Stack: $stackTrace');
      LoggerService.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    } finally {
      // Всегда закрываем соединение
      if (client != null) {
        LoggerService.log('SMTP: Cleanup - disconnecting client');
        try {
          await client.disconnect();
          LoggerService.log('SMTP: Cleanup - ✓ disconnected');
        } catch (e) {
          LoggerService.log('SMTP: Cleanup - disconnect error: $e');
        }
      }
    }
  }

  // Закрытие соединений
  Future<void> disconnect() async {
    _isIdleRunning = false;
    await _imapClient?.logout();
  }
}
