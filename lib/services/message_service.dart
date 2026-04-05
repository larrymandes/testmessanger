import 'dart:convert';
import 'package:enough_mail/enough_mail.dart';
import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PublicKey, PrivateKey;
import 'crypto_service.dart';
import 'storage_service.dart';
import 'logger_service.dart';

/// MessageService - вся бизнес-логика обработки сообщений
/// Отвечает за:
/// - Обработку входящих писем
/// - Расшифровку
/// - Сохранение в БД
/// - Уведомление UI
class MessageService {
  final String accountEmail;
  final AsymmetricKeyPair<PublicKey, PrivateKey> keyPair;
  
  // Callbacks для уведомления UI
  final List<Function()> _uiCallbacks = [];
  
  // Callbacks для обновления статуса сообщений (без перезагрузки)
  final List<Function(List<String> uids, String status)> _statusUpdateCallbacks = [];
  
  // Callback для автоматической отправки ответного инвайта
  Function(String contactEmail, String contactPubKey)? _sendInviteCallback;
  
  // ✅ Флаг для защиты от параллельных вызовов sendReadReceipts
  final Map<String, bool> _sendingReadReceipts = {};
  
  MessageService({
    required this.accountEmail,
    required this.keyPair,
  });
  
  /// Регистрация callback для уведомления UI
  void addUICallback(Function() callback) {
    if (!_uiCallbacks.contains(callback)) {
      _uiCallbacks.add(callback);
      LoggerService.log('MessageService: UI callback registered (total: ${_uiCallbacks.length})');
    }
  }
  
  /// Удаление callback
  void removeUICallback(Function() callback) {
    _uiCallbacks.remove(callback);
    LoggerService.log('MessageService: UI callback removed (total: ${_uiCallbacks.length})');
  }
  
  /// Регистрация callback для обновления статуса сообщений
  void addStatusUpdateCallback(Function(List<String> uids, String status) callback) {
    if (!_statusUpdateCallbacks.contains(callback)) {
      _statusUpdateCallbacks.add(callback);
      LoggerService.log('MessageService: Status update callback registered (total: ${_statusUpdateCallbacks.length})');
    }
  }
  
  /// Удаление callback для обновления статуса
  void removeStatusUpdateCallback(Function(List<String> uids, String status) callback) {
    _statusUpdateCallbacks.remove(callback);
    LoggerService.log('MessageService: Status update callback removed (total: ${_statusUpdateCallbacks.length})');
  }
  
  /// Регистрация callback для автоматической отправки ответного инвайта
  void setSendInviteCallback(Function(String contactEmail, String contactPubKey) callback) {
    _sendInviteCallback = callback;
    LoggerService.log('MessageService: Send invite callback registered');
  }
  
  /// Обработка новых писем (вызывается из EmailService)
  Future<void> processNewMessages(List<MimeMessage> messages) async {
    LoggerService.log('MessageService: Processing ${messages.length} new messages');
    
    int processed = 0;
    bool shouldNotifyUI = false;
    
    for (final message in messages) {
      try {
        final notifyUI = await _processMessage(message);
        processed++;
        if (notifyUI) {
          shouldNotifyUI = true;
        }
      } catch (e) {
        LoggerService.log('MessageService: Error processing message: $e');
      }
    }
    
    LoggerService.log('MessageService: Processed $processed/${messages.length} messages');
    
    // Проверяем и повторяем отправку ответных инвайтов для non-mutual контактов
    await _retryPendingInvites();
    
    // Уведомляем UI только если были реальные сообщения (не BCC копии)
    if (shouldNotifyUI) {
      _notifyUI();
    }
  }
  
