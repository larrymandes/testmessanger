import 'dart:convert';
import 'email_service.dart';
import 'message_service.dart';
import 'account_service.dart';
import 'storage_service.dart';
import 'logger_service.dart';
import 'crypto_service.dart';

/// ChatService - главный координатор
/// Связывает EmailService и MessageService
/// Это единая точка входа для UI
class ChatService {
  final String email;
  final String password;
  
  late final EmailService _emailService;
  late final MessageService _messageService;
  late final AccountData _accountData;
  
  bool _initialized = false;
  
  // Храним callbacks до инициализации MessageService
  final List<Function()> _pendingUICallbacks = [];
  final List<Function(List<String> uids, String status)> _pendingStatusCallbacks = [];
  
  // Rate limiting: 2 сообщения в секунду
  static const int _maxMessagesPerSecond = 2;
  static const int _rateLimitWindowMs = 1000;
  final List<int> _messageSendTimestamps = [];
  
  // Лимит символов на сообщение (как в Telegram)
  static const int _maxMessageLength = 4096;
  
  ChatService({
    required this.email,
    required this.password,
  });
  
  /// Инициализация (вызывается один раз)
  Future<void> initialize() async {
    if (_initialized) return;
    
    LoggerService.log('ChatService: Initializing for $email');
    
    // 1. Загружаем/генерируем ключи
    _accountData = await AccountService.loadOrGenerateAccount(email);
    
    // 2. Создаём MessageService
    _messageService = MessageService(
      accountEmail: email,
      keyPair: _accountData.keyPair,
    );
    
    // 2.1. Регистрируем все pending callbacks
    for (final callback in _pendingUICallbacks) {
      _messageService.addUICallback(callback);
    }
    for (final callback in _pendingStatusCallbacks) {
      _messageService.addStatusUpdateCallback(callback);
    }
    _pendingUICallbacks.clear();
    _pendingStatusCallbacks.clear();
    
    // 2.2. Регистрируем callback для автоматической отправки ответного инвайта
    _messageService.setSendInviteCallback((contactEmail, contactPubKey) async {
      LoggerService.log('ChatService: Auto-reply invite callback triggered for $contactEmail');
      await _sendInviteReply(contactEmail, contactPubKey);
    });
    
    // 3. Создаём EmailService
    _emailService = EmailService(
      email: email,
      password: password,
    );
    
    // 4. Связываем: EmailService → MessageService → UI
    // EmailService вызывает processor для обработки сообщений
    _emailService.setMessageProcessor(() async {
      LoggerService.log('ChatService: Message processor triggered');
      
      // Fetch новых писем
      final maxUID = await StorageService.getMaxProcessedUID(email);
      final newMessages = await _emailService.fetchNewMessages(lastSeenUid: maxUID);
      
      // Обрабатываем через MessageService (он сам уведомит UI)
      if (newMessages.isNotEmpty) {
        await _messageService.processNewMessages(newMessages);
      }
    });
    
    // 5. Проверяем первый запуск ДО подключения
    final maxUIDBeforeConnect = await StorageService.getMaxProcessedUID(email);
    final isFirstRun = maxUIDBeforeConnect == 0;
    
    if (isFirstRun) {
      LoggerService.log('ChatService: First run detected - sync point will be set');
    } else {
      LoggerService.log('ChatService: Not first run (maxUID=$maxUIDBeforeConnect)');
    }
    
    // 6. Подключаемся к IMAP БЕЗ запуска IDLE (если не первый запуск)
    await _emailService.connectImap(startIdle: isFirstRun);
    
    // 7. ВАЖНО: Делаем начальный fetch ПОСЛЕ подключения (если не первый запуск)
    if (!isFirstRun) {
      LoggerService.log('ChatService: Doing initial fetch for missed messages...');
      try {
        final maxUID = await StorageService.getMaxProcessedUID(email);
        final newMessages = await _emailService.fetchNewMessages(lastSeenUid: maxUID);
        
        if (newMessages.isNotEmpty) {
          LoggerService.log('ChatService: Initial fetch - found ${newMessages.length} new messages');
          await _messageService.processNewMessages(newMessages);
        } else {
          LoggerService.log('ChatService: Initial fetch - no new messages');
        }
      } catch (e) {
        LoggerService.log('ChatService: Initial fetch error: $e');
        // Не падаем, продолжаем работу
      }
      
      // 8. Теперь запускаем IDLE (после fetch)
      LoggerService.log('ChatService: Starting IDLE after initial fetch');
      _emailService.startIdleIfNeeded();
    } else {
      LoggerService.log('ChatService: First run - skipping initial fetch (sync point set)');
      LoggerService.log('ChatService: IDLE already started');
    }
    
    _initialized = true;
    LoggerService.log('ChatService: Initialized successfully');
  }
  
