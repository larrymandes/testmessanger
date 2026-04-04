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
    
    // Пропускаем свои BCC копии
    if (from == accountEmail) {
      LoggerService.log('📤 BCC copy from myself, skipping');
      await StorageService.addProcessedUID(accountEmail, uid);
      if (messageId.isNotEmpty) {
        await StorageService.addProcessedMessageId(accountEmail, messageId);
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
      await StorageService.addProcessedUID(accountEmail, uid);
      if (messageId.isNotEmpty) {
        await StorageService.addProcessedMessageId(accountEmail, messageId);
      }
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
      await StorageService.addProcessedUID(accountEmail, uid);
      if (messageId.isNotEmpty) {
        await StorageService.addProcessedMessageId(accountEmail, messageId);
      }
      return;
    }
    
    // Обрабатываем по типу
    try {
      final parsed = jsonDecode(plaintext);
      LoggerService.log('✅ Plaintext JSON parsed');
      LoggerService.log('📋 Type: ${parsed['type']}');
      LoggerService.log('📋 Keys: ${parsed.keys.toList()}');
      
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
    
    // Помечаем как обработанное
    await StorageService.addProcessedUID(accountEmail, uid);
    if (messageId.isNotEmpty) {
      await StorageService.addProcessedMessageId(accountEmail, messageId);
    }
    
    LoggerService.log('✅ Message UID=$uid processed');
    LoggerService.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
  
  Future<void> _handleInvite(Map<String, dynamic> invite, String from) async {
    LoggerService.log('👥 INVITE handler started');
    LoggerService.log('👥 Invite data: $invite');
    
    final contactEmail = invite['email'] as String;
    final contactPubKey = invite['pubkey'] as String;
    
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
    final success = await StorageService.updateMessageStatusByMessageId(
      accountEmail, 
      originalMessageId, 
      'read'
    );
    
    if (success) {
      LoggerService.log('📖 ✅ Message $originalMessageId marked as READ');
      // Уведомляем UI об обновлении статуса
      _notifyStatusUpdate([originalMessageId], 'read');
    } else {
      LoggerService.log('📖 ⚠️ Message $originalMessageId not found in DB');
    }
  }
  
  /// Отправка read receipt для контакта (вызывается из UI)
  Future<void> sendReadReceipts({
    required String contactEmail,
    required Function(String toEmail, String payload) sendMessageCallback,
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
        await sendMessageCallback(contactEmail, jsonEncode(encrypted));
        
        // Помечаем что read receipt отправлен
        await StorageService.markMessageReadSentByMessageId(accountEmail, messageId);
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
    LoggerService.log('💬 From: $from, UID: $uid');
    
    await StorageService.saveMessage(
      accountEmail: accountEmail,
      contactEmail: from,
      text: message['text'],
      sent: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      uid: message['uid'],
      messageId: messageId.isNotEmpty ? messageId : null,
    );
    
    LoggerService.log('✅ Text message saved to DB');
    
    // ВАЖНО: Чистим дубликаты сразу после сохранения
    final deleted = await StorageService.removeDuplicateMessages(accountEmail, from);
    if (deleted > 0) {
      LoggerService.log('🧹 Removed $deleted duplicate messages for $from');
    }
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