  /// Повторная отправка ответных инвайтов для контактов с mutual = false
  Future<void> _retryPendingInvites() async {
    try {
      // ✅ Получаем только те контакты, кому ещё НЕ отправляли (invite_sent = 0)
      final nonMutualContacts = await StorageService.getNonMutualContacts(accountEmail);
      
      if (nonMutualContacts.isEmpty) {
        return;
      }
      
      LoggerService.log('MessageService: Found ${nonMutualContacts.length} non-mutual contacts (not sent yet), retrying invites...');
      
      for (final contact in nonMutualContacts) {
        final contactEmail = contact['email'] as String;
        final contactPubKey = contact['publicKey'] as String;
        
        if (_sendInviteCallback != null) {
          try {
            LoggerService.log('MessageService: Retrying invite to $contactEmail...');
            await _sendInviteCallback!(contactEmail, contactPubKey);
            
            // ✅ Отправка успешна → ставим mutual = true
            await StorageService.setContactMutual(
              accountEmail: accountEmail,
              contactEmail: contactEmail,
            );
            LoggerService.log('MessageService: ✅ Retry successful for $contactEmail, set as mutual');
            
          } catch (e) {
            LoggerService.log('MessageService: ❌ Retry failed for $contactEmail: $e');
            
            // ✅ Отмечаем что попытка была (защита от спама)
            await StorageService.markInviteSent(
              accountEmail: accountEmail,
              contactEmail: contactEmail,
            );
            LoggerService.log('MessageService: ⚠️ Marked as invite_sent (will not retry again)');
            // Больше не будем пытаться (защита от спама)
          }
        }
      }
    } catch (e) {
      LoggerService.log('MessageService: Error in _retryPendingInvites: $e');
    }
  }
  
