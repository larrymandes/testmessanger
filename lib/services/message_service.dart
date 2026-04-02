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
    
    if (uid == 0) return;
    
    // Пропускаем свои BCC копии
    if (from == accountEmail) {
      LoggerService.log('UID=$uid: BCC copy from myself, skipping');
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
    
    LoggerService.log('Processing UID=$uid from $from');
    
    // Убираем пробелы
    body = body.replaceAll(RegExp(r'\s+'), '');
    
    // Парсим JSON
    Map<String, dynamic> encrypted;
    try {
      encrypted = jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
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
      LoggerService.log('Decrypted ok');
    } catch (e) {
      LoggerService.log('Decryption failed - skipping');
      await StorageService.addProcessedUID(accountEmail, uid);
      if (messageId.isNotEmpty) {
        await StorageService.addProcessedMessageId(accountEmail, messageId);
      }
      return;
    }
    
    // Обрабатываем по типу
    try {
      final parsed = jsonDecode(plaintext);
      
      if (parsed['type'] == 'invite') {
        await _handleInvite(parsed, from);
      } else if (parsed['type'] == 'read_receipt') {
        await _handleReadReceipt(parsed, from);
      } else if (parsed['text'] != null) {
        await _handleTextMessage(parsed, from, uid, messageId);
      }
    } catch (e) {
      // Старый формат
      await _handleTextMessage({'text': plaintext, 'uid': uid.toString()}, from, uid, messageId);
    }
    
    // Помечаем как обработанное
    await StorageService.addProcessedUID(accountEmail, uid);
    if (messageId.isNotEmpty) {
      await StorageService.addProcessedMessageId(accountEmail, messageId);
    }
  }
  
  Future<void> _handleInvite(Map<String, dynamic> invite, String from) async {
    final contactEmail = invite['email'] as String;
    final contactPubKey = invite['pubkey'] as String;
    
    if (from != contactEmail) {
      LoggerService.log('WARNING: from != contactEmail, skipping');
      return;
    }
    
    final existing = await StorageService.getContact(accountEmail, contactEmail);
    if (existing != null) {
      LoggerService.log('Contact already exists');
      return;
    }
    
    await StorageService.saveContact(
      accountEmail: accountEmail,
      contactEmail: contactEmail,
      publicKey: contactPubKey,
    );
    
    LoggerService.log('Contact $contactEmail saved');
  }
  
  Future<void> _handleReadReceipt(Map<String, dynamic> receipt, String from) async {
    final messageUIDs = receipt['message_uids'] as List<dynamic>?;
    final singleUID = receipt['message_uid'];
    
    final uids = messageUIDs ?? (singleUID != null ? [singleUID] : []);
    
    if (uids.isEmpty) return;
    
    LoggerService.log('📖 Read receipt: ${uids.length} messages from=$from');
    
    int updated = 0;
    for (final uid in uids) {
      final success = await StorageService.updateMessageStatus(accountEmail, uid.toString(), 'read');
      if (success) updated++;
    }
    
    LoggerService.log('📖 Updated $updated/${uids.length} messages to READ');
  }
  
  Future<void> _handleTextMessage(Map<String, dynamic> message, String from, int uid, String messageId) async {
    await StorageService.saveMessage(
      accountEmail: accountEmail,
      contactEmail: from,
      text: message['text'],
      sent: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      uid: message['uid'],
      messageId: messageId.isNotEmpty ? messageId : null,
    );
    
    LoggerService.log('Message saved');
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