  /// Регистрация UI callback
  void addUICallback(Function() callback) {
    if (_initialized) {
      _messageService.addUICallback(callback);
    } else {
      // Сохраняем до инициализации
      if (!_pendingUICallbacks.contains(callback)) {
        _pendingUICallbacks.add(callback);
        LoggerService.log('ChatService: UI callback queued (pending initialization)');
      }
    }
  }
  
  /// Удаление UI callback
  void removeUICallback(Function() callback) {
    if (_initialized) {
      _messageService.removeUICallback(callback);
    } else {
      _pendingUICallbacks.remove(callback);
    }
  }
  
  /// Регистрация callback для обновления статуса сообщений
  void addStatusUpdateCallback(Function(List<String> uids, String status) callback) {
    if (_initialized) {
      _messageService.addStatusUpdateCallback(callback);
    } else {
      // Сохраняем до инициализации
      if (!_pendingStatusCallbacks.contains(callback)) {
        _pendingStatusCallbacks.add(callback);
        LoggerService.log('ChatService: Status callback queued (pending initialization)');
      }
    }
  }
  
  /// Удаление callback для обновления статуса
  void removeStatusUpdateCallback(Function(List<String> uids, String status) callback) {
    if (_initialized) {
      _messageService.removeStatusUpdateCallback(callback);
    } else {
      _pendingStatusCallbacks.remove(callback);
    }
  }
  
  /// Проверка rate limit и ожидание если нужно
  Future<void> _waitForRateLimit() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Удаляем старые timestamps (старше 1 секунды)
    _messageSendTimestamps.removeWhere((ts) => now - ts > _rateLimitWindowMs);
    
    // Если лимит не достигнут - можно отправлять сразу
    if (_messageSendTimestamps.length < _maxMessagesPerSecond) {
      return;
    }
    
    // Лимит достигнут - нужно подождать
    // Ждём пока самый старый timestamp не выйдет за окно (1 секунда)
    final oldestTimestamp = _messageSendTimestamps.first;
    final timeSinceOldest = now - oldestTimestamp;
    final waitTime = _rateLimitWindowMs - timeSinceOldest;
    