  /// Обработка одного письма
  /// Возвращает true если нужно уведомить UI (не BCC копия)
  Future<bool> _processMessage(MimeMessage mimeMessage) async {
    final from = mimeMessage.from?.first?.email ?? '';
    final uid = mimeMessage.uid ?? 0;
    final messageId = mimeMessage.decodeHeaderValue('message-id') ?? '';
    
    LoggerService.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    LoggerService.log('📨 Processing message UID=$uid from $from');
    
    if (uid == 0) {
      LoggerService.log('❌ UID is 0, skipping');
      return false; // ✅ Не уведомляем UI
    }
    
    // ВАЖНО: Проверяем что UID ещё НЕ обработан (защита от дублирования)
    final alreadyProcessed = await StorageService.isUIDProcessed(accountEmail, uid);
    if (alreadyProcessed) {
      LoggerService.log('⏭️ UID=$uid already processed, skipping');
      return false; // ✅ Не уведомляем UI
    }
    
    // ВАЖНО: Проверяем Message-ID (защита от дублирования при повторном fetch)
    if (messageId.isNotEmpty) {
      final messageIdProcessed = await StorageService.isMessageIdProcessed(accountEmail, messageId);
      if (messageIdProcessed) {
        LoggerService.log('⏭️ Message-ID=$messageId already processed, skipping');
        // Помечаем UID тоже (на всякий случай)
        await StorageService.addProcessedUID(accountEmail, uid);
        return false; // ✅ Не уведомляем UI
      }
    }
    
    // СРАЗУ помечаем как обработанное (чтобы избежать race condition)
    await StorageService.addProcessedUID(accountEmail, uid);
    if (messageId.isNotEmpty) {
      await StorageService.addProcessedMessageId(accountEmail, messageId);
    }
    LoggerService.log('✅ Marked UID=$uid as processed (Message-ID: ${messageId.isNotEmpty ? messageId : "none"})');
    
    // ВАЖНО: Обрабатываем BCC копии для обновления серверного Message-ID!
    if (from == accountEmail) {
      LoggerService.log('📤 BCC copy from myself - extracting server Message-ID');
      
      // ✅ СНАЧАЛА пробуем извлечь локальный Message-ID из заголовка (быстро и надёжно!)
      final localMessageIdFromHeader = mimeMessage.decodeHeaderValue('x-local-message-id');
      
      if (localMessageIdFromHeader != null && localMessageIdFromHeader.isNotEmpty && messageId.isNotEmpty) {
        LoggerService.log('📤 ✅ Found X-Local-Message-ID in header: $localMessageIdFromHeader');
        
        if (localMessageIdFromHeader != messageId) {
          LoggerService.log('📤 Updating server Message-ID: $localMessageIdFromHeader -> $messageId');
          await _updateServerMessageId(localMessageIdFromHeader, messageId);
          LoggerService.log('📤 ✅ Server Message-ID updated successfully!');
        } else {
          LoggerService.log('📤 Local and server Message-IDs are the same, skipping update');
        }
        
        return false; // ✅ BCC копия - НЕ уведомляем UI
      }
      
      // ❌ Заголовка нет - пробуем старый способ (расшифровка body)
      LoggerService.log('📤 ⚠️ X-Local-Message-ID header not found, trying to decrypt body...');
      
      // Получаем body для извлечения локального Message-ID
      String body = '';
      final textPlainPart = mimeMessage.getPartWithMediaSubtype(MediaSubtype.textPlain);
      if (textPlainPart != null) {
        body = textPlainPart.decodeContentText() ?? '';
      } else {
        body = mimeMessage.decodeTextPlainPart() ?? '';
      }
      
      body = body.replaceAll(RegExp(r'\s+'), '');
      
      try {
        final encrypted = jsonDecode(body) as Map<String, dynamic>;
        final plaintext = await CryptoService.decryptMessage(
          encrypted: encrypted.map((k, v) => MapEntry(k, v.toString())),
          myKeyPair: keyPair,
        );
        
        final parsed = jsonDecode(plaintext);
        
        // Извлекаем локальный Message-ID из метаданных
        final localMessageId = parsed['local_message_id'] as String?;
        
        if (localMessageId != null && messageId.isNotEmpty && localMessageId != messageId) {
          LoggerService.log('📤 Updating server Message-ID: $localMessageId -> $messageId');
          
          // Обновляем в БД: заменяем локальный Message-ID на серверный
          await _updateServerMessageId(localMessageId, messageId);
          
          LoggerService.log('📤 ✅ Server Message-ID updated');
        } else {
          LoggerService.log('📤 No local_message_id in BCC copy or same as server');
        }
      } catch (e) {
        LoggerService.log('📤 ⚠️ Failed to extract local Message-ID from BCC: $e');
      }
      
      return false; // ✅ BCC копия - НЕ уведомляем UI
    }
    
    // Получаем body
    String body = '';
    final textPlainPart = mimeMessage.getPartWithMediaSubtype(MediaSubtype.textPlain);
    if (textPlainPart != null) {
      body = textPlainPart.decodeContentText() ?? '';
    } else {
      body = mimeMessage.decodeTextPlainPart() ?? '';
    }
    
    LoggerService.log('📄 Raw body length: ${body.length} chars');
    
    // Убираем пробелы
    body = body.replaceAll(RegExp(r'\s+'), '');
    LoggerService.log('📄 Body after whitespace removal: ${body.length} chars');
    
    // Парсим JSON (зашифрованное)
    Map<String, dynamic> encrypted;
    try {
      encrypted = jsonDecode(body) as Map<String, dynamic>;
      LoggerService.log('🔐 Encrypted JSON parsed, keys: ${encrypted.keys.toList()}');
    } catch (e) {
      LoggerService.log('❌ Failed to parse encrypted JSON: $e');
      return false; // ✅ Не уведомляем UI
    }
    
    // Расшифровываем
    String plaintext;
    try {
      plaintext = await CryptoService.decryptMessage(
        encrypted: encrypted.map((k, v) => MapEntry(k, v.toString())),
        myKeyPair: keyPair,
      );
      LoggerService.log('🔓 Decrypted successfully');
      LoggerService.log('📝 Plaintext: $plaintext');
    } catch (e) {
      LoggerService.log('❌ Decryption failed: $e');
      return false; // ✅ Не уведомляем UI
    }
    
    // Обрабатываем по типу
    try {
      final parsed = jsonDecode(plaintext);
      LoggerService.log('✅ Plaintext JSON parsed');
      LoggerService.log('📋 Type: ${parsed['type']}');
      LoggerService.log('📋 Keys: ${parsed.keys.toList()}');
      LoggerService.log('📋 Full parsed data: $parsed');
      
      if (parsed['type'] == 'invite') {
        LoggerService.log('👥 Processing INVITE');
        await _handleInvite(parsed, from);
      } else if (parsed['type'] == 'read_receipt') {
        LoggerService.log('📖 Processing READ_RECEIPT');
        await _handleReadReceipt(parsed, from);
      } else if (parsed['text'] != null) {
        LoggerService.log('💬 Processing TEXT message');
        await _handleTextMessage(parsed, from, uid, messageId);
      } else {
        LoggerService.log('⚠️ Unknown message format, treating as text');
        await _handleTextMessage({'text': plaintext, 'uid': uid.toString()}, from, uid, messageId);
      }
    } catch (e) {
      // Старый формат или не JSON
      LoggerService.log('⚠️ Not JSON or parse error: $e');
      LoggerService.log('📝 Treating as plain text message');
      await _handleTextMessage({'text': plaintext, 'uid': uid.toString()}, from, uid, messageId);
    }
    
    LoggerService.log('✅ Message UID=$uid processed');
    LoggerService.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    return true; // ✅ Обычное сообщение - уведомляем UI
  }
  
