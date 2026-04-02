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
      
      // ВАЖНО: При первом запуске (maxUID=0) НЕ fetch'им старые письма!
      if (maxUID == 0) {
        LoggerService.log('ChatService: First run in processor, setting initial UIDNEXT');
        final currentUidNext = await _emailService.getCurrentUidNext();
        if (currentUidNext > 0) {
          await StorageService.addProcessedUID(email, currentUidNext - 1);
          LoggerService.log('ChatService: Initial UIDNEXT set to ${currentUidNext - 1}');
        }
        return;
      }
      
      final newMessages = await _emailService.fetchNewMessages(lastSeenUid: maxUID);
      
      // Обрабатываем через MessageService (он сам уведомит UI)
      if (newMessages.isNotEmpty) {
        await _messageService.processNewMessages(newMessages);
      }
    });
    
    // 5. Подключаемся к IMAP
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
    
    try {
      final maxUID = await StorageService.getMaxProcessedUID(email);
      
      // ВАЖНО: При первом запуске (maxUID=0) НЕ fetch'им старые письма!
      // Устанавливаем lastSeenUid в текущий UIDNEXT и fetch'им только новые
      if (maxUID == 0) {
        LoggerService.log('ChatService: First run, setting initial UIDNEXT');
        // Получаем текущий UIDNEXT без fetch
        final currentUidNext = await _emailService.getCurrentUidNext();
        if (currentUidNext > 0) {
          // Сохраняем фиктивный UID чтобы не fetch'ить старые письма
          await StorageService.addProcessedUID(email, currentUidNext - 1);
          LoggerService.log('ChatService: Initial UIDNEXT set to ${currentUidNext - 1}');
        }
        return;
      }
      
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
