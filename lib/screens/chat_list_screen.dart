import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pointycastle/export.dart';
import '../services/email_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import 'dart:convert';
import 'chat_screen.dart';
import 'qr_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String email;
  final String password;

  const ChatListScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late EmailService _emailService;
  final Map<String, Map<String, dynamic>> _chats = {};
  bool _isLoading = true;
  AsymmetricKeyPair<PublicKey, PrivateKey>? _myKeyPair;
  String? _myPublicKeyHex;

  @override
  void initState() {
    super.initState();
    _emailService = EmailService(
      email: widget.email,
      password: widget.password,
    );
    _initialize();
    
    // Периодическая проверка на случай если IDLE не сработает
    Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _fetchNewMessages();
    });
  }

  Future<void> _initialize() async {
    try {
      // Загружаем или генерируем ключи
      await _loadOrGenerateKeys();
      
      // Загружаем контакты
      await _loadContacts();
      
      // Подключаемся к IMAP
      await _emailService.connectImap();
      
      // Слушаем новые сообщения
      _emailService.listenForNewMessages().listen((_) {
        _fetchNewMessages();
      });
      
      // Получаем новые сообщения
      await _fetchNewMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка подключения: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrGenerateKeys() async {
    final account = await StorageService.getAccount(widget.email);
    
    if (account != null) {
      // Загружаем существующие ключи
      final privateKey = CryptoService.importPrivateKey(account['privateKey']!);
      final publicKey = CryptoService.importPublicKey(account['publicKey']!);
      _myKeyPair = AsymmetricKeyPair<PublicKey, PrivateKey>(publicKey, privateKey);
      _myPublicKeyHex = account['publicKey']!;
    } else {
      // Генерируем новые ключи
      _myKeyPair = await CryptoService.generateKeyPair();
      _myPublicKeyHex = CryptoService.exportPublicKey(_myKeyPair!);
      
      final privateKeyHex = CryptoService.exportPrivateKey(_myKeyPair!);
      
      await StorageService.saveAccount(
        email: widget.email,
        privateKey: privateKeyHex,
        publicKey: _myPublicKeyHex!,
      );
    }
  }

  Future<void> _loadContacts() async {
    final contacts = await StorageService.getContacts(widget.email);
    
    for (final contact in contacts) {
      final messages = await StorageService.getMessages(
        widget.email,
        contact['email'],
      );
      
      _chats[contact['email']] = {
        'publicKey': contact['publicKey'],
        'messages': messages,
        'lastMessage': messages.isNotEmpty ? messages.first['text'] : null,
      };
    }
    
    setState(() {});
  }

  Future<void> _fetchNewMessages() async {
    try {
      final maxUID = await StorageService.getMaxProcessedUID(widget.email);
      final newMessages = await _emailService.fetchNewMessages(lastSeenUid: maxUID);
      
      for (final mimeMessage in newMessages) {
        await _processMessage(mimeMessage);
      }
      
      if (newMessages.isNotEmpty) {
        await _loadContacts();
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  Future<void> _processMessage(dynamic mimeMessage) async {
    try {
      final from = mimeMessage.from?.first?.email ?? '';
      final body = mimeMessage.decodeTextPlainPart() ?? '';
      final uid = mimeMessage.uid ?? 0;
      
      // Проверяем не обработано ли уже
      if (await StorageService.isUIDProcessed(widget.email, uid)) {
        return;
      }
      
      // Парсим зашифрованный payload
      final encrypted = jsonDecode(body) as Map<String, dynamic>;
      
      // Расшифровываем
      final plaintext = await CryptoService.decryptMessage(
        encrypted: encrypted.map((k, v) => MapEntry(k, v.toString())),
        myKeyPair: _myKeyPair!,
      );
      
      // Парсим содержимое
      try {
        final parsed = jsonDecode(plaintext);
        
        // Обработка приглашения
        if (parsed['type'] == 'invite') {
          await _handleInvite(parsed, from);
        }
        // Обработка read receipt
        else if (parsed['type'] == 'read_receipt') {
          await _handleReadReceipt(parsed, from);
        }
        // Обычное сообщение
        else if (parsed['text'] != null && parsed['uid'] != null) {
          await _handleTextMessage(parsed, from, uid);
        }
      } catch (e) {
        // Старый формат без JSON
        await _handleTextMessage({'text': plaintext, 'uid': uid.toString()}, from, uid);
      }
      
      await StorageService.addProcessedUID(widget.email, uid);
    } catch (e) {
      print('Process message error: $e');
    }
  }

  Future<void> _handleInvite(Map<String, dynamic> invite, String from) async {
    if (_chats.containsKey(invite['email'])) return;
    
    await StorageService.saveContact(
      accountEmail: widget.email,
      contactEmail: invite['email'],
      publicKey: invite['pubkey'],
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Новый контакт: ${invite['email']}')),
      );
    }
  }

  Future<void> _handleReadReceipt(Map<String, dynamic> receipt, String from) async {
    final messageUID = receipt['message_uid'];
    if (messageUID != null) {
      await StorageService.updateMessageStatus(widget.email, messageUID, 'read');
      // Обновляем UI
      await _loadContacts();
    }
  }

  Future<void> _handleTextMessage(Map<String, dynamic> message, String from, int uid) async {
    await StorageService.saveMessage(
      accountEmail: widget.email,
      contactEmail: from,
      text: message['text'],
      sent: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      uid: message['uid'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.email),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showMyQR,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _scanQR,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? _buildEmptyState()
              : _buildChatList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Нет чатов',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте контакт через QR-код',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final email = _chats.keys.elementAt(index);
        final chat = _chats[email]!;
        
        return ListTile(
          leading: CircleAvatar(
            child: Text(email[0].toUpperCase()),
          ),
          title: Text(email),
          subtitle: Text(
            chat['lastMessage'] ?? 'Нет сообщений',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  contactEmail: email,
                  contactPublicKey: chat['publicKey'],
                  myEmail: widget.email,
                  myKeyPair: _myKeyPair!,
                  myPublicKeyHex: _myPublicKeyHex!,
                  emailService: _emailService,
                ),
              ),
            ).then((_) => _loadContacts());
          },
        );
      },
    );
  }

  void _showMyQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScreen(
          myEmail: widget.email,
          myPublicKey: _myPublicKeyHex!,
        ),
      ),
    );
  }

  void _scanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanQRScreen(
          myEmail: widget.email,
          onContactAdded: (email, pubKey) async {
            // Отправляем автоматическое приглашение
            await _sendInvite(email, pubKey);
            await _loadContacts();
          },
        ),
      ),
    );
  }

  Future<void> _sendInvite(String contactEmail, String contactPubKey) async {
    try {
      final inviteMessage = jsonEncode({
        'type': 'invite',
        'email': widget.email,
        'pubkey': _myPublicKeyHex,
      });
      
      final encrypted = await CryptoService.encryptMessage(
        plaintext: inviteMessage,
        recipientPubKeyHex: contactPubKey,
        senderEmail: widget.email,
        recipientEmail: contactEmail,
      );
      
      await _emailService.sendMessage(
        toEmail: contactEmail,
        encryptedPayload: jsonEncode(encrypted),
      );
    } catch (e) {
      print('Send invite error: $e');
    }
  }

  @override
  void dispose() {
    _emailService.disconnect();
    super.dispose();
  }
}
