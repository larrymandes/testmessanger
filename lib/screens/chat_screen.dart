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

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _sendReadReceipts();
    
    // Слушаем новые сообщения
    widget.emailService.listenForNewMessages().listen((_) {
      _loadMessages();
      _sendReadReceipts();
    });
  }

  Future<void> _loadMessages() async {
    final messages = await StorageService.getMessages(
      widget.myEmail,
      widget.contactEmail,
    );

    final chatMessages = messages.map((msg) => _createMessage(msg)).toList();
    _chatController.setMessages(chatMessages);
    
    if (mounted) {
      setState(() {});
    }
  }

  Message _createMessage(Map<String, dynamic> msg) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(msg['timestamp']);
    
    return TextMessage(
      id: msg['uid'] ?? msg['id'].toString(),
      authorId: msg['sent'] ? widget.myEmail : widget.contactEmail,
      createdAt: timestamp,
      text: msg['text'],
      sentAt: msg['status'] == 'sent' || msg['status'] == 'read' ? timestamp : null,
      seenAt: msg['status'] == 'read' ? timestamp : null,
      metadata: msg['status'] == 'sending' ? {'sending': true} : null,
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
      print('Send read receipt error: $e');
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

      // Отправляем
      await widget.emailService.sendMessage(
        toEmail: widget.contactEmail,
        encryptedPayload: jsonEncode(encrypted),
      );

      // Сохраняем в БД
      await StorageService.saveMessage(
        accountEmail: widget.myEmail,
        contactEmail: widget.contactEmail,
        text: text,
        sent: true,
        timestamp: now.millisecondsSinceEpoch,
        status: 'sent',
        uid: messageUID,
      );

      // Обновляем статус на "отправлено"
      final updatedMessage = chatMessage.copyWith(
        sentAt: now,
        metadata: null,
      );
      _chatController.updateMessage(chatMessage, updatedMessage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Отправлено'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Send error: $e');
      
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
            action: SnackBarAction(
              label: 'Копировать',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'Ошибка отправки: $e'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ошибка скопирована'),
                    duration: Duration(seconds: 2),
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
    _chatController.dispose();
    super.dispose();
  }
}
