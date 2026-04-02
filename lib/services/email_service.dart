import 'dart:async';
import 'package:enough_mail/enough_mail.dart';
import 'logger_service.dart';

class EmailService {
  final String email;
  final String password;
  final String imapServer;
  final int imapPort;
  final String smtpServer;
  final int smtpPort;

  ImapClient? _imapClient;
  StreamController<void>? _newMessageController;
  bool _isIdleRunning = false;
  bool _isFetching = false;
  int _lastKnownExists = 0;
  int _lastUidNext = 0; // Как в Delta Chat - отслеживаем UIDNEXT
  int _uidValidity = 0; // Для проверки что ящик не пересоздан

  EmailService({
    required this.email,
    required this.password,
    this.imapServer = 'imap.mail.ru',
    this.imapPort = 993,
    this.smtpServer = 'smtp.mail.ru',
    this.smtpPort = 587,
  });

  // Подключение к IMAP
  Future<void> connectImap() async {
    try {
      _imapClient = ImapClient(isLogEnabled: false);
      await _imapClient!.connectToServer(imapServer, imapPort, isSecure: true);
      await _imapClient!.login(email, password);
      final mailbox = await _imapClient!.selectInbox();
      
      _lastKnownExists = mailbox.messagesExists;
      _lastUidNext = mailbox.uidNext ?? 0;
      _uidValidity = mailbox.uidValidity ?? 0;
      
      LoggerService.log('IMAP: Connected, EXISTS=$_lastKnownExists, UIDNEXT=$_lastUidNext, UIDVALIDITY=$_uidValidity');
    } catch (e) {
      _imapClient = null;
      rethrow;
    }
  }

  // IMAP IDLE для мгновенных уведомлений (как в Delta Chat)
  Stream<void> listenForNewMessages() {
    if (_newMessageController != null && !_newMessageController!.isClosed) {
      return _newMessageController!.stream;
    }
    
    _newMessageController = StreamController<void>.broadcast();
    _startIdleLoop();
    
    return _newMessageController!.stream;
  }

