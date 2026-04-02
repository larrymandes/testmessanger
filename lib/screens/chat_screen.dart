import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'dart:convert';
import '../services/chat_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/logger_service.dart';

class ChatScreen extends StatefulWidget {
  final String contactEmail;
  final String contactPublicKey;
  final ChatService chatService;

  const ChatScreen({
    super.key,
    required this.contactEmail,
    required this.contactPublicKey,
    required this.chatService,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatController = InMemoryChatController();
  late Function() _messageCallback; // Сохраняем ссылку на callback

  @override
  void initState() {
    super.initState();
    LoggerService.log('ChatScreen: initState for ${widget.contactEmail}');
    
    // Создаём callback и регистрируем
    _messageCallback = () {
      LoggerService.log('ChatScreen: Callback triggered for ${widget.contactEmail}!');
      if (mounted) {
        LoggerService.log('ChatScreen: Loading messages...');
        _loadMessages();
        _sendReadReceipts();
      } else {
        LoggerService.log('ChatScreen: NOT mounted, skipping');
      }
    };
    
    widget.chatService.addUICallback(_messageCallback);
    LoggerService.log('ChatScreen: Callback registered');
    
    // Загружаем сообщения из БД
    _loadMessages();
    _sendReadReceipts();
  }

  Future<void> _loadMessages() async {
    final startTime = DateTime.now();
    LoggerService.log('ChatScreen: _loadMessages() called at ${startTime.hour}:${startTime.minute}:${startTime.second}.${startTime.millisecond}');
    
    final messages = await StorageService.getMessages(
      widget.chatService.email,
      widget.contactEmail,
    );
    
    final afterDbTime = DateTime.now();
    final dbDuration = afterDbTime.difference(startTime).inMilliseconds;
    LoggerService.log('ChatScreen: Loaded ${messages.length} messages from DB in ${dbDuration}ms');

    // Сортируем по timestamp (новые внизу для чата)
    messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    
    final chatMessages = messages.map((msg) => _createMessage(msg)).toList();
    LoggerService.log('ChatScreen: Created ${chatMessages.length} chat messages');
    
    if (mounted) {
      LoggerService.log('ChatScreen: Calling setState to update UI');
      setState(() {
        _chatController.setMessages(chatMessages);
      });
      
      final endTime = DateTime.now();
      final totalDuration = endTime.difference(startTime).inMilliseconds;
      LoggerService.log('ChatScreen: ✅ UI updated in ${totalDuration}ms total (DB: ${dbDuration}ms, UI: ${totalDuration - dbDuration}ms)');
    } else {
      LoggerService.log('ChatScreen: NOT mounted, cannot update UI');
    }
  }

  Message _createMessage(Map<String, dynamic> msg) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(msg['timestamp']);
    final isSent = msg['sent'] == 1 || msg['sent'] == true;
    final status = msg['status'] ?? 'sent';
    final uid = msg['uid'] ?? msg['id'].toString();
    
    // Логируем статус для отладки read receipts
    if (isSent) {
      LoggerService.log('ChatScreen: Message $uid status="$status" (sent=${isSent})');
    }
    
    return TextMessage(
      id: uid,
      authorId: isSent ? widget.chatService.email : widget.contactEmail,
      createdAt: timestamp,
      text: msg['text'],
      // Отправленные: показываем галочки
      sentAt: isSent && status != 'sending' ? timestamp : null,
      seenAt: isSent && status == 'read' ? timestamp : null,
      metadata: status == 'sending' ? {'sending': true} : null,
    );
  }

  Future<void> _sendReadReceipts() async {
    // Находим непрочитанные входящие сообщения
    final messages = await StorageService.getMessages(
      widget.chatService.email,
      widget.contactEmail,
    );

    final unread = messages.where((m) => 
      !m['sent'] && !m['readSent'] && m['uid'] != null
    ).toList();

    if (unread.isEmpty) return;
    
    LoggerService.log('ChatScreen: Sending ${unread.length} read receipts');

    // Батчинг: отправляем все UID одним сообщением
    final uids = unread.map((m) => m['uid']).toList();
    
    try {
      final receipt = jsonEncode({
        'type': 'read_receipt',
        'message_uids': uids, // Массив вместо одного UID
      });

      final encrypted = await CryptoService.encryptMessage(
        plaintext: receipt,
        recipientPubKeyHex: widget.contactPublicKey,
        senderEmail: widget.chatService.email,
        recipientEmail: widget.contactEmail,
      );

      await widget.chatService.sendMessage(
        toEmail: widget.contactEmail,
        encryptedPayload: jsonEncode(encrypted),
      );
      
      // Помечаем все как отправленные
      for (final msg in unread) {
        await StorageService.markMessageReadSent(widget.chatService.email, msg['uid']);
      }
      
      LoggerService.log('ChatScreen: ✅ ${unread.length} read receipts sent');
    } catch (e) {
      LoggerService.log('Send read receipts error: $e');
    }
  }

  void _handleSendPressed(String text) async {
    final messageUID = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
    final now = DateTime.now().toUtc();
    
    // Добавляем сообщение с статусом "отправляется"
    final chatMessage = TextMessage(
      id: messageUID,
      authorId: widget.chatService.email,
      createdAt: now,
      text: text,
      metadata: {'sending': true},
    );

    _chatController.insertMessage(chatMessage);

    try {
      // ВАЖНО: Сохраняем в БД СРАЗУ (до отправки) чтобы BCC не опередила
      await StorageService.saveMessage(
        accountEmail: widget.chatService.email,
        contactEmail: widget.contactEmail,
        text: text,
        sent: true,
        timestamp: now.millisecondsSinceEpoch,
        status: 'sending',
        uid: messageUID,
        messageId: null, // Message-ID пока нет
      );
      
      // Создаём сообщение с UID
      final messageWithUID = jsonEncode({
        'text': text,
        'uid': messageUID,
      });

      // Шифруем
      final encrypted = await CryptoService.encryptMessage(
        plaintext: messageWithUID,
        recipientPubKeyHex: widget.contactPublicKey,
        senderEmail: widget.chatService.email,
        recipientEmail: widget.contactEmail,
      );

      // Отправляем и получаем Message-ID
      final messageId = await widget.chatService.sendMessage(
        toEmail: widget.contactEmail,
        encryptedPayload: jsonEncode(encrypted),
      );

      // Обновляем статус на "sent" и добавляем Message-ID
      await StorageService.updateMessageStatus(widget.chatService.email, messageUID, 'sent');
      
      // Сохраняем Message-ID как обработанный (чтобы не обрабатывать свою копию)
      await StorageService.addProcessedMessageId(widget.chatService.email, messageId);

      // Обновляем статус на "отправлено"
      final updatedMessage = chatMessage.copyWith(
        sentAt: now,
        metadata: null,
      );
      _chatController.updateMessage(chatMessage, updatedMessage);
      
      // Перезагружаем сообщения из БД чтобы синхронизировать
      await _loadMessages();
    } catch (e) {
      LoggerService.log('Send error: $e');
      
      // Обновляем статус на "ошибка"
      await StorageService.updateMessageStatus(widget.chatService.email, messageUID, 'error');
      
      final updatedMessage = chatMessage.copyWith(
        failedAt: now,
        metadata: null,
      );
      _chatController.updateMessage(chatMessage, updatedMessage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Ошибка отправки: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Копировать',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'Ошибка отправки: $e'));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ошибка скопирована'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contactEmail),
            FutureBuilder<String>(
              future: CryptoService.getFingerprint(widget.contactPublicKey),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Chat(
        chatController: _chatController,
        currentUserId: widget.chatService.email,
        onMessageSend: _handleSendPressed,
        onMessageLongPress: _handleMessageLongPress, // Добавляем long press
        resolveUser: (userId) async {
          return User(
            id: userId,
            name: userId == widget.chatService.email ? 'Вы' : widget.contactEmail,
          );
        },
        theme: ChatTheme.dark().copyWith(
          colors: ChatTheme.dark().colors.copyWith(
            primary: const Color(0xFF2b5278),
            surface: const Color(0xFF0e1621),
            onSurface: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleMessageLongPress(Message message) {
    // Копируем текст сообщения
    if (message is TextMessage) {
      Clipboard.setData(ClipboardData(text: message.text));
      
      // Показываем уведомление
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Текст скопирован'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      LoggerService.log('Message copied: ${message.text}');
    }
  }

  @override
  void dispose() {
    LoggerService.log('ChatScreen: dispose() - removing callback');
    widget.chatService.removeUICallback(_messageCallback);
    _chatController.dispose();
    super.dispose();
  }
}
