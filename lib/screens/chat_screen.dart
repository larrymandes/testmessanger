import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cryptography/cryptography.dart';
import 'dart:convert';
import '../services/email_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final String contactEmail;
  final String contactPublicKey;
  final String myEmail;
  final SimpleKeyPair myKeyPair;
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
  final List<types.Message> _messages = [];
  late final types.User _user;

  @override
  void initState() {
    super.initState();
    _user = types.User(id: widget.myEmail);
    _loadMessages();
    _sendReadReceipts();
  }

  Future<void> _loadMessages() async {
    final messages = await StorageService.getMessages(
      widget.myEmail,
      widget.contactEmail,
    );

    setState(() {
      _messages.clear();
      for (final msg in messages) {
        _messages.add(_createMessage(msg));
      }
    });
  }

  types.Message _createMessage(Map<String, dynamic> msg) {
    return types.TextMessage(
      author: msg['sent']
          ? _user
          : types.User(id: widget.contactEmail),
      createdAt: msg['timestamp'],
      id: msg['uid'] ?? msg['id'].toString(),
      text: msg['text'],
      status: msg['sent'] ? _parseStatus(msg['status']) : null,
    );
  }

  types.Status? _parseStatus(String? status) {
    switch (status) {
      case 'sending':
        return types.Status.sending;
      case 'sent':
        return types.Status.sent;
      case 'read':
        return types.Status.seen;
      case 'error':
        return types.Status.error;
      default:
        return types.Status.sent;
    }
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

  void _handleSendPressed(types.PartialText message) async {
    final messageUID = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
    
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: messageUID,
      text: message.text,
      status: types.Status.sending,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    try {
      // Создаём сообщение с UID
      final messageWithUID = jsonEncode({
        'text': message.text,
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
        text: message.text,
        sent: true,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'sent',
        uid: messageUID,
      );

      // Обновляем статус на "отправлено"
      final index = _messages.indexWhere((m) => m.id == textMessage.id);
      if (index != -1) {
        setState(() {
          _messages[index] = textMessage.copyWith(status: types.Status.sent);
        });
      }
    } catch (e) {
      print('Send error: $e');
      
      // Обновляем статус на "ошибка"
      final index = _messages.indexWhere((m) => m.id == textMessage.id);
      if (index != -1) {
        setState(() {
          _messages[index] = textMessage.copyWith(status: types.Status.error);
        });
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
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: DefaultChatTheme(
          backgroundColor: const Color(0xFF0e1621),
          primaryColor: const Color(0xFF2b5278),
          secondaryColor: const Color(0xFF242f3d),
          inputBackgroundColor: const Color(0xFF242f3d),
          inputTextColor: Colors.white,
          receivedMessageBodyTextStyle: const TextStyle(color: Colors.white),
          sentMessageBodyTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