  Future<void> _handleInvite(Map<String, dynamic> invite, String from) async {
    LoggerService.log('👥 INVITE handler started');
    LoggerService.log('👥 Invite data: $invite');
    
    final contactEmail = invite['email'] as String;
    final contactPubKey = invite['pubkey'] as String;
    final expectedFingerprint = invite['fingerprint'] as String?;
    final contactNickname = invite['nickname'] as String?; // ✅ Никнейм из инвайта
    
    LoggerService.log('👥 Contact email: $contactEmail');
    LoggerService.log('👥 Contact pubkey length: ${contactPubKey.length}');
    LoggerService.log('👥 Contact nickname: ${contactNickname ?? "(none)"}');
    LoggerService.log('👥 From: $from');
    
    if (from != contactEmail) {
      LoggerService.log('❌ WARNING: from ($from) != contactEmail ($contactEmail), skipping');
      return;
    }
    
    // ✅ Валидация публичного ключа
    LoggerService.log('👥 Validating public key...');
    if (!CryptoService.isValidPublicKey(contactPubKey)) {
      LoggerService.log('❌ Invalid public key format, skipping');
      return;
    }
    LoggerService.log('👥 ✅ Public key is valid');
    
    // 🔒 ПРОВЕРКА FINGERPRINT (защита от MITM)
    if (expectedFingerprint != null && expectedFingerprint.isNotEmpty) {
      LoggerService.log('👥 Verifying fingerprint...');
      final actualFingerprint = await CryptoService.getEmojiFingerprint(contactPubKey);
      
      if (actualFingerprint != expectedFingerprint) {
        LoggerService.log('❌ MITM ATTACK DETECTED! Fingerprints do not match!');
        LoggerService.log('❌ Expected: $expectedFingerprint');
        LoggerService.log('❌ Actual: $actualFingerprint');
        // НЕ СОХРАНЯЕМ КОНТАКТ!
        return;
      }
      
      LoggerService.log('👥 ✅ Fingerprint verified!');
    } else {
      LoggerService.log('⚠️ No fingerprint in invite (old version?)');
    }
    
    final existing = await StorageService.getContact(accountEmail, contactEmail);
    if (existing != null) {
      LoggerService.log('⚠️ Contact $contactEmail already exists');
      
      // ✅ Обновляем никнейм если пришёл новый
      if (contactNickname != null && contactNickname.isNotEmpty) {
        await StorageService.updateContactNickname(
          accountEmail: accountEmail,
          contactEmail: contactEmail,
          nickname: contactNickname,
        );
        LoggerService.log('👥 ✅ Updated nickname to: $contactNickname');
      }
      
      // Проверяем: если контакт УЖЕ есть, значит это ОТВЕТНЫЙ инвайт!
      // Устанавливаем mutual = true
      if (existing['mutual'] != true) {
        LoggerService.log('👥 This is a reply invite! Setting mutual = true');
        await StorageService.setContactMutual(
          accountEmail: accountEmail,
          contactEmail: contactEmail,
        );
        LoggerService.log('✅ Contact $contactEmail is now mutual!');
        
        // Уведомляем UI что статус изменился
        _notifyUI();
      } else {
        LoggerService.log('👥 Contact already mutual, skipping');
      }
      
      return;
    }
    
    LoggerService.log('💾 Saving contact to DB...');
    await StorageService.saveContact(
      accountEmail: accountEmail,
      contactEmail: contactEmail,
      publicKey: contactPubKey,
      nickname: contactNickname, // ✅ Сохраняем никнейм
    );
    
    LoggerService.log('✅ Contact $contactEmail saved successfully with nickname: ${contactNickname ?? "(none)"}');
    
    // 🔥 АВТОМАТИЧЕСКИ ОТПРАВЛЯЕМ ОТВЕТНЫЙ ИНВАЙТ
    if (_sendInviteCallback != null) {
      LoggerService.log('👥 Sending automatic reply invite to $contactEmail...');
      try {
        // ВАЖНО: Сначала отправляем, ПОТОМ ставим mutual
        await _sendInviteCallback!(contactEmail, contactPubKey);
        LoggerService.log('👥 ✅ Reply invite sent successfully!');
        
        // ✅ Отправка успешна → ставим mutual = true
        await StorageService.setContactMutual(
          accountEmail: accountEmail,
          contactEmail: contactEmail,
        );
        LoggerService.log('👥 ✅ Contact $contactEmail set as mutual after successful send!');
        
      } catch (e) {
        LoggerService.log('👥 ❌ Failed to send reply invite: $e');
        
        // ✅ Отмечаем что попытка была (защита от спама)
        await StorageService.markInviteSent(
          accountEmail: accountEmail,
          contactEmail: contactEmail,
        );
        LoggerService.log('👥 ⚠️ Contact saved with invite_sent = true (will not retry)');
        // Контакт сохранён с mutual = false, invite_sent = true
        // НЕ будем пытаться снова (защита от спама)
      }
    } else {
      LoggerService.log('👥 ⚠️ Send invite callback not set, skipping reply');
    }
    
    // ВАЖНО: Уведомляем UI что контакт добавлен
    _notifyUI();
  }
  
