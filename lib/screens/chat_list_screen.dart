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
    setState(() => _isLoading = true);
    
    try {
      LoggerService.log('ChatListScreen: Initializing ChatService...');
      
      // Инициализируем ChatService (он сам загрузит ключи, подключится к IMAP и т.д.)
      await _chatService.initialize();
      
      // Получаем данные аккаунта
      _accountData = _chatService.accountData;
      
      // Регистрируем callback для обновления UI
      _chatService.addUICallback(() {
        LoggerService.log('ChatListScreen: UI callback triggered!');
        if (mounted) {
          _loadContacts();
        }
      });
      
      // Загружаем контакты из БД
      await _loadContacts();
      
      setState(() {
        _isLoading = false;
        _connectionStatus = 'Подключено';
      });
      
      // Запускаем периодический refresh UI
      _startPeriodicFetch();
      
      LoggerService.log('ChatListScreen: Initialization complete!');
      
      // ВАЖНО: Делаем fetch при старте (на случай если были новые сообщения пока приложение было закрыто)
      // Делаем ПОСЛЕ инициализации чтобы не блокировать UI
      LoggerService.log('ChatListScreen: Initial fetch on startup...');
      _chatService.fetchAndProcessNewMessages().then((_) {
        LoggerService.log('ChatListScreen: Initial fetch completed!');
      }).catchError((e) {
        LoggerService.log('ChatListScreen: Initial fetch error: $e');
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

  Future<void> _loadContacts() async {
    final contacts = await StorageService.getContacts(widget.email);
    
    _chats.clear();
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
                await _loadContacts();
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
                  chatService: _chatService,
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Удаляем observer
    _periodicFetchTimer?.cancel(); // Останавливаем периодический fetch
    _chatService.disconnect();
    super.dispose();
  }
}
