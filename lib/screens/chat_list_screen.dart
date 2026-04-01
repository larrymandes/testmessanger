import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PublicKey, PrivateKey;
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
  String _connectionStatus = 'Подключение...';
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
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    
    try {
      // Загружаем или генерируем ключи
      await _loadOrGenerateKeys();
      
      // Загружаем контакты
      await _loadContacts();
      
      setState(() => _isLoading = false);
      
      // Подключаемся к IMAP асинхронно (не блокируем UI)
      setState(() => _connectionStatus = 'Подключение...');
      
      _emailService.connectImap().then((_) {
        if (mounted) {
          setState(() => _connectionStatus = 'Подключено');
        }
        
        // Запускаем IDLE listener (не ждём его)
        _emailService.listenForNewMessages().listen((_) {
          _fetchNewMessages();
        });
        
        // Получаем новые сообщения
        _fetchNewMessages();
      }).catchError((e) {
        if (mounted) {
          setState(() => _connectionStatus = 'Ошибка');
          _showErrorWithCopy('Ошибка подключения', e.toString());
        }
      });
      
    } catch (e) {
      setState(() {
        _connectionStatus = 'Ошибка';
        _isLoading = false;
      });
      if (mounted) {
        _showErrorWithCopy('Ошибка инициализации', e.toString());
      }
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
      setState(() => _connectionStatus = 'Ошибка');
      if (mounted) {
        _showErrorWithCopy('Ошибка получения', e.toString());
      }
    }
  }

  Future<void> _processMessage(dynamic mimeMessage) async {
    try {
      final from = mimeMessage.from?.first?.email ?? '';
      final body = mimeMessage.decodeTextPlainPart() ?? '';
      final uid = mimeMessage.uid ?? 0;
      
      print('Processing message from $from, UID: $uid');
      print('Body length: ${body.length}');
      
      // Проверяем не обработано ли уже
      if (await StorageService.isUIDProcessed(widget.email, uid)) {
        print('UID $uid already processed, skipping');
        return;
      }
      
      // Парсим зашифрованный payload
      Map<String, dynamic> encrypted;
      try {
        encrypted = jsonDecode(body) as Map<String, dynamic>;
        print('Encrypted payload keys: ${encrypted.keys.join(", ")}');
      } catch (e) {
        print('Failed to parse JSON: $e');
        await StorageService.addProcessedUID(widget.email, uid);
        return;
      }
      
      // Расшифровываем
      String plaintext;
      try {
        plaintext = await CryptoService.decryptMessage(
          encrypted: encrypted.map((k, v) => MapEntry(k, v.toString())),
          myKeyPair: _myKeyPair!,
        );
        print('Decrypted successfully: ${plaintext.substring(0, plaintext.length > 50 ? 50 : plaintext.length)}...');
      } catch (e) {
        print('Decryption failed: $e');
        // Помечаем как обработанное чтобы не пытаться снова
        await StorageService.addProcessedUID(widget.email, uid);
        if (mounted) {
          _showErrorWithCopy('Не удалось расшифровать сообщение от $from', e.toString());
        }
        return;
      }
      
      // Парсим содержимое
      try {
        final parsed = jsonDecode(plaintext);
        print('Message type: ${parsed['type'] ?? 'text'}');
        
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
        print('Not JSON, treating as plain text');
        await _handleTextMessage({'text': plaintext, 'uid': uid.toString()}, from, uid);
      }
      
      await StorageService.addProcessedUID(widget.email, uid);
    } catch (e) {
      print('Process message error: $e');
      if (mounted) {
        _showErrorWithCopy('Ошибка обработки сообщения', e.toString());
      }
    }
  }

  Future<void> _handleInvite(Map<String, dynamic> invite, String from) async {
    final contactEmail = invite['email'] as String;
    final contactPubKey = invite['pubkey'] as String;
    
    // Проверяем, не добавлен ли уже
    final existing = await StorageService.getContact(widget.email, contactEmail);
    if (existing != null) return;
    
    // Сохраняем контакт (БЕЗ отправки invite обратно, как в оригинале)
    await StorageService.saveContact(
      accountEmail: widget.email,
      contactEmail: contactEmail,
      publicKey: contactPubKey,
    );
    
    // Перезагружаем список контактов
    await _loadContacts();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.email),
            Text(
              _connectionStatus,
              style: TextStyle(
                fontSize: 12,
                color: _connectionStatus == 'Подключено' 
                  ? Colors.green[300] 
                  : _connectionStatus == 'Ошибка'
                    ? Colors.red[300]
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => _connectionStatus = 'Обновление...');
              await _fetchNewMessages();
              setState(() => _connectionStatus = 'Подключено');
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showDebugInfo,
          ),
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

  void _showDebugInfo() async {
    final contacts = await StorageService.getContacts(widget.email);
    final maxUID = await StorageService.getMaxProcessedUID(widget.email);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${widget.email}'),
              const SizedBox(height: 8),
              Text('Контактов: ${contacts.length}'),
              const SizedBox(height: 8),
              Text('Последний UID: $maxUID'),
              const SizedBox(height: 8),
              Text('Чатов: ${_chats.length}'),
              const SizedBox(height: 16),
              const Text('Контакты:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...contacts.map((c) => Text('- ${c['email']}')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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
          myPublicKeyHex: _myPublicKeyHex!,
          emailService: _emailService,
          onContactAdded: (email, pubKey) async {
            await _loadContacts();
          },
        ),
      ),
    );
  }

  void _showErrorWithCopy(String title, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✗ $title: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Копировать',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: '$title: $error'));
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

  @override
  void dispose() {
    _emailService.disconnect();
    super.dispose();
  }
}
