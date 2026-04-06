import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/chat_service.dart';
import '../services/account_service.dart';
import '../services/storage_service.dart';
import '../services/logger_service.dart';
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

class _ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver {
  late ChatService _chatService;
  late AccountData _accountData;
  final Map<String, Map<String, dynamic>> _chats = {};
  bool _isLoading = true;
  String _connectionStatus = 'Подключение...';
  Timer? _periodicFetchTimer; // Периодический fetch (backup)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Слушаем lifecycle
    _chatService = ChatService(
      email: widget.email,
      password: widget.password,
    );
    _initialize();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Когда приложение возвращается на передний план - fetch новые сообщения
    if (state == AppLifecycleState.resumed) {
      LoggerService.log('📱 App resumed - fetching new messages');
      _chatService.fetchAndProcessNewMessages().catchError((e) {
        LoggerService.log('📱 Fetch on resume error: $e');
      });
      _startPeriodicFetch();
    } else if (state == AppLifecycleState.paused) {
      LoggerService.log('📱 App paused - stopping periodic fetch');
      _periodicFetchTimer?.cancel();
    }
  }
  
  // Периодический fetch каждые 30 секунд (BACKUP)
  void _startPeriodicFetch() {
    _periodicFetchTimer?.cancel();
    _periodicFetchTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      LoggerService.log('⏰ Periodic UI refresh (backup)...');
      if (mounted) {
        _loadContacts();
      }
    });
    LoggerService.log('⏰ Periodic UI refresh started (every 30s)');
  }

  Future<void> _initialize() async {
    try {
      LoggerService.log('ChatListScreen: Initializing ChatService...');
      
      // СНАЧАЛА загружаем контакты из БД (показываем сразу)
      await _loadContacts();
      setState(() => _isLoading = false);
      
      // ВАЖНО: Регистрируем callback ДО инициализации!
      _chatService.addUICallback(() {
        LoggerService.log('ChatListScreen: UI callback triggered!');
        if (mounted) {
          // Просто загружаем данные, БЕЗ изменения статуса
          _loadContacts();
        }
      });
      
      // Инициализируем ChatService (он сам загрузит ключи, подключится к IMAP и т.д.)
      setState(() => _connectionStatus = 'Подключение...');
      await _chatService.initialize();
      
      // Получаем данные аккаунта
      _accountData = _chatService.accountData;
      
      setState(() => _connectionStatus = 'Подключено');
      
      // Запускаем периодический refresh UI
      _startPeriodicFetch();
      
      LoggerService.log('ChatListScreen: Initialization complete!');
      
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

  Future<void> _loadContacts() async {
    final contacts = await StorageService.getContacts(widget.email);
    
    _chats.clear();
    for (final contact in contacts) {
      final messages = await StorageService.getMessages(
        widget.email,
        contact['email'],
      );
      
      // Считаем непрочитанные (входящие без read receipt)
      final unreadCount = messages.where((m) => 
        !m['sent'] && !m['readSent']
      ).length;
      
      _chats[contact['email']] = {
        'publicKey': contact['publicKey'],
        'nickname': contact['nickname'], // ✅ Никнейм
        'messages': messages,
        'lastMessage': messages.isNotEmpty ? messages.first['text'] : null,
        'unreadCount': unreadCount,
      };
    }
    
    if (mounted) {
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
                  ? Colors.green 
                  : _connectionStatus == 'Ошибка'
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Изменить никнейм',
            onPressed: _editNickname,
          ),
          IconButton(
            icon: const Icon(Icons.music_note),
            tooltip: 'Изменить трек',
            onPressed: _editYandexTrack,
          ),
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
            onPressed: () {
              // Просто делаем то же что при запуске
              _chatService.fetchAndProcessNewMessages().catchError((e) {
                LoggerService.log('Manual refresh error: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✗ Ошибка: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
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
          Icon(
            Icons.chat_bubble_outline, 
            size: 80, 
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
          const SizedBox(height: 16),
          Text(
            'Нет чатов',
            style: TextStyle(
              fontSize: 20, 
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте контакт через QR-код',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
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
        final unreadCount = chat['unreadCount'] as int;
        final nickname = chat['nickname'] as String? ?? '';
        
        // ✅ Показываем никнейм если есть, иначе email
        final displayName = nickname.isNotEmpty ? nickname : email;
        
        return ListTile(
          leading: CircleAvatar(
            child: Text(displayName[0].toUpperCase()),
          ),
          title: Text(displayName),
          subtitle: Text(
            chat['lastMessage'] ?? 'Нет сообщений',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  contactEmail: email,
                  contactPublicKey: chat['publicKey'],
                  chatService: _chatService,
                ),
              ),
            ).then((_) => _loadContacts());
          },
          onLongPress: () => _showContactOptions(email),
        );
      },
    );
  }
  
  void _showContactOptions(String contactEmail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить контакт', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteContact(contactEmail);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  void _confirmDeleteContact(String contactEmail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить контакт?'),
        content: Text('Контакт $contactEmail и все сообщения будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteContact(contactEmail);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteContact(String contactEmail) async {
    try {
      await StorageService.deleteContact(widget.email, contactEmail);
      await _loadContacts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Контакт $contactEmail удалён'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      LoggerService.log('Delete contact error: $e');
      if (mounted) {
        _showErrorWithCopy('Ошибка удаления', e.toString());
      }
    }
  }

  void _showMyQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScreen(
          myEmail: widget.email,
          myPublicKey: _accountData.publicKeyHex,
        ),
      ),
    );
  }

  void _scanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanQRScreen(
          chatService: _chatService,
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
  
  void _editNickname() async {
    // Загружаем текущий никнейм
    final account = await StorageService.getAccount(widget.email);
    final currentNickname = account?['nickname'] ?? '';
    
    final controller = TextEditingController(text: currentNickname);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить никнейм'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Никнейм',
            hintText: 'Введите никнейм',
          ),
          maxLength: 32,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final nickname = controller.text.trim();
              
              try {
                // Сохраняем никнейм
                await StorageService.updateAccountNickname(widget.email, nickname);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(nickname.isEmpty 
                        ? '✓ Никнейм удалён' 
                        : '✓ Никнейм изменён на "$nickname"'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✗ Ошибка: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
  
  void _editYandexTrack() async {
    // Загружаем текущий Yandex Track ID
    final account = await StorageService.getAccount(widget.email);
    final currentTrackId = account?['yandexTrackId'] ?? '';
    
    final controller = TextEditingController(text: currentTrackId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить трек'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Введите ID трека или ссылку из Яндекс.Музыки',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'Например: 147457409 или https://music.yandex.ru/album/.../track/147457409',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Track ID или ссылка',
                hintText: '147457409',
              ),
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final input = controller.text.trim();
              
              try {
                // Парсим Track ID из строки (число или ссылка)
                String trackId = '';
                if (input.isNotEmpty) {
                  // Если это просто число
                  if (RegExp(r'^\d+$').hasMatch(input)) {
                    trackId = input;
                  } else {
                    // Если это ссылка: https://music.yandex.ru/album/41305001/track/149601172
                    final urlPattern = RegExp(r'/track/(\d+)');
                    final match = urlPattern.firstMatch(input);
                    if (match != null) {
                      trackId = match.group(1)!;
                    } else {
                      throw Exception('Неверный формат. Введите Track ID (число) или ссылку на трек');
                    }
                  }
                }
                
                // Сохраняем Track ID
                await StorageService.updateAccountYandexTrackId(widget.email, trackId);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(trackId.isEmpty 
                        ? '✓ Трек удалён' 
                        : '✓ Трек изменён на "$trackId"'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✗ Ошибка: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Удаляем observer
    _periodicFetchTimer?.cancel(); // Останавливаем периодический fetch
    _chatService.disconnect();
    super.dispose();
  }
}