  Future<void> _handleReadReceipt(Map<String, dynamic> receipt, String from) async {
    // ✅ Поддержка батчинга: message_ids (массив) или original_message_id (одиночный)
    final messageIds = receipt['message_ids'] as List<dynamic>?;
    final singleMessageId = receipt['original_message_id'] as String?;
    
    List<String> idsToProcess = [];
    
    if (messageIds != null && messageIds.isNotEmpty) {
      // Батчинг: массив Message-IDs
      idsToProcess = messageIds.map((id) => id.toString()).toList();
      LoggerService.log('📖 Batched read receipt for ${idsToProcess.length} messages from=$from');
    } else if (singleMessageId != null && singleMessageId.isNotEmpty) {
      // Старый формат: одиночный Message-ID
      idsToProcess = [singleMessageId];
      LoggerService.log('📖 Read receipt for message_id=$singleMessageId from=$from');
    } else {
      LoggerService.log('📖 ⚠️ Read receipt without message_ids or original_message_id, skipping');
      return;
    }
    
    // Обновляем статус для всех Message-IDs
    final updatedIds = <String>[];
    for (final messageId in idsToProcess) {
      final success = await StorageService.updateMessageStatus(
        accountEmail, 
        messageId, 
        'read'
      );
      
      if (success) {
        updatedIds.add(messageId);
        LoggerService.log('📖 ✅ Message $messageId marked as READ');
      } else {
        LoggerService.log('📖 ⚠️ Message $messageId not found in DB');
      }
    }
    
    // ✅ Уведомляем UI об обновлении статуса (БЕЗ перезагрузки!)
    if (updatedIds.isNotEmpty) {
      _notifyStatusUpdate(updatedIds, 'read');
    }
  }
  
  /// Отправка read receipt для контакта (вызывается из UI)
  Future<void> sendReadReceipts({
    required String contactEmail,
    required Function(String toEmail, Map<String, String> encrypted) sendMessageCallback,
  }) async {
    // ✅ Защита от параллельных вызовов (race condition)
    if (_sendingReadReceipts[contactEmail] == true) {
      LoggerService.log('📖 Already sending read receipts for $contactEmail, skipping');
      return;
    }
    
    _sendingReadReceipts[contactEmail] = true;
    
    try {
      LoggerService.log('📖 MessageService: Checking for unread messages from $contactEmail');
      
      // ✅ Загружаем ТОЛЬКО сообщения для которых НЕ отправлен read receipt
      final unread = await StorageService.getUnreadMessagesForReceipt(accountEmail, contactEmail);
      
      if (unread.isEmpty) {
        LoggerService.log('📖 No unread messages to send receipts for');
        return;
      }
      
      LoggerService.log('📖 Found ${unread.length} unread messages (receipt not sent), sending read receipts...');
      
      // ✅ БАТЧИНГ: Собираем все Message-IDs в один массив
      final messageIds = unread.map((m) => m['message_id'] as String).toList();
      
      // ✅ КРИТИЧЕСКИ ВАЖНО: Помечаем СРАЗУ (защита от race condition)
      // Если пометить ПОСЛЕ отправки → за время SMTP (~1 сек) придут callbacks
      // и они увидят старые данные → отправят дубликаты!
      for (final messageId in messageIds) {
        await StorageService.markReadReceiptSent(accountEmail, messageId);
      }
      LoggerService.log('📖 ✅ Marked ${messageIds.length} messages as read_receipt_sent (before sending)');
      
      try {
        // RFC 3798 MDN формат с батчингом (как в Delta Chat)
        final receipt = jsonEncode({
          'type': 'read_receipt',
          'message_ids': messageIds, // ✅ Массив Message-IDs
          'disposition': 'displayed',
        });
        
        // Шифруем и отправляем через callback
        final contact = await StorageService.getContact(accountEmail, contactEmail);
        if (contact == null) {
          LoggerService.log('📖 ⚠️ Contact $contactEmail not found, skipping');
          return;
        }
        
        final contactPubKeyHex = contact['publicKey'] as String;
        final encrypted = await CryptoService.encryptMessage(
          plaintext: receipt,
          recipientPubKeyHex: contactPubKeyHex,
          senderEmail: accountEmail,
          recipientEmail: contactEmail,
        );
        
        // Отправляем через callback (ChatService.sendMessage)
        await sendMessageCallback(contactEmail, encrypted);
        
        LoggerService.log('📖 ✅ Sent batched read receipt for ${messageIds.length} messages');
      } catch (e) {
        LoggerService.log('📖 ❌ Failed to send batched read receipt: $e');
        // ⚠️ Флаги УЖЕ установлены (перед отправкой)
        // Если ошибка → пользователь увидит что сообщения прочитаны (локально)
        // но получатель не получит уведомление (это OK, не критично)
      }
    } finally {
      // ✅ Снимаем флаг в любом случае (даже если ошибка)
      _sendingReadReceipts[contactEmail] = false;
    }
  }
  
