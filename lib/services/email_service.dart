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
    _imapClient = ImapClient(isLogEnabled: false);
    await _imapClient!.connectToServer(imapServer, imapPort, isSecure: true);
    await _imapClient!.login(email, password);
    await _imapClient!.selectInbox();
  }

  // IMAP IDLE для мгновенных уведомлений
  Stream<void> listenForNewMessages() {
    _newMessageController = StreamController<void>.broadcast();
    
    _imapClient?.idleStart().listen((event) {
      if (event.eventType == ImapEventType.exists || 
          event.eventType == ImapEventType.recent) {
        _newMessageController?.add(null);
      }
    });

    return _newMessageController!.stream;
  }

  // Получение новых сообщений
  Future<List<MimeMessage>> fetchNewMessages({int lastSeenUid = 0}) async {
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
  }

  // Отправка сообщения
  Future<void> sendMessage({
    required String toEmail,
    required String encryptedPayload,
  }) async {
    _smtpClient ??= SmtpClient('secure_messenger', isLogEnabled: false);
    
    if (!_smtpClient!.isLoggedIn) {
      await _smtpClient!.connectToServer(smtpServer, smtpPort);
      await _smtpClient!.ehlo();
      await _smtpClient!.startTls();
      await _smtpClient!.login(email, password);
    }

    final message = MessageBuilder.buildSimpleTextMessage(
      MailAddress('', email),
      [MailAddress('', toEmail)],
      encryptedPayload,
      subject: '[chat]',
    );

    await _smtpClient!.sendMessage(message);
  }

  // Закрытие соединений
  Future<void> disconnect() async {
    await _imapClient?.logout();
    await _smtpClient?.quit();
    await _newMessageController?.close();
  }
}
