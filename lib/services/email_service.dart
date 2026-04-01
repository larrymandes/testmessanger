import 'dart:async';
import 'package:enough_mail/enough_mail.dart';

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
    _newMessageController = StreamController<void>.broadcast();
    
    // IMAP IDLE работает через polling в enough_mail
    // Используем таймер для проверки новых сообщений
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final searchResult = await _imapClient?.searchMessages(
          searchCriteria: 'UNSEEN SUBJECT "[chat]"',
        );
        
        if (searchResult?.matchingSequence != null && 
            searchResult!.matchingSequence!.isNotEmpty) {
          _newMessageController?.add(null);
        }
      } catch (e) {
        print('IDLE check error: $e');
      }
    });

    return _newMessageController!.stream;
  }

  // Получение новых сообщений
  Future<List<MimeMessage>> fetchNewMessages({int lastSeenUid = 0}) async {
    try {
      if (_imapClient == null) await connectImap();

      // Ищем только UNSEEN письма с [chat] в subject
      final searchResult = await _imapClient!.searchMessages(
        searchCriteria: 'UNSEEN SUBJECT "[chat]"',
      );

    if (searchResult.matchingSequence == null) return [];

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
      }
      rethrow;
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
        // Для порта 587 подключаемся БЕЗ SSL, потом делаем STARTTLS
        await _smtpClient!.connectToServer(smtpServer, smtpPort, isSecure: false);
        await _smtpClient!.ehlo();
        await _smtpClient!.startTls();
        
        // Используем authenticate вместо login
        if (_smtpClient!.serverInfo.supportsAuth(AuthMechanism.plain)) {
          await _smtpClient!.authenticate(email, password, AuthMechanism.plain);
        } else if (_smtpClient!.serverInfo.supportsAuth(AuthMechanism.login)) {
          await _smtpClient!.authenticate(email, password, AuthMechanism.login);
        }
      }

      final message = MessageBuilder.buildSimpleTextMessage(
        MailAddress('', email),
        [MailAddress('', toEmail)],
        encryptedPayload,
        subject: '[chat]',
      );

      await _smtpClient!.sendMessage(message);
    } catch (e) {
      // Если ошибка подключения, сбрасываем клиент для переподключения
      if (e.toString().contains('Connection') || e.toString().contains('Socket') || 
          e.toString().contains('HandshakeException')) {
        _smtpClient = null;
      }
      rethrow;
    }
  }

  // Закрытие соединений
  Future<void> disconnect() async {
    await _imapClient?.logout();
    await _smtpClient?.quit();
    await _newMessageController?.close();
  }
}