  /// Уведомление UI об обновлении статуса сообщений
  void _notifyStatusUpdate(List<String> uids, String status) {
    LoggerService.log('MessageService: Notifying ${_statusUpdateCallbacks.length} status update callbacks for ${uids.length} messages');
    for (final callback in _statusUpdateCallbacks) {
      try {
        callback(uids, status);
      } catch (e) {
        LoggerService.log('MessageService: Status update callback error: $e');
      }
    }
  }
  
  Future<void> _handleTextMessage(Map<String, dynamic> message, String from, int uid, String messageId) async {
    LoggerService.log('💬 TEXT message handler started');
    LoggerService.log('💬 Message data: $message');
    LoggerService.log('💬 From: $from, UID: $uid, Message-ID: $messageId');
    
    // ВАЖНО: Message-ID ОБЯЗАТЕЛЕН для сохранения!
    if (messageId.isEmpty) {
      LoggerService.log('❌ No Message-ID, cannot save message!');
      return;
    }
    
    // ✅ СИНХРОНИЗАЦИЯ НИКНЕЙМА: Извлекаем из сообщения и обновляем в БД
    final senderNickname = message['sender_nickname'] as String?;
    final senderEmail = message['sender_email'] as String?;
    
    if (senderNickname != null && senderNickname.isNotEmpty) {
      LoggerService.log('💬 ✅ Sender nickname in message: "$senderNickname"');
      
      // Обновляем никнейм контакта в БД
      try {
        await StorageService.updateContactNickname(
          accountEmail: accountEmail,
          contactEmail: from,
          nickname: senderNickname,
        );
        LoggerService.log('💬 ✅ Contact nickname updated to: "$senderNickname"');
      } catch (e) {
        LoggerService.log('💬 ⚠️ Failed to update contact nickname: $e');
        // Не критично, продолжаем
      }
    } else {
      LoggerService.log('💬 No sender_nickname in message');
    }
    
    await StorageService.saveMessage(
      messageId: messageId,
      accountEmail: accountEmail,
      contactEmail: from,
      text: message['text'],
      sent: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    
    LoggerService.log('✅ Text message saved to DB with Message-ID: $messageId');
  }
  
  /// Обновление серверного Message-ID (из BCC копии)
  Future<void> _updateServerMessageId(String localMessageId, String serverMessageId) async {
    // Обновляем message_id в БД
    await StorageService.updateServerMessageId(accountEmail, localMessageId, serverMessageId);
    
    // Добавляем серверный Message-ID в processed (для дедупликации)
    await StorageService.addProcessedMessageId(accountEmail, serverMessageId);
  }
  
  /// Уведомление UI
  void _notifyUI() {
    LoggerService.log('MessageService: Notifying ${_uiCallbacks.length} UI callbacks');
    for (final callback in _uiCallbacks) {
      try {
        callback();
      } catch (e) {
        LoggerService.log('MessageService: UI callback error: $e');
      }
    }
  }
}
