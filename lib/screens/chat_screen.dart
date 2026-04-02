import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PublicKey, PrivateKey;
import 'dart:convert';
import 'dart:math';
import '../services/email_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final String contactEmail;
  final String contactPublicKey;
  final String myEmail;
  final AsymmetricKeyPair<PublicKey, PrivateKey> myKeyPair;
  final String myPublicKeyHex;
  final EmailService emailService;

  const ChatScreen({
    super.key,
    required this.contactEmail,
    required this.contactPublicKey,
    required this.myEmail,
    required this.myKeyPair,
    required this.myPublicKeyHex,
    required this.emailService,
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
    _loadMessages();
    _sendReadReceipts();
    
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
    
    widget.emailService.setNewMessageCallback(_messageCallback);
    LoggerService.log('ChatScreen: Callback registered');
  }

  Future<void> _loadMessages() async {
    LoggerService.log('ChatScreen: _loadMessages() called');
    final messages = await StorageService.getMessages(
      widget.myEmail,
      widget.contactEmail,
    );
    LoggerService.log('ChatScreen: Loaded ${messages.length} messages from DB');

    // Сортируем по timestamp (новые внизу для чата)
    messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    
    final chatMessages = messages.map((msg) => _createMessage(msg)).toList();
    LoggerService.log('ChatScreen: Created ${chatMessages.length} chat messages');
    
    if (mounted) {
      LoggerService.log('ChatScreen: Calling setState to update UI');
      setState(() {
        _chatController.setMessages(chatMessages);
      });
      LoggerService.log('ChatScreen: UI updated!');
    } else {
      LoggerService.log('ChatScreen: NOT mounted, cannot update UI');
    }
  }

  Message _createMessage(Map<String, dynamic> msg) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(msg['timestamp']);
    final isSent = msg['sent'] == 1 || msg['sent'] == true;
    final status = msg['status'] ?? 'sent';
    
    return TextMessage(
      id: msg['uid'] ?? msg['id'].toString(),
      authorId: isSent ? widget.myEmail : widget.contactEmail,
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
      widget.myEmail,
      widget.contactEmail,
    );

    final unread = messages.where((m) => 
      !m['sent'] && !m['readSent'] && m['uid'] != null
    ).toList();

    for (final msg in unread) {
      await _sendReadReceipt(msg['uid']);
      await StorageService.markMessageReadSent(widget.myEmail, msg['uid']);
    }
  }

  Future<void> _sendReadReceipt(String messageUID) async {
    try {
      final receipt = jsonEncode({
        'type': 'read_receipt',
        'message_uid': messageUID,
      });

      final encrypted = await CryptoService.encryptMessage(
        plaintext: receipt,
        recipientPubKeyHex: widget.contactPublicKey,
        senderEmail: widget.myEmail,
        recipientEmail: widget.contactEmail,
      );

      await widget.emailService.sendMessage(
        toEmail: widget.contactEmail,
        encryptedPayload: jsonEncode(encrypted),
      );
    } catch (e) {
      LoggerService.log('Send read receipt error: $e');
    }
  }

  void _handleSendPressed(String text) async {
    final messageUID = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
    final now = DateTime.now().toUtc();
    
    // Добавляем сообщение с статусом "отправляется"
    final chatMessage = TextMessage(
      id: messageUID,
      authorId: widget.myEmail,
      createdAt: now,
      text: text,
      metadata: {'sending': true},
    );

    _chatController.insertMessage(chatMessage);

    try {
      // Создаём сообщение с UID
      final messageWithUID = jsonEncode({
        'text': text,
        'uid': messageUID,
      });

      // Шифруем
      final encrypted = await CryptoService.encryptMessage(
        plaintext: messageWithUID,
        recipientPubKeyHex: widget.contactPublicKey,
        senderEmail: widget.myEmail,
        recipientEmail: widget.contactEmail,
      );

      // Отправляем и получаем Message-ID
      final messageId = await widget.emailService.sendMessage(
        toEmail: widget.contactEmail,
        encryptedPayload: jsonEncode(encrypted),
      );

      // Сохраняем в БД с Message-ID
      await StorageService.saveMessage(
        accountEmail: widget.myEmail,
        contactEmail: widget.contactEmail,
        text: text,
        sent: true,
        timestamp: now.millisecondsSinceEpoch,
        status: 'sent',
        uid: messageUID,
        messageId: messageId,
      );
      
      // Сохраняем Message-ID как обработанный (чтобы не обрабатывать свою копию)
      await StorageService.addProcessedMessageId(widget.myEmail, messageId);

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
        currentUserId: widget.myEmail,
        onMessageSend: _handleSendPressed,
        resolveUser: (userId) async {
          return User(
            id: userId,
            name: userId == widget.myEmail ? 'Вы' : widget.contactEmail,
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

  @override
  void dispose() {
    LoggerService.log('ChatScreen: dispose() - removing callback');
    // Удаляем callback при закрытии
    widget.emailService.removeNewMessageCallback(_messageCallback);
    _chatController.dispose();
    super.dispose();
  }
}
