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
  
  /// Обработка новых писем (вызывается из EmailService)
  Future<void> processNewMessages(List<MimeMessage> messages) async {
    LoggerService.log('MessageService: Processing ${messages.length} new messages');
    
    int processed = 0;
    for (final message in messages) {
      try {
        await _processMessage(message);
        processed++;
      } catch (e) {
        LoggerService.log('MessageService: Error processing message: $e');
      }
    }
    
    LoggerService.log('MessageService: Processed $processed/${messages.length} messages');
    
    // Уведомляем UI
    if (processed > 0) {
      _notifyUI();
    }
  }
  
  /// Обработка одного письма
  Future<void> _processMessage(MimeMessage mimeMessage) async {
    final from = mimeMessage.from?.first?.email ?? '';
    final uid = mimeMessage.uid ?? 0;
    final messageId = mimeMessage.decodeHeaderValue('message-id') ?? '';
    
    LoggerService.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    LoggerService.log('📨 Processing message UID=$uid from $from');
    
    if (uid == 0) {
      LoggerService.log('❌ UID is 0, skipping');
      return;
    }
    
    // ВАЖНО: Проверяем что UID ещё НЕ обработан (защита от дублирования)
    final alreadyProcessed = await StorageService.isUIDProcessed(accountEmail, uid);
    if (alreadyProcessed) {
      LoggerService.log('⏭️ UID=$uid already processed, skipping');
      return;
    }
    
    // ВАЖНО: Проверяем Message-ID (защита от дублирования при повторном fetch)
    if (messageId.isNotEmpty) {
      final messageIdProcessed = await StorageService.isMessageIdProcessed(accountEmail, messageId);
      if (messageIdProcessed) {
        LoggerService.log('⏭️ Message-ID=$messageId already processed, skipping');
        // Помечаем UID тоже (на всякий случай)
        await StorageService.addProcessedUID(accountEmail, uid);
        return;
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
        
        return; // ✅ Готово! Не нужно расшифровывать
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
      
      return;
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
      return;
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
      return;
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
  }
  
  Future<void> _handleInvite(Map<String, dynamic> invite, String from) async {
    LoggerService.log('👥 INVITE handler started');
    LoggerService.log('👥 Invite data: $invite');
    
    final contactEmail = invite['email'] as String;
    final contactPubKey = invite['pubkey'] as String;
    final expectedFingerprint = invite['fingerprint'] as String?;
    
    LoggerService.log('👥 Contact email: $contactEmail');
    LoggerService.log('👥 Contact pubkey length: ${contactPubKey.length}');
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
      LoggerService.log('⚠️ Contact $contactEmail already exists, skipping');
      return;
    }
    
    LoggerService.log('💾 Saving contact to DB...');
    await StorageService.saveContact(
      accountEmail: accountEmail,
      contactEmail: contactEmail,
      publicKey: contactPubKey,
    );
    
    LoggerService.log('✅ Contact $contactEmail saved successfully!');
    
    // ВАЖНО: Уведомляем UI что контакт добавлен
    _notifyUI();
  }
  
  Future<void> _handleReadReceipt(Map<String, dynamic> receipt, String from) async {
    // RFC 3798 MDN формат: Original-Message-ID
    final originalMessageId = receipt['original_message_id'] as String?;
    
    if (originalMessageId == null || originalMessageId.isEmpty) {
      LoggerService.log('📖 ⚠️ Read receipt without original_message_id, skipping');
      return;
    }
    
    LoggerService.log('📖 Read receipt for message_id=$originalMessageId from=$from');
    
    // Обновляем статус по message_id
    final success = await StorageService.updateMessageStatus(
      accountEmail, 
      originalMessageId, 
      'read'
    );
    
    if (success) {
      LoggerService.log('📖 ✅ Message $originalMessageId marked as READ');
      // ✅ Уведомляем UI об обновлении статуса (БЕЗ перезагрузки!)
      // Status callback обновит сообщение в памяти, анимация не проиграется
      _notifyStatusUpdate([originalMessageId], 'read');
    } else {
      LoggerService.log('📖 ⚠️ Message $originalMessageId not found in DB');
    }
  }
  
  /// Отправка read receipt для контакта (вызывается из UI)
  Future<void> sendReadReceipts({
    required String contactEmail,
    required Function(String toEmail, Map<String, String> encrypted) sendMessageCallback,
  }) async {
    LoggerService.log('📖 MessageService: Checking for unread messages from $contactEmail');
    
    // Загружаем сообщения от контакта
    final messages = await StorageService.getMessages(accountEmail, contactEmail);
    
    // Фильтруем: не отправленные нами, не прочитанные, с message_id
    final unread = messages.where((m) {
      final sent = m['sent'] as bool;
      final readSent = m['readSent'] as bool;
      final messageId = m['message_id'] as String?;
      return !sent && !readSent && messageId != null && messageId.isNotEmpty;
    }).toList();
    
    if (unread.isEmpty) {
      LoggerService.log('📖 No unread messages to send receipts for');
      return;
    }
    
    LoggerService.log('📖 Found ${unread.length} unread messages, sending read receipts...');
    
    // Отправляем read receipt для каждого сообщения
    int sent = 0;
    for (final msg in unread) {
      final messageId = msg['message_id'] as String;
      
      try {
        // RFC 3798 MDN формат (упрощённый)
        final receipt = jsonEncode({
          'type': 'read_receipt',
          'original_message_id': messageId,
          'disposition': 'displayed', // RFC 3798: displayed, processed, deleted, etc.
        });
        
        // Шифруем и отправляем через callback
        final contact = await StorageService.getContact(accountEmail, contactEmail);
        if (contact == null) {
          LoggerService.log('📖 ⚠️ Contact $contactEmail not found, skipping');
          continue;
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
        
        // Помечаем что read receipt отправлен
        await StorageService.markMessageReadSent(accountEmail, messageId);
        sent++;
        
        LoggerService.log('📖 ✅ Read receipt sent for message_id=$messageId');
      } catch (e) {
        LoggerService.log('📖 ❌ Failed to send read receipt for $messageId: $e');
      }
    }
    
    LoggerService.log('📖 ✅ Sent $sent/${unread.length} read receipts');
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