  void _startIdleLoop() async {
    if (_isIdleRunning) return;
    _isIdleRunning = true;

    while (_isIdleRunning && _newMessageController != null && !_newMessageController!.isClosed) {
      try {
        if (_imapClient == null) {
          await connectImap();
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
        
        subscription = _imapClient!.eventBus!.on<ImapEvent>().listen((event) {
          if (event is ImapMessagesExistEvent) {
            newExists = event.newMessagesExists;
            
            // Уведомляем только если УВЕЛИЧИЛОСЬ
            if (newExists > _lastKnownExists) {
              LoggerService.log('IDLE: New message! $_lastKnownExists -> $newExists');
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
          await _imapClient!.idleDone();
          // NOOP для проверки соединения (как Delta Chat)
          await _imapClient!.noop();
          LoggerService.log('IDLE: Done + NOOP ok');
        } catch (e) {
          LoggerService.log('IDLE: Done/NOOP error: $e');
          _imapClient = null;
          continue;
        }
        
        // Если было новое письмо - уведомляем UI
        if (completer.isCompleted && newExists > _lastKnownExists) {
          _lastKnownExists = newExists;
          LoggerService.log('IDLE: Notifying UI (EXISTS: $_lastKnownExists)');
          if (_newMessageController != null && !_newMessageController!.isClosed) {
            _newMessageController!.add(null);
          }
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

  // Получение новых сообщений (как Delta Chat - используем UIDNEXT)
  Future<List<MimeMessage>> fetchNewMessages({int lastSeenUid = 0}) async {
    if (_isFetching) {
      LoggerService.log('Already fetching, skipping');
      return [];
    }
    
    _isFetching = true;
    
    try {
      if (_imapClient == null) await connectImap();

      // Проверяем UIDVALIDITY - если изменился, ящик пересоздан
      final mailbox = await _imapClient!.selectInbox();
      final currentUidValidity = mailbox.uidValidity ?? 0;
      
      if (_uidValidity != 0 && currentUidValidity != _uidValidity) {
        LoggerService.log('UIDVALIDITY changed! Mailbox was recreated. Resetting.');
        _uidValidity = currentUidValidity;
        _lastUidNext = mailbox.uidNext ?? 0;
        // Нужно пересинхронизировать всё, но пока просто сбрасываем
        return [];
      }
      
      _uidValidity = currentUidValidity;
      final currentUidNext = mailbox.uidNext ?? 0;
      
      // Если UIDNEXT не изменился - новых писем нет
      if (currentUidNext <= _lastUidNext) {
        LoggerService.log('No new messages (UIDNEXT=$currentUidNext)');
        return [];
      }
      
      LoggerService.log('New messages detected! UIDNEXT: $_lastUidNext -> $currentUidNext');
      
      // Батчинг: fetch по 50 писем за раз (как Delta Chat, но проще)
      final startUid = _lastUidNext > 0 ? _lastUidNext : 1;
      final totalNew = currentUidNext - startUid;
      final messages = <MimeMessage>[];
      
      LoggerService.log('fetch_new_msg_batch(INBOX): UIDVALIDITY=$_uidValidity, UIDNEXT=$currentUidNext');
      
      if (totalNew > 50) {
        LoggerService.log('Batching: $totalNew messages, fetching in batches of 50');
        
        // Fetch батчами
        for (int batchStart = startUid; batchStart < currentUidNext; batchStart += 50) {
          final batchEnd = (batchStart + 49 < currentUidNext) ? batchStart + 49 : currentUidNext - 1;
          
          LoggerService.log('Batch: UID $batchStart:$batchEnd');
          
          // Используем uidSearchMessages + uidFetchMessages для батча
          // Для uidSearchMessages используем просто 'ALL' и потом фильтруем по UID через MessageSequence
          // Или проще - сразу используем uidFetchMessages с MessageSequence
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
        LoggerService.log('Starting UID FETCH of message set "$startUid:*"');
        
        // Используем MessageSequence для диапазона UID
        final sequence = MessageSequence.fromRangeToLast(startUid);
        final fetchResult = await _imapClient!.uidFetchMessages(
          sequence,
          'BODY.PEEK[]',
        );
        
        LoggerService.log('Successfully received ${fetchResult.messages.length} messages.');
        messages.addAll(_filterChatMessages(fetchResult.messages, lastSeenUid));
      }
      
      // Обновляем UIDNEXT
      _lastUidNext = currentUidNext;
      
      LoggerService.log('${messages.length} mails read from "INBOX".');
      LoggerService.log('Fetched ${messages.length} new chat messages');
      return messages;
      
    } catch (e) {
      LoggerService.log('fetchNewMessages error: $e');
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
    final uniqueId = DateTime.now().microsecondsSinceEpoch;
    SmtpClient? client;
    
    try {
      LoggerService.log('SMTP[$uniqueId]: Creating client');
      
      // Создаём ПОЛНОСТЬЮ новый клиент с уникальным именем
      client = SmtpClient('msg_$uniqueId', isLogEnabled: false);
      
      LoggerService.log('SMTP[$uniqueId]: Connecting');
      await client.connectToServer(smtpServer, smtpPort, isSecure: false);
      
      LoggerService.log('SMTP[$uniqueId]: EHLO');
      await client.ehlo();
      
      LoggerService.log('SMTP[$uniqueId]: STARTTLS');
      await client.startTls();
      
      LoggerService.log('SMTP[$uniqueId]: AUTH');
      if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
        await client.authenticate(email, password, AuthMechanism.plain);
      } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
        await client.authenticate(email, password, AuthMechanism.login);
      } else {
        throw Exception('No auth');
      }
      
      LoggerService.log('SMTP[$uniqueId]: Authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = DateTime.now().microsecond;
      final messageId = '<$timestamp.$random@${email.split('@')[1]}>';
      
      final builder = MessageBuilder()
        ..from = [MailAddress('', email)]
        ..to = [MailAddress('', toEmail)]
        ..subject = '[chat]'
        ..text = encryptedPayload;
      
      if (bccToSelf) {
        builder.bcc = [MailAddress('', email)];
      }
      
      builder.setHeader('Message-ID', messageId);
      final message = builder.buildMimeMessage();

      LoggerService.log('SMTP[$uniqueId]: Sending');
      await client.sendMessage(message);
      LoggerService.log('SMTP[$uniqueId]: Sent');
      
      await client.quit();
      LoggerService.log('SMTP[$uniqueId]: Closed');
      
      return messageId;
      
    } catch (e, stack) {
      LoggerService.log('SMTP[$uniqueId] ERROR: $e');
      rethrow;
    } finally {
      if (client != null) {
        try {
          await client.disconnect();
        } catch (_) {}
      }
    }
  }

  // Закрытие соединений
  Future<void> disconnect() async {
    _isIdleRunning = false;
    await _imapClient?.logout();
    if (_newMessageController != null && !_newMessageController!.isClosed) {
      await _newMessageController?.close();
    }
  }
}
