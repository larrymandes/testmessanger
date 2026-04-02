import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PublicKey, PrivateKey;
import 'package:enough_mail/enough_mail.dart';
import '../services/email_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/logger_service.dart';
import 'dart:convert';
import 'chat_screen.dart';
import 'qr_screen.dart';
import 'logs_screen.dart';

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
      
      // Устанавливаем callback ДО подключения (чтобы не пропустить события)
      _emailService.setNewMessageCallback(() {
        // Вызывается мгновенно при IDLE событии
        LoggerService.log('ChatListScreen: Callback triggered!');
        if (mounted) {
          LoggerService.log('ChatListScreen: Fetching new messages...');
          _fetchNewMessages();
        } else {
          LoggerService.log('ChatListScreen: NOT mounted, skipping');
        }
      });
      
      _emailService.connectImap().then((_) async {
        if (mounted) {
          setState(() => _connectionStatus = 'Подключено');
        }
        
        // НЕ слушаем stream - используем только callback (чтобы не было дублей)
        
        // СРАЗУ получаем новые сообщения при запуске (ВАЖНО!)
        LoggerService.log('Initial fetch on startup...');
        await _fetchNewMessages();
        
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
    final fetchStartTime = DateTime.now();
    LoggerService.log('UI: Fetch started at ${fetchStartTime.hour}:${fetchStartTime.minute}:${fetchStartTime.second}.${fetchStartTime.millisecond}');
    
    try {
      final maxUID = await StorageService.getMaxProcessedUID(widget.email);
      LoggerService.log('UI: Requesting fetch (last UID: $maxUID)...');
      
      final newMessages = await _emailService.fetchNewMessages(lastSeenUid: maxUID);
      
      final afterFetchTime = DateTime.now();
      final fetchDuration = afterFetchTime.difference(fetchStartTime).inMilliseconds;
      LoggerService.log('UI: Got ${newMessages.length} new messages in ${fetchDuration}ms');
      
      for (final mimeMessage in newMessages) {
        await _processMessage(mimeMessage);
      }
      
      // ВСЕГДА обновляем список чатов после fetch
      if (mounted) {
        await _loadContacts();
        setState(() {});
        
        final endTime = DateTime.now();
        final totalDuration = endTime.difference(fetchStartTime).inMilliseconds;
        LoggerService.log('UI: ✅ Fetch + UI update completed in ${totalDuration}ms (fetch: ${fetchDuration}ms, process+UI: ${totalDuration - fetchDuration}ms)');
      }
    } catch (e) {
      LoggerService.log('UI: Fetch error: $e');
      if (mounted) {
        setState(() => _connectionStatus = 'Ошибка');
      }
    }
  }

  Future<void> _processMessage(dynamic mimeMessage) async {
    try {
      final from = mimeMessage.from?.first?.email ?? '';
      final uid = mimeMessage.uid ?? 0;
      final messageId = mimeMessage.decodeHeaderValue('message-id') ?? '';
      
      // ВАЖНО: Получаем RAW body без декодирования переносов строк
      String body = '';
      
      // Пробуем получить text/plain часть
      final textPlainPart = mimeMessage.getPartWithMediaSubtype(MediaSubtype.textPlain);
      if (textPlainPart != null) {
        body = textPlainPart.decodeContentText() ?? '';
      } else {
        // Fallback на decodeTextPlainPart
        body = mimeMessage.decodeTextPlainPart() ?? '';
      }
      
      // Убираем все переносы строк и пробелы из JSON
      body = body.replaceAll(RegExp(r'\s+'), '');
      
      LoggerService.log('Body length: ${body.length}');
      
      // Пропускаем битые
      if (uid == 0) {
        LoggerService.log('UID=0, skipping');
        return;
      }
      
      // Дедупликация по Message-ID (как Delta Chat)
      if (messageId.isNotEmpty) {
        if (await StorageService.isMessageIdProcessed(widget.email, messageId)) {
          LoggerService.log('Message-ID already processed: $messageId');
          await StorageService.addProcessedUID(widget.email, uid);
          await _emailService.markMessageAsSeen(uid);
          return;
        }
      }
      
      // Проверяем не обработано ли по UID
      if (await StorageService.isUIDProcessed(widget.email, uid)) {
        LoggerService.log('UID=$uid already processed');
        return;
      }
      
      LoggerService.log('Processing UID=$uid from $from');
      
      // Парсим JSON
      Map<String, dynamic> encrypted;
      try {
        encrypted = jsonDecode(body) as Map<String, dynamic>;
        LoggerService.log('Body is valid JSON');
      } catch (e) {
        LoggerService.log('Not JSON, error: $e');
        await StorageService.addProcessedUID(widget.email, uid);
        if (messageId.isNotEmpty) {
          await StorageService.addProcessedMessageId(widget.email, messageId);
        }
        await _emailService.markMessageAsSeen(uid);
        return;
      }
      
      // Расшифровываем
      String plaintext;
      try {
        plaintext = await CryptoService.decryptMessage(
          encrypted: encrypted.map((k, v) => MapEntry(k, v.toString())),
          myKeyPair: _myKeyPair!,
        );
        LoggerService.log('Decrypted ok');
      } catch (e) {
        LoggerService.log('Decryption failed (wrong key)');
        await StorageService.addProcessedUID(widget.email, uid);
        if (messageId.isNotEmpty) {
          await StorageService.addProcessedMessageId(widget.email, messageId);
        }
        await _emailService.markMessageAsSeen(uid);
        return;
      }
      
      // Обрабатываем
      try {
        final parsed = jsonDecode(plaintext);
        
        LoggerService.log('Message type: ${parsed['type'] ?? 'text'}');
        
        if (parsed['type'] == 'invite') {
          LoggerService.log('Processing invite...');
          await _handleInvite(parsed, from);
        } else if (parsed['type'] == 'read_receipt') {
          LoggerService.log('Processing read receipt...');
          await _handleReadReceipt(parsed, from);
        } else if (parsed['text'] != null) {
          LoggerService.log('Processing text message...');
          await _handleTextMessage(parsed, from, uid, messageId);
        }
      } catch (e) {
        // Старый формат
        LoggerService.log('Old format, treating as text');
        await _handleTextMessage({'text': plaintext, 'uid': uid.toString()}, from, uid, messageId);
      }
      
      // Помечаем как обработанное
      await StorageService.addProcessedUID(widget.email, uid);
      if (messageId.isNotEmpty) {
        await StorageService.addProcessedMessageId(widget.email, messageId);
      }
      await _emailService.markMessageAsSeen(uid);
      
    } catch (e) {
      LoggerService.log('Process error: $e');
    }
  }

  Future<void> _handleInvite(Map<String, dynamic> invite, String from) async {
    final contactEmail = invite['email'] as String;
    final contactPubKey = invite['pubkey'] as String;
    
    LoggerService.log('Invite from $contactEmail (received from $from)');
    
    // Проверяем что from совпадает с contactEmail (защита от подделки)
    if (from != contactEmail) {
      LoggerService.log('WARNING: from ($from) != contactEmail ($contactEmail), skipping');
      return;
    }
    
    // Проверяем не добавлен ли
    final existing = await StorageService.getContact(widget.email, contactEmail);
    if (existing != null) {
      LoggerService.log('Contact already exists');
      return;
    }
    
    // Сохраняем контакт
    await StorageService.saveContact(
      accountEmail: widget.email,
      contactEmail: contactEmail,
      publicKey: contactPubKey,
    );
    
    LoggerService.log('Contact $contactEmail saved successfully');
    
    if (mounted) {
      // Перезагружаем контакты
      await _loadContacts();
      
      // Обновляем UI
      setState(() {});
      
      // Показываем уведомление
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Новый контакт добавлен: $contactEmail'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleReadReceipt(Map<String, dynamic> receipt, String from) async {
    final messageUID = receipt['message_uid'];
    if (messageUID != null) {
      LoggerService.log('📖 Read receipt: message=$messageUID from=$from');
      
      // Обновляем статус сообщения на 'read'
      final updated = await StorageService.updateMessageStatus(widget.email, messageUID, 'read');
      
      if (updated) {
        LoggerService.log('📖 Message $messageUID status updated to READ in DB');
      } else {
        LoggerService.log('📖 WARNING: Failed to update message $messageUID status');
      }
      
      // Обновляем UI
      if (mounted) {
        await _loadContacts();
        setState(() {});
        LoggerService.log('📖 UI updated after read receipt');
      }
    } else {
      LoggerService.log('📖 WARNING: Read receipt without message_uid');
    }
  }

  Future<void> _handleTextMessage(Map<String, dynamic> message, String from, int uid, String messageId) async {
    await StorageService.saveMessage(
      accountEmail: widget.email,
      contactEmail: from,
      text: message['text'],
      sent: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      uid: message['uid'],
      messageId: messageId.isNotEmpty ? messageId : null,
    );
    LoggerService.log('Message saved');
    
    if (mounted) {
      // Перезагружаем контакты
      await _loadContacts();
      
      // Обновляем UI
      setState(() {});
    }
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
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              LoggerService.log('Manual refresh triggered');
              setState(() => _connectionStatus = 'Обновление...');
              try {
                await _fetchNewMessages();
                if (mounted) {
                  setState(() => _connectionStatus = 'Подключено');
                }
              } catch (e) {
                LoggerService.log('Manual refresh error: $e');
                if (mounted) {
                  setState(() => _connectionStatus = 'Ошибка');
                }
              }
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
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Копировать',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: '$title: $error'));
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

  @override
  void dispose() {
    _emailService.disconnect();
    super.dispose();
  }
}
