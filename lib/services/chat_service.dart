import 'email_service.dart';
import 'message_service.dart';
import 'account_service.dart';
import 'storage_service.dart';
import 'logger_service.dart';

/// ChatService - главный координатор
/// Связывает EmailService и MessageService
/// Это единая точка входа для UI
class ChatService {
  final String email;
  final String password;
  
  late final EmailService _emailService;
  late final MessageService _messageService;
  late final AccountData _accountData;
  
  bool _initialized = false;
  
  // Храним callbacks до инициализации MessageService
  final List<Function()> _pendingUICallbacks = [];
  final List<Function(List<String> uids, String status)> _pendingStatusCallbacks = [];
  
  ChatService({
    required this.email,
    required this.password,
  });
  
  /// Инициализация (вызывается один раз)
  Future<void> initialize() async {
    if (_initialized) return;
    
    LoggerService.log('ChatService: Initializing for $email');
    
    // 1. Загружаем/генерируем ключи
    _accountData = await AccountService.loadOrGenerateAccount(email);
    
    // 2. Создаём MessageService
    _messageService = MessageService(
      accountEmail: email,
      keyPair: _accountData.keyPair,
    );
    
    // 2.1. Регистрируем все pending callbacks
    for (final callback in _pendingUICallbacks) {
      _messageService.addUICallback(callback);
    }
    for (final callback in _pendingStatusCallbacks) {
      _messageService.addStatusUpdateCallback(callback);
    }
    _pendingUICallbacks.clear();
    _pendingStatusCallbacks.clear();
    
    // 3. Создаём EmailService
    _emailService = EmailService(
      email: email,
      password: password,
    );
    
    // 4. Связываем: EmailService → MessageService → UI
    // EmailService вызывает processor для обработки сообщений
    _emailService.setMessageProcessor(() async {
      LoggerService.log('ChatService: Message processor triggered');
      
      // Fetch новых писем
      final maxUID = await StorageService.getMaxProcessedUID(email);
      final newMessages = await _emailService.fetchNewMessages(lastSeenUid: maxUID);
      
      // Обрабатываем через MessageService (он сам уведомит UI)
      if (newMessages.isNotEmpty) {
        await _messageService.processNewMessages(newMessages);
      }
    });
    
    // 5. Проверяем первый запуск ДО подключения
    final maxUIDBeforeConnect = await StorageService.getMaxProcessedUID(email);
    final isFirstRun = maxUIDBeforeConnect == 0;
    
    if (isFirstRun) {
      LoggerService.log('ChatService: First run detected - sync point will be set');
    } else {
      LoggerService.log('ChatService: Not first run (maxUID=$maxUIDBeforeConnect)');
    }
    
    // 6. Подключаемся к IMAP БЕЗ запуска IDLE (если не первый запуск)
    await _emailService.connectImap(startIdle: isFirstRun);
    
    // 7. ВАЖНО: Делаем начальный fetch ПОСЛЕ подключения (если не первый запуск)
    if (!isFirstRun) {
      LoggerService.log('ChatService: Doing initial fetch for missed messages...');
      try {
        final maxUID = await StorageService.getMaxProcessedUID(email);
        final newMessages = await _emailService.fetchNewMessages(lastSeenUid: maxUID);
        
        if (newMessages.isNotEmpty) {
          LoggerService.log('ChatService: Initial fetch - found ${newMessages.length} new messages');
          await _messageService.processNewMessages(newMessages);
        } else {
          LoggerService.log('ChatService: Initial fetch - no new messages');
        }
      } catch (e) {
        LoggerService.log('ChatService: Initial fetch error: $e');
        // Не падаем, продолжаем работу
      }
      
      // 8. Теперь запускаем IDLE (после fetch)
      LoggerService.log('ChatService: Starting IDLE after initial fetch');
      _emailService.startIdleIfNeeded();
    } else {
      LoggerService.log('ChatService: First run - skipping initial fetch (sync point set)');
      LoggerService.log('ChatService: IDLE already started');
    }
    
    _initialized = true;
    LoggerService.log('ChatService: Initialized successfully');
  }
  
  /// Регистрация UI callback
  void addUICallback(Function() callback) {
    if (_initialized) {
      _messageService.addUICallback(callback);
    } else {
      // Сохраняем до инициализации
      if (!_pendingUICallbacks.contains(callback)) {
        _pendingUICallbacks.add(callback);
        LoggerService.log('ChatService: UI callback queued (pending initialization)');
      }
    }
  }
  
  /// Удаление UI callback
  void removeUICallback(Function() callback) {
    if (_initialized) {
      _messageService.removeUICallback(callback);
    } else {
      _pendingUICallbacks.remove(callback);
    }
  }
  
  /// Регистрация callback для обновления статуса сообщений
  void addStatusUpdateCallback(Function(List<String> uids, String status) callback) {
    if (_initialized) {
      _messageService.addStatusUpdateCallback(callback);
    } else {
      // Сохраняем до инициализации
      if (!_pendingStatusCallbacks.contains(callback)) {
        _pendingStatusCallbacks.add(callback);
        LoggerService.log('ChatService: Status callback queued (pending initialization)');
      }
    }
  }
  
  /// Удаление callback для обновления статуса
  void removeStatusUpdateCallback(Function(List<String> uids, String status) callback) {
    if (_initialized) {
      _messageService.removeStatusUpdateCallback(callback);
    } else {
      _pendingStatusCallbacks.remove(callback);
    }
  }
  
  /// Отправка сообщения
  Future<String> sendMessage({
    required String toEmail,
    required String encryptedPayload,
  }) async {
    return await _emailService.sendMessage(
      toEmail: toEmail,
      encryptedPayload: encryptedPayload,
    );
  }
  
  /// Получение данных аккаунта
  AccountData get accountData => _accountData;
  
  /// Принудительный fetch новых сообщений (для resume и т.д.)
  Future<void> fetchAndProcessNewMessages() async {
    if (!_initialized) {
      LoggerService.log('ChatService: Not initialized, skipping fetch');
      return;
    }
    
    LoggerService.log('ChatService: fetchAndProcessNewMessages() called');
    
    try {
      final maxUID = await StorageService.getMaxProcessedUID(email);
      LoggerService.log('ChatService: maxUID from DB = $maxUID');
      
      final newMessages = await _emailService.fetchNewMessages(lastSeenUid: maxUID);
      
      if (newMessages.isNotEmpty) {
        LoggerService.log('ChatService: Fetched ${newMessages.length} new messages');
        await _messageService.processNewMessages(newMessages);
      } else {
        LoggerService.log('ChatService: No new messages');
      }
    } catch (e) {
      LoggerService.log('ChatService: Fetch error: $e');
      rethrow;
    }
  }
  
  /// Отключение
  Future<void> disconnect() async {
    await _emailService.disconnect();
  }
}
