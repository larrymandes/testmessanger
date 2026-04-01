import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PublicKey, PrivateKey;
import '../services/email_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import 'dart:convert';
import 'chat_screen.dart';
import '../theme/app_theme.dart';

class ChatsTab extends StatefulWidget {
  final String email;
  final String password;
  final EmailService emailService;
  final AsymmetricKeyPair<PublicKey, PrivateKey>? myKeyPair;
  final String? myPublicKeyHex;

  const ChatsTab({
    super.key,
    required this.email,
    required this.password,
    required this.emailService,
    this.myKeyPair,
    this.myPublicKeyHex,
  });

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> with AutomaticKeepAliveClientMixin {
  final Map<String, Map<String, dynamic>> _chats = {};
  bool _isLoading = true;
  String _connectionStatus = 'Подключение...';
  AsymmetricKeyPair<PublicKey, PrivateKey>? _myKeyPair;
  String? _myPublicKeyHex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _myKeyPair = widget.myKeyPair;
    _myPublicKeyHex = widget.myPublicKeyHex;
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadOrGenerateKeys();
      await _loadContacts();
      
      setState(() => _connectionStatus = 'Подключение...');
      await widget.emailService.connectImap();
      setState(() => _connectionStatus = 'Подключено');
      
      widget.emailService.listenForNewMessages().listen((_) {
        _fetchNewMessages();
      });
      
      await _fetchNewMessages();
    } catch (e) {
      setState(() => _connectionStatus = 'Ошибка');
      if (mounted) {
        _showErrorWithCopy('Ошибка подключения', e.toString());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrGenerateKeys() async {
    final account = await StorageService.getAccount(widget.email);
    
    if (account != null) {
      final privateKey = CryptoService.importPrivateKey(account['privateKey']!);
      final publicKey = CryptoService.importPublicKey(account['publicKey']!);
      _myKeyPair = AsymmetricKeyPair<PublicKey, PrivateKey>(publicKey, privateKey);
      _myPublicKeyHex = account['publicKey']!;
    } else {
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
        'lastTimestamp': messages.isNotEmpty ? messages.first['timestamp'] : 0,
        'unreadCount': messages.where((m) => !m['sent'] && !m['readSent']).length,
      };
    }
    
    if (mounted) setState(() {});
  }

  Future<void> _fetchNewMessages() async {
    try {
      final maxUID = await StorageService.getMaxProcessedUID(widget.email);
      final newMessages = await widget.emailService.fetchNewMessages(lastSeenUid: maxUID);
      
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
      
      if (await StorageService.isUIDProcessed(widget.email, uid)) {
        return;
      }
      
      final encrypted = jsonDecode(body) as Map<String, dynamic>;
      final plaintext = await CryptoService.decryptMessage(
        encrypted: encrypted.map((k, v) => MapEntry(k, v.toString())),
        myKeyPair: _myKeyPair!,
      );
      
      try {
        final parsed = jsonDecode(plaintext);
        
        if (parsed['type'] == 'invite') {
          await _handleInvite(parsed, from);
        } else if (parsed['type'] == 'read_receipt') {
          await _handleReadReceipt(parsed, from);
        } else if (parsed['text'] != null && parsed['uid'] != null) {
          await _handleTextMessage(parsed, from, uid);
        }
      } catch (e) {
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
    
    final existing = await StorageService.getContact(widget.email, contactEmail);
    if (existing != null) return;
    
    await StorageService.saveContact(
      accountEmail: widget.email,
      contactEmail: contactEmail,
      publicKey: contactPubKey,
    );
    
    await _loadContacts();
  }

  Future<void> _handleReadReceipt(Map<String, dynamic> receipt, String from) async {
    final messageUID = receipt['message_uid'];
    if (messageUID != null) {
      await StorageService.updateMessageStatus(widget.email, messageUID, 'read');
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
    super.build(context);
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.headerBgColor,
        border: null,
        middle: Column(
          children: [
            const Text('Чаты', style: TextStyle(color: AppTheme.textColor)),
            Text(
              _connectionStatus,
              style: TextStyle(
                fontSize: 11,
                color: _connectionStatus == 'Подключено' 
                  ? AppTheme.accentTextColor
                  : _connectionStatus == 'Ошибка'
                    ? AppTheme.destructiveTextColor
                    : AppTheme.subtitleTextColor,
              ),
            ),
          ],
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.square_pencil, color: AppTheme.accentTextColor),
          onPressed: () {
            // TODO: Новый чат
          },
        ),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
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
          Icon(CupertinoIcons.chat_bubble_2, size: 80, color: AppTheme.subtitleTextColor),
          const SizedBox(height: 16),
          const Text(
            'Нет чатов',
            style: TextStyle(fontSize: 20, color: AppTheme.subtitleTextColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте контакт на вкладке Контакты',
            style: TextStyle(color: AppTheme.hintColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    final sortedChats = _chats.entries.toList()
      ..sort((a, b) => (b.value['lastTimestamp'] as int).compareTo(a.value['lastTimestamp'] as int));

    return ListView.separated(
      itemCount: sortedChats.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: AppTheme.sectionSeparatorColor,
        indent: 72,
      ),
      itemBuilder: (context, index) {
        final entry = sortedChats[index];
        final email = entry.key;
        final chat = entry.value;
        
        return _buildChatItem(email, chat);
      },
    );
  }

  Widget _buildChatItem(String email, Map<String, dynamic> chat) {
    final lastTimestamp = chat['lastTimestamp'] as int;
    final timeStr = _formatTime(lastTimestamp);
    final unreadCount = chat['unreadCount'] as int;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ChatScreen(
              contactEmail: email,
              contactPublicKey: chat['publicKey'],
              myEmail: widget.email,
              myKeyPair: _myKeyPair!,
              myPublicKeyHex: _myPublicKeyHex!,
              emailService: widget.emailService,
            ),
          ),
        ).then((_) => _loadContacts());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AppTheme.bgColor,
        child: Row(
          children: [
            // Аватар
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentTextColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  email[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Контент
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: AppTheme.subtitleTextColor,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage'] ?? 'Нет сообщений',
                          style: const TextStyle(
                            color: AppTheme.subtitleTextColor,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTextColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return '';
    
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Вчера';
    } else if (diff.inDays < 7) {
      const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      return days[date.weekday - 1];
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _showErrorWithCopy(String title, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✗ $title: $error'),
        backgroundColor: AppTheme.destructiveTextColor,
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
    // EmailService будет закрыт в MainScreen
    super.dispose();
  }
}
