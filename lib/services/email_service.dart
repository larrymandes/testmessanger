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
  SmtpClient? _smtpClient;
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

  void _startIdleLoop() {
    // Запускаем в отдельном Future чтобы не блокировать
    Future(() async {
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
            throw Exception('IMAP IDLE not supported by server');
          }

          LoggerService.log('IDLE: Starting...');
          await _imapClient!.idleStart();
          LoggerService.log('IDLE: Active, waiting for events');
          
          // Ждём события или 28 минут
          bool gotEvent = false;
          final startTime = DateTime.now();
          
          // Слушаем события через eventBus
          StreamSubscription<ImapEvent>? subscription;
          if (_imapClient!.eventBus != null) {
            subscription = _imapClient!.eventBus!.on<ImapEvent>().listen((event) {
              LoggerService.log('IDLE: Event received: ${event.runtimeType}');
              if (event is ImapExpungeEvent || event is ImapFetchEvent || event is ImapVanishedEvent) {
                gotEvent = true;
              }
            });
          } else {
            LoggerService.log('IDLE: WARNING - eventBus is null');
          }
          
          // Ждём события или 28 минут
          while (_isIdleActive && DateTime.now().difference(startTime).inMinutes < 28 && !gotEvent) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
          
          // Останавливаем IDLE
          await subscription?.cancel();
          
          if (_imapClient != null) {
            try {
              await _imapClient!.idleDone();
              LoggerService.log('IDLE: Stopped');
            } catch (e) {
              LoggerService.log('IDLE: idleDone error: $e');
            }
          }
          
          // Если получили событие, уведомляем
          if (gotEvent) {
            LoggerService.log('IDLE: Notifying about new message');
            if (_newMessageController != null && !_newMessageController!.isClosed) {
              _newMessageController!.add(null);
            }
            // Небольшая пауза перед перезапуском
            await Future.delayed(const Duration(milliseconds: 500));
          } else {
            LoggerService.log('IDLE: Timeout reached, restarting');
          }
          
        } catch (e) {
          LoggerService.log('IDLE error: $e');
          _imapClient = null;
          _isIdleActive = false;
          
          // Ждём перед повторной попыткой
          await Future.delayed(const Duration(seconds: 10));
        }
      }
      
      LoggerService.log('IDLE: Loop ended');
    });
  }

  // Получение новых сообщений
  Future<List<MimeMessage>> fetchNewMessages({int lastSeenUid = 0}) async {
    if (_isFetching) {
      LoggerService.log('Already fetching, skipping');
      return [];
    }
    
    _isFetching = true;
    
    try {
      // Останавливаем IDLE если активен
      if (_isIdleActive && _imapClient != null) {
        try {
          _isIdleActive = false;
          await _imapClient!.idleDone();
          LoggerService.log('IDLE stopped for fetch');
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

      if (searchResult.matchingSequence == null) {
        return [];
      }

      final messages = <MimeMessage>[];
      for (final uid in searchResult.matchingSequence!.toList()) {
        if (uid <= lastSeenUid) continue;

        final fetchResult = await _imapClient!.fetchMessage(uid, '(RFC822)');
        if (fetchResult.messages.isNotEmpty) {
          messages.add(fetchResult.messages.first);
          
          // Помечаем как прочитанное
          await _imapClient!.store(
            MessageSequence.fromId(uid),
            [r'\Seen'],
            action: StoreAction.add,
          );
        }
      }

      return messages;
    } catch (e) {
      // Если ошибка подключения, сбрасываем клиент для переподключения
      if (e.toString().contains('Connection') || e.toString().contains('Socket')) {
        _imapClient = null;
        _isIdleActive = false;
      }
      rethrow;
    } finally {
      _isFetching = false;
      
      // Перезапускаем IDLE после fetch
      if (_imapClient != null && !_isIdleActive && _newMessageController != null && !_newMessageController!.isClosed) {
        try {
          await _imapClient!.idleStart();
          _isIdleActive = true;
          LoggerService.log('IDLE restarted after fetch');
        } catch (e) {
          LoggerService.log('Failed to restart IDLE: $e');
        }
      }
    }
  }

  // Отправка сообщения
  Future<void> sendMessage({
    required String toEmail,
    required String encryptedPayload,
  }) async {
    try {
      _smtpClient ??= SmtpClient('secure_messenger', isLogEnabled: false);
      
      if (!_smtpClient!.isLoggedIn) {
        LoggerService.log('SMTP: Connecting to $smtpServer:$smtpPort');
        
        // Для порта 587 подключаемся БЕЗ SSL, потом делаем STARTTLS
        await _smtpClient!.connectToServer(smtpServer, smtpPort, isSecure: false);
        LoggerService.log('SMTP: Connected, sending EHLO');
        
        await _smtpClient!.ehlo();
        LoggerService.log('SMTP: EHLO done, starting TLS');
        
        await _smtpClient!.startTls();
        LoggerService.log('SMTP: TLS started, authenticating');
        
        // Используем authenticate вместо login
        if (_smtpClient!.serverInfo.supportsAuth(AuthMechanism.plain)) {
          await _smtpClient!.authenticate(email, password, AuthMechanism.plain);
        } else if (_smtpClient!.serverInfo.supportsAuth(AuthMechanism.login)) {
          await _smtpClient!.authenticate(email, password, AuthMechanism.login);
        }
        
        LoggerService.log('SMTP: Authenticated');
      }

      final message = MessageBuilder.buildSimpleTextMessage(
        MailAddress('', email),
        [MailAddress('', toEmail)],
        encryptedPayload,
        subject: '[chat]',
      );

      LoggerService.log('SMTP: Sending message to $toEmail');
      await _smtpClient!.sendMessage(message);
      LoggerService.log('SMTP: Message sent successfully');
    } catch (e) {
      LoggerService.log('SMTP error: $e');
      // Если ошибка подключения, сбрасываем клиент для переподключения
      if (e.toString().contains('Connection') || e.toString().contains('Socket') || 
          e.toString().contains('HandshakeException') || e.toString().contains('WRONG_VERSION')) {
        _smtpClient = null;
      }
      rethrow;
    }
  }

  // Закрытие соединений
  Future<void> disconnect() async {
    _isIdleActive = false;
    await _imapClient?.logout();
    await _smtpClient?.quit();
    if (_newMessageController != null && !_newMessageController!.isClosed) {
      await _newMessageController?.close();
    }
  }
}
