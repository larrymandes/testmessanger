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
    
    // 5. Подключаемся к IMAP (он сам установит sync point если нужно)
    await _emailService.connectImap();
    
    _initialized = true;
    LoggerService.log('ChatService: Initialized successfully');
  }
  
  /// Регистрация UI callback
  void addUICallback(Function() callback) {
    _messageService.addUICallback(callback);
  }
  
  /// Удаление UI callback
  void removeUICallback(Function() callback) {
    _messageService.removeUICallback(callback);
  }
  
  /// Регистрация callback для обновления статуса сообщений
  void addStatusUpdateCallback(Function(List<String> uids, String status) callback) {
    _messageService.addStatusUpdateCallback(callback);
  }
  
  /// Удаление callback для обновления статуса
  void removeStatusUpdateCallback(Function(List<String> uids, String status) callback) {
    _messageService.removeStatusUpdateCallback(callback);
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
