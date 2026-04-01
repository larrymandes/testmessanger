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
  bool _isIdleActive = false;
  bool _isFetching = false;

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
      // Порт 993 - это IMAP over SSL (implicit TLS)
      await _imapClient!.connectToServer(imapServer, imapPort, isSecure: true);
      await _imapClient!.login(email, password);
      await _imapClient!.selectInbox();
    } catch (e) {
      _imapClient = null;
      rethrow;
    }
  }

  // IMAP IDLE для мгновенных уведомлений
  Stream<void> listenForNewMessages() {
    if (_newMessageController != null && !_newMessageController!.isClosed) {
      return _newMessageController!.stream;
    }
    
    _newMessageController = StreamController<void>.broadcast();
    
    // Запускаем IDLE loop в фоне (не блокируем)
    _startIdleLoop();
    
    return _newMessageController!.stream;
  }

  void _startIdleLoop() async {
    if (_isIdleActive) return;
    _isIdleActive = true;

    while (_isIdleActive && _newMessageController != null && !_newMessageController!.isClosed) {
      try {
        if (_imapClient == null) {
          await connectImap();
        }

        // Проверяем поддержку IDLE
        if (!_imapClient!.serverInfo.supportsIdle) {
          LoggerService.log('ERROR: Server does not support IDLE');
          await Future.delayed(const Duration(seconds: 30));
          continue;
        }

        LoggerService.log('IDLE: Starting...');
        
        // Подписываемся на события ПЕРЕД запуском IDLE
        StreamSubscription<ImapEvent>? subscription;
        final completer = Completer<void>();
        
        subscription = _imapClient!.eventBus!.on<ImapEvent>().listen((event) {
          LoggerService.log('IDLE: Event: ${event.runtimeType}');
          
          // Реагируем только на новые сообщения (EXISTS)
          if (event is ImapMessagesExistEvent) {
            LoggerService.log('IDLE: New message detected!');
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        });
        
        // Запускаем IDLE
        await _imapClient!.idleStart();
        LoggerService.log('IDLE: Active, waiting for new messages...');
        
        // Ждём события или 28 минут (IDLE timeout)
        await Future.any([
          completer.future,
          Future.delayed(const Duration(minutes: 28)),
        ]);
        
        // Останавливаем IDLE
        await subscription.cancel();
        
        try {
          await _imapClient!.idleDone();
          LoggerService.log('IDLE: Done');
        } catch (e) {
          LoggerService.log('IDLE: idleDone error: $e');
        }
        
        // Если получили событие, уведомляем
        if (completer.isCompleted) {
          LoggerService.log('IDLE: Notifying UI about new message');
          if (_newMessageController != null && !_newMessageController!.isClosed) {
            _newMessageController!.add(null);
          }
        }
        
        // Небольшая пауза перед перезапуском IDLE
        await Future.delayed(const Duration(milliseconds: 200));
        
      } catch (e) {
        LoggerService.log('IDLE error: $e');
        _imapClient = null;
        
        // Ждём перед повторной попыткой
        await Future.delayed(const Duration(seconds: 5));
      }
    }
    
    LoggerService.log('IDLE: Loop ended');
  }

  // Получение новых сообщений
  Future<List<MimeMessage>> fetchNewMessages({int lastSeenUid = 0}) async {
    if (_isFetching) {
      LoggerService.log('Already fetching, skipping');
      return [];
    }
    
    _isFetching = true;
    bool needRestartIdle = false;
    
    try {
      // Останавливаем IDLE если активен
      if (_isIdleActive && _imapClient != null) {
        try {
          needRestartIdle = true;
          await _imapClient!.idleDone();
          LoggerService.log('IDLE: Paused for fetch');
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          LoggerService.log('idleDone error: $e');
        }
      }
      
      if (_imapClient == null) await connectImap();

      // Ищем только UNSEEN письма с [chat] в subject
      final searchResult = await _imapClient!.searchMessages(
        searchCriteria: 'UNSEEN SUBJECT "[chat]"',
      );

      if (searchResult.matchingSequence == null || searchResult.matchingSequence!.isEmpty) {
        LoggerService.log('No new messages found');
        return [];
      }

      LoggerService.log('Found ${searchResult.matchingSequence!.length} new messages');
      
      final messages = <MimeMessage>[];
      for (final uid in searchResult.matchingSequence!.toList()) {
        if (uid <= lastSeenUid || uid == 0) {
          LoggerService.log('Skipping UID: $uid (old or invalid)');
          continue;
        }

        try {
          final fetchResult = await _imapClient!.fetchMessage(uid, '(RFC822)');
          if (fetchResult.messages.isNotEmpty) {
            messages.add(fetchResult.messages.first);
            LoggerService.log('Fetched message UID: $uid');
            
            // Помечаем как прочитанное
            await _imapClient!.store(
              MessageSequence.fromId(uid),
              [r'\Seen'],
              action: StoreAction.add,
            );
          }
        } catch (e) {
          LoggerService.log('Error fetching UID $uid: $e');
        }
      }

      return messages;
    } catch (e) {
      LoggerService.log('fetchNewMessages error: $e');
      // Если ошибка подключения, сбрасываем клиент для переподключения
      if (e.toString().contains('Connection') || e.toString().contains('Socket')) {
        _imapClient = null;
        _isIdleActive = false;
        needRestartIdle = false;
      }
      rethrow;
    } finally {
      _isFetching = false;
      
      // Перезапускаем IDLE после fetch
      if (needRestartIdle && _imapClient != null) {
        try {
          await _imapClient!.idleStart();
          LoggerService.log('IDLE: Resumed after fetch');
        } catch (e) {
          LoggerService.log('Failed to resume IDLE: $e');
          _isIdleActive = false;
        }
      }
    }
  }

  // Отправка сообщения
  Future<void> sendMessage({
    required String toEmail,
    required String encryptedPayload,
  }) async {
    SmtpClient? client;
    
    try {
      // Всегда создаём новый клиент для каждой отправки
      // Это решает проблему "StreamSink is bound to a stream"
      client = SmtpClient('secure_messenger', isLogEnabled: false);
      
      LoggerService.log('SMTP: Connecting to $smtpServer:$smtpPort');
      
      // Для порта 587 подключаемся БЕЗ SSL, потом делаем STARTTLS
      await client.connectToServer(smtpServer, smtpPort, isSecure: false);
      LoggerService.log('SMTP: Connected, sending EHLO');
      
      await client.ehlo();
      LoggerService.log('SMTP: EHLO done, starting TLS');
      
      await client.startTls();
      LoggerService.log('SMTP: TLS started, authenticating');
      
      // Используем authenticate вместо login
      if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
        await client.authenticate(email, password, AuthMechanism.plain);
      } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
        await client.authenticate(email, password, AuthMechanism.login);
      }
      
      LoggerService.log('SMTP: Authenticated');

      final message = MessageBuilder.buildSimpleTextMessage(
        MailAddress('', email),
        [MailAddress('', toEmail)],
        encryptedPayload,
        subject: '[chat]',
      );

      LoggerService.log('SMTP: Sending message to $toEmail');
      await client.sendMessage(message);
      LoggerService.log('SMTP: Message sent successfully');
      
      // Закрываем соединение
      await client.quit();
      LoggerService.log('SMTP: Connection closed');
      
    } catch (e) {
      LoggerService.log('SMTP error: $e');
      rethrow;
    } finally {
      // Всегда закрываем соединение
      try {
        await client?.quit();
      } catch (e) {
        // Игнорируем ошибки при закрытии
      }
    }
  }

  // Закрытие соединений
  Future<void> disconnect() async {
    _isIdleActive = false;
    await _imapClient?.logout();
    if (_newMessageController != null && !_newMessageController!.isClosed) {
      await _newMessageController?.close();
    }
  }
}