    if (waitTime > 0) {
      LoggerService.log('ChatService: ⏳ Rate limit, waiting ${waitTime}ms...');
      await Future.delayed(Duration(milliseconds: waitTime));
    }
  }
  
  /// Добавление timestamp отправки
  void _addSendTimestamp() {
    _messageSendTimestamps.add(DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Отправка текстового сообщения с заданными UIDs (с валидацией, rate limiting и разделением)
  Future<void> sendTextMessageWithUIDs({
    required String toEmail,
    required String text,
    required String recipientPublicKey,
    required List<String> messageIds, // ← Теперь это Message-IDs!
    required Function(String messageId, String status) onStatusUpdate,
  }) async {
    LoggerService.log('ChatService: sendTextMessageWithUIDs() called');
    LoggerService.log('ChatService: Text length: ${text.length} chars, Message-IDs: ${messageIds.length}');
    
    // 1. Валидация публичного ключа
    if (!CryptoService.isValidPublicKey(recipientPublicKey)) {
      throw Exception('Неверный формат публичного ключа получателя');
    }
    
    // 2. Получаем свой никнейм
    final myAccount = await StorageService.getAccount(email);
    final myNickname = myAccount?['nickname'] ?? '';
    
    // 3. Разделяем текст на части
    final parts = _splitTextIntoParts(text);
    LoggerService.log('ChatService: Split into ${parts.length} part(s)');
    
    if (parts.length != messageIds.length) {
      throw Exception('Message-IDs count (${messageIds.length}) != parts count (${parts.length})');
    }
    
    // 4. Отправляем каждую часть с rate limiting
    for (int i = 0; i < parts.length; i++) {
      try {
        // Ждём если нужно (rate limiting)
        await _waitForRateLimit();
        
        LoggerService.log('ChatService: Sending part ${i + 1}/${parts.length} (${parts[i].length} chars)');
        
        // ✅ Шифруем (добавляем sender_nickname в КАЖДОЕ сообщение!)
        final encrypted = await CryptoService.encryptMessage(
          plaintext: jsonEncode({
            'text': parts[i],
            'local_message_id': messageIds[i],  // ← Для BCC обработки!
            'sender_nickname': myNickname.isNotEmpty ? myNickname : null, // ✅ Никнейм!
            'sender_email': email, // ✅ Email на всякий случай
          }),
          recipientPubKeyHex: recipientPublicKey,
          senderEmail: email,
          recipientEmail: toEmail,
        );
        
        // Отправляем с заданным Message-ID
        await _sendMessageWithId(
          toEmail: toEmail,
          encryptedPayload: jsonEncode(encrypted),
          messageId: messageIds[i],
        );
        
        // Сохраняем в БД
        await StorageService.saveMessage(
          messageId: messageIds[i],
          accountEmail: email,
          contactEmail: toEmail,
          text: parts[i],
          sent: true,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          status: 'sent',
        );
        
        // Добавляем timestamp для rate limiting
        _addSendTimestamp();
        
        LoggerService.log('ChatService: ✅ Part ${i + 1}/${parts.length} sent (Message-ID: ${messageIds[i]})');
        
        // Уведомляем UI об успешной отправке
        onStatusUpdate(messageIds[i], 'sent');
        
      } catch (e) {
        LoggerService.log('ChatService: ❌ Part ${i + 1}/${parts.length} error: $e');
        
        // Уведомляем UI об ошибке
        onStatusUpdate(messageIds[i], 'error');
        
        rethrow;
      }
    }
    
    LoggerService.log('ChatService: ✅ All ${parts.length} parts sent');
  }
  
  /// Отправка текстового сообщения (с валидацией, rate limiting и разделением)
  /// Возвращает список UID созданных сообщений
  Future<List<String>> sendTextMessageWithSplit({
    required String toEmail,
    required String text,
    required String recipientPublicKey,
    required Function(String uid, String status) onStatusUpdate,
  }) async {
    LoggerService.log('ChatService: sendTextMessageWithSplit() called');
    LoggerService.log('ChatService: Text length: ${text.length} chars');
    
    // 1. Валидация публичного ключа
    if (!CryptoService.isValidPublicKey(recipientPublicKey)) {
      throw Exception('Неверный формат публичного ключа получателя');
    }
    
    // 2. Получаем свой никнейм
    final myAccount = await StorageService.getAccount(email);
    final myNickname = myAccount?['nickname'] ?? '';
    
    // 3. Разделяем текст на части
    final parts = _splitTextIntoParts(text);
    LoggerService.log('ChatService: Split into ${parts.length} part(s)');
    
    // 4. Генерируем UIDs для всех частей
    final uids = <String>[];
    for (int i = 0; i < parts.length; i++) {
      final uid = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}_$i';
      uids.add(uid);
    }
    
    // 5. Отправляем каждую часть с rate limiting
    for (int i = 0; i < parts.length; i++) {
      try {
        // Ждём если нужно (rate limiting)
        await _waitForRateLimit();
        
        LoggerService.log('ChatService: Sending part ${i + 1}/${parts.length} (${parts[i].length} chars)');
        
        // ✅ Шифруем (добавляем sender_nickname в КАЖДОЕ сообщение!)
        final encrypted = await CryptoService.encryptMessage(
          plaintext: jsonEncode({
            'text': parts[i],
            'sender_nickname': myNickname.isNotEmpty ? myNickname : null, // ✅ Никнейм!
            'sender_email': email, // ✅ Email на всякий случай
          }),
          recipientPubKeyHex: recipientPublicKey,
          senderEmail: email,
          recipientEmail: toEmail,
        );
        
        // Отправляем и получаем Message-ID
        final messageId = await sendMessage(
          toEmail: toEmail,
          encryptedPayload: jsonEncode(encrypted),
        );
        
        // Сохраняем в БД с Message-ID
        await StorageService.saveMessage(
          messageId: messageId,
          accountEmail: email,
          contactEmail: toEmail,
          text: parts[i],
          sent: true,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          status: 'sent',
        );
        
        // Добавляем timestamp для rate limiting
        _addSendTimestamp();
        
        LoggerService.log('ChatService: ✅ Part ${i + 1}/${parts.length} sent (Message-ID: $messageId)');
        
        // Уведомляем UI об успешной отправке
        onStatusUpdate(uids[i], 'sent');
        
      } catch (e) {
        LoggerService.log('ChatService: ❌ Part ${i + 1}/${parts.length} error: $e');
        
        // Уведомляем UI об ошибке
        onStatusUpdate(uids[i], 'error');
        
        rethrow;
      }
    }
    
    LoggerService.log('ChatService: ✅ All ${parts.length} parts sent');
    return uids;
  }
  
  /// Разделение текста на части (4096 символов)
  List<String> _splitTextIntoParts(String text) {
    if (text.length <= _maxMessageLength) {
      return [text];
    }
    
    final parts = <String>[];
    int start = 0;
    
    while (start < text.length) {
      int end = start + _maxMessageLength;
      if (end > text.length) {
        end = text.length;
      }
      parts.add(text.substring(start, end));
      start = end;
    }
    
    return parts;
  }
  
  /// Отправка текстового сообщения (с валидацией и rate limiting)
  Future<void> sendTextMessage({
    required String toEmail,
    required String text,
    required String recipientPublicKey,
  }) async {
    // 1. Валидация публичного ключа
    if (!CryptoService.isValidPublicKey(recipientPublicKey)) {
      throw Exception('Неверный формат публичного ключа получателя');
    }
    
    // 2. Ждём если нужно (rate limiting)
    await _waitForRateLimit();
    
    LoggerService.log('ChatService: Sending message (${text.length} chars)');
    
    // 3. Шифруем
    final encrypted = await CryptoService.encryptMessage(
      plaintext: jsonEncode({'text': text}),
      recipientPubKeyHex: recipientPublicKey,
      senderEmail: email,
      recipientEmail: toEmail,
    );
    
    // 4. Отправляем
    await sendMessage(
      toEmail: toEmail,
      encryptedPayload: jsonEncode(encrypted),
    );
    
    // 5. Добавляем timestamp для rate limiting
    _addSendTimestamp();
    
    LoggerService.log('ChatService: ✅ Message sent');
  }
  
  /// Отправка сообщения (с rate limiting и разделением длинных сообщений)
  Future<String> sendMessage({
    required String toEmail,
    required String encryptedPayload,
    bool bccToSelf = true,
  }) async {
    return await _emailService.sendMessage(
      toEmail: toEmail,
      encryptedPayload: encryptedPayload,
      bccToSelf: bccToSelf,
    );
  }
  
  /// Отправка сообщения с заданным Message-ID (для UI)
  Future<void> _sendMessageWithId({
    required String toEmail,
    required String encryptedPayload,
    required String messageId,
    bool bccToSelf = true,
  }) async {
    await _emailService.sendMessageWithId(
      toEmail: toEmail,
      encryptedPayload: encryptedPayload,
      messageId: messageId,
      bccToSelf: bccToSelf,
    );
  }
  
  /// Получение данных аккаунта
  AccountData get accountData => _accountData;
  
  /// Принудительный fetch новых сообщений (для resume и т.д.)
  Future<void> fetchAndProcessNewMessages() async {
    if (!_initialized) {
      LoggerService.log('ChatService: Not initialized, skipping fetch');
      return;
    }
    
    LoggerService.log('ChatService: fetchAndProcessNewMessages() called');
    
    try {
      final maxUID = await StorageService.getMaxProcessedUID(email);
      LoggerService.log('ChatService: maxUID from DB = $maxUID');
      
      final newMessages = await _emailService.fetchNewMessages(lastSeenUid: maxUID);
      
      if (newMessages.isNotEmpty) {
        LoggerService.log('ChatService: Fetched ${newMessages.length} new messages');
        await _messageService.processNewMessages(newMessages);
      } else {
        LoggerService.log('ChatService: No new messages');
      }
    } catch (e) {
      LoggerService.log('ChatService: Fetch error: $e');
      rethrow;
    }
  }
  
  /// Добавление контакта через QR (с отправкой invite)
  Future<void> addContactWithInvite({
    required String contactEmail,
    required String contactPublicKey,
  }) async {
    LoggerService.log('ChatService: Adding contact $contactEmail with invite');
    
    // 1. Валидация публичного ключа
    LoggerService.log('ChatService: Validating public key...');
    if (!CryptoService.isValidPublicKey(contactPublicKey)) {
      throw Exception('Неверный формат публичного ключа');
    }
    LoggerService.log('ChatService: ✅ Public key is valid');
    
    // 2. Проверяем что не добавляем самого себя
    if (contactEmail == email) {
      throw Exception('Нельзя добавить самого себя');
    }
    
    // 3. Проверяем что контакт ещё не добавлен
    final existing = await StorageService.getContact(email, contactEmail);
    if (existing != null) {
      LoggerService.log('ChatService: Contact already exists');
      return; // Не ошибка, просто уже есть
    }
    
    // 4. Получаем свой никнейм из БД
    final myAccount = await StorageService.getAccount(email);
    final myNickname = myAccount?['nickname'] ?? '';
    
    // 5. Создаём invite сообщение с никнеймом
    final fingerprint = await CryptoService.getEmojiFingerprint(_accountData.publicKeyHex);
    final inviteMessage = jsonEncode({
      'type': 'invite',
      'email': email,
      'pubkey': _accountData.publicKeyHex,
      'fingerprint': fingerprint,
      'nickname': myNickname.isNotEmpty ? myNickname : null, // ✅ Никнейм
    });
    
    // 6. Шифруем
    LoggerService.log('ChatService: Encrypting invite...');
    final encrypted = await CryptoService.encryptMessage(
      plaintext: inviteMessage,
      recipientPubKeyHex: contactPublicKey,
      senderEmail: email,
      recipientEmail: contactEmail,
    );
    
    // 7. ВАЖНО: СНАЧАЛА отправляем invite
    LoggerService.log('ChatService: Sending invite via SMTP...');
    await sendMessage(
      toEmail: contactEmail,
      encryptedPayload: jsonEncode(encrypted),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Таймаут отправки (30 сек)');
      },
    );
    
    LoggerService.log('ChatService: ✅ Invite sent successfully!');
    
    // 8. Invite отправлен успешно → ТЕПЕРЬ сохраняем контакт в БД
    await StorageService.saveContact(
      accountEmail: email,
      contactEmail: contactEmail,
      publicKey: contactPublicKey,
    );
    
    LoggerService.log('ChatService: ✅ Contact $contactEmail saved to DB');
  }
  
  /// Отправка ответного инвайта (БЕЗ сохранения контакта - он уже сохранён)
  Future<void> _sendInviteReply(String contactEmail, String contactPubKey) async {
    LoggerService.log('ChatService: Sending reply invite to $contactEmail');
    
    try {
      // 1. Получаем свой никнейм из БД
      final myAccount = await StorageService.getAccount(email);
      final myNickname = myAccount?['nickname'] ?? '';
      
      // 2. Создаём invite сообщение с никнеймом
      final fingerprint = await CryptoService.getEmojiFingerprint(_accountData.publicKeyHex);
      final inviteMessage = jsonEncode({
        'type': 'invite',
        'email': email,
        'pubkey': _accountData.publicKeyHex,
        'fingerprint': fingerprint,
        'nickname': myNickname.isNotEmpty ? myNickname : null, // ✅ Никнейм
      });
      
      // 3. Шифруем
      final encrypted = await CryptoService.encryptMessage(
        plaintext: inviteMessage,
        recipientPubKeyHex: contactPubKey,
        senderEmail: email,
        recipientEmail: contactEmail,
      );
      
      // 4. Отправляем (контакт УЖЕ сохранён, просто отправляем)
      await sendMessage(
        toEmail: contactEmail,
        encryptedPayload: jsonEncode(encrypted),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Таймаут отправки ответного инвайта (30 сек)');
        },
      );
      
      LoggerService.log('ChatService: ✅ Reply invite sent to $contactEmail');
    } catch (e) {
      LoggerService.log('ChatService: ❌ Failed to send reply invite: $e');
      // Не критично, контакт уже сохранён
      rethrow;
    }
  }
  
  /// Отправка read receipts для контакта (вызывается из UI)
  Future<void> sendReadReceipts(String contactEmail) async {
    if (!_initialized) {
      LoggerService.log('ChatService: Not initialized, skipping read receipts');
      return;
    }
    
    LoggerService.log('ChatService: sendReadReceipts() for $contactEmail');
    
    // Вызываем MessageService с callback для отправки
    await _messageService.sendReadReceipts(
      contactEmail: contactEmail,
      sendMessageCallback: (toEmail, encrypted) async {
        // Отправляем БЕЗ BCC (read receipts не нужны себе)
        await sendMessage(
          toEmail: toEmail,
          encryptedPayload: jsonEncode(encrypted),
          bccToSelf: false,
        );
      },
    );
  }
  
  /// Отключение
  Future<void> disconnect() async {
    await _emailService.disconnect();
  }
}
