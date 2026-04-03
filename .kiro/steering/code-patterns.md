---
inclusion: always
---

# Code Patterns - Email Messenger

## ПАТТЕРНЫ КОДА - ИСПОЛЬЗУЙ ЭТИ ШАБЛОНЫ

### Паттерн 1: Добавление новой функции в сервис

```dart
// В ChatService или MessageService
Future<void> myNewFeature({required String param}) async {
  try {
    LoggerService.log('MyService: Starting myNewFeature');
    
    // 1. Получаем данные
    final data = await _fetchData(param);
    
    // 2. Обрабатываем
    final processed = await _processData(data);
    
    // 3. Сохраняем в БД
    await StorageService.saveData(processed);
    
    // 4. Уведомляем UI (если нужно)
    _notifyUI();
    
    LoggerService.log('MyService: myNewFeature completed');
  } catch (e) {
    LoggerService.log('MyService: myNewFeature error: $e');
    rethrow;
  }
}
```

### Паттерн 2: Вызов сервиса из UI

```dart
// В Screen
Future<void> _onButtonPressed() async {
  try {
    // Показываем loading
    setState(() => _isLoading = true);
    
    // Вызываем сервис
    await _chatService.myNewFeature(param: 'value');
    
    // Загружаем обновлённые данные из БД
    await _loadData();
    
    // Убираем loading
    if (mounted) {
      setState(() => _isLoading = false);
    }
  } catch (e) {
    LoggerService.log('Screen: Error: $e');
    if (mounted) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }
}
```

### Паттерн 3: Регистрация callback в UI

```dart
// В Screen initState
@override
void initState() {
  super.initState();
  
  // Создаём callback
  _callback = () {
    LoggerService.log('Screen: Callback triggered');
    if (mounted) {
      _loadData(); // Загружаем из БД
    }
  };
  
  // Регистрируем
  _chatService.addUICallback(_callback);
  
  // Загружаем начальные данные
  _loadData();
}

// В Screen dispose
@override
void dispose() {
  _chatService.removeUICallback(_callback);
  super.dispose();
}
```

### Паттерн 4: Обработка lifecycle событий

```dart
// В Screen
class _MyScreenState extends State<MyScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      LoggerService.log('📱 App resumed');
      // Вызываем сервис для fetch
      _chatService.fetchAndProcessNewMessages().catchError((e) {
        LoggerService.log('📱 Fetch error: $e');
      });
    } else if (state == AppLifecycleState.paused) {
      LoggerService.log('📱 App paused');
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

### Паттерн 5: Загрузка данных из БД в UI

```dart
// В Screen
Future<void> _loadData() async {
  final startTime = DateTime.now();
  
  try {
    // Загружаем из БД
    final data = await StorageService.getData(widget.email);
    
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    LoggerService.log('Screen: Loaded ${data.length} items in ${duration}ms');
    
    // Обновляем UI
    if (mounted) {
      setState(() {
        _data = data;
      });
    }
  } catch (e) {
    LoggerService.log('Screen: Load error: $e');
  }
}
```

### Паттерн 6: Показ ошибки пользователю

```dart
// В Screen
void _showError(String error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('✗ Ошибка: $error'),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Копировать',
        textColor: Colors.white,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: error));
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
```

### Паттерн 7: Обработка сообщений в MessageService

```dart
// В MessageService
Future<void> _handleMyMessageType(Map<String, dynamic> data, String from) async {
  LoggerService.log('MessageService: Handling my message type');
  
  // 1. Валидация
  if (!data.containsKey('required_field')) {
    LoggerService.log('MessageService: Invalid data, skipping');
    return;
  }
  
  // 2. Обработка
  final value = data['required_field'] as String;
  
  // 3. Сохранение в БД
  await StorageService.saveMyData(
    accountEmail: accountEmail,
    from: from,
    value: value,
  );
  
  LoggerService.log('MessageService: My message type handled');
}
```

### Паттерн 8: Добавление нового типа сообщений

```dart
// 1. В MessageService._processMessage() добавь:
if (parsed['type'] == 'my_new_type') {
  await _handleMyNewType(parsed, from);
}

// 2. Создай handler:
Future<void> _handleMyNewType(Map<String, dynamic> data, String from) async {
  // Обработка
}

// 3. В UI просто загружай из БД:
final data = await StorageService.getMyNewTypeData(email);
```

### Паттерн 9: Pending Callbacks (для late инициализации)

```dart
// В сервисе с late полями
class MyService {
  late final SubService _subService;
  bool _initialized = false;
  
  // Храним callbacks до инициализации
  final List<Function()> _pendingCallbacks = [];
  
  void addCallback(Function() callback) {
    if (_initialized) {
      _subService.addCallback(callback);  // Сразу регистрируем
    } else {
      _pendingCallbacks.add(callback);  // Сохраняем на потом
    }
  }
  
  Future<void> initialize() async {
    _subService = SubService();
    
    // Передаём все pending callbacks
    for (final callback in _pendingCallbacks) {
      _subService.addCallback(callback);
    }
    _pendingCallbacks.clear();
    
    _initialized = true;
  }
}
```

### Паттерн 10: НЕ дублируй действия callback

```dart
// ❌ ПЛОХО - дублирование
Future<void> _onRefresh() async {
  await _service.fetchData();  // → вызывает callback
  await _loadData();           // ← callback уже это делает!
}

// ✅ ХОРОШО - callback делает всё
Future<void> _onRefresh() async {
  await _service.fetchData();  // → callback сам загрузит данные
  // Показываем уведомление
  _showSnackBar('✓ Обновлено');
}
```

### Паттерн 11: Безопасная отправка с сохранением

```dart
// ✅ ПРАВИЛЬНЫЙ порядок
Future<void> _sendInvite() async {
  try {
    // 1. СНАЧАЛА отправляем
    await _service.sendInvite(email, pubkey);
    
    // 2. ПОТОМ сохраняем (только если успешно)
    await StorageService.saveContact(email, pubkey);
    
    _showSuccess('Контакт добавлен');
  } catch (e) {
    // Контакт НЕ сохранён, можно повторить
    _showError('Ошибка: $e');
  }
}

// ❌ НЕПРАВИЛЬНЫЙ порядок
Future<void> _sendInvite() async {
  await StorageService.saveContact(email, pubkey);  // ❌ Сначала
  await _service.sendInvite(email, pubkey);         // ❌ Потом
  // Если ошибка → контакт в БД, но invite не отправлен!
}
```

---

## ЛОГИРОВАНИЕ

### Всегда логируй:
```dart
LoggerService.log('ServiceName: Action started');
LoggerService.log('ServiceName: Processing ${items.length} items');
LoggerService.log('ServiceName: ✅ Action completed in ${duration}ms');
LoggerService.log('ServiceName: ❌ Error: $e');
```

### Префиксы:
- `ChatService:` - для ChatService
- `MessageService:` - для MessageService
- `EmailService:` - для EmailService
- `IMAP:` - для IMAP операций
- `SMTP:` - для SMTP операций
- `Screen:` - для UI экранов
- `📱` - для lifecycle событий
- `📖` - для read receipts
- `⏰` - для периодических задач

---

## ТИПИЧНЫЕ ОШИБКИ - НЕ ДЕЛАЙ ТАК

### ❌ Обработка в UI:
```dart
// ПЛОХО
Future<void> _onMessageReceived(MimeMessage msg) async {
  final decrypted = await CryptoService.decrypt(msg); // ❌
  await StorageService.save(decrypted);               // ❌
}
```

### ✅ Правильно - вызов сервиса:
```dart
// ХОРОШО
void _onRefresh() {
  _chatService.fetchAndProcessNewMessages(); // ✅
}
```

### ❌ UI в сервисе:
```dart
// ПЛОХО
class MyService {
  void doSomething() {
    setState(() { ... }); // ❌
    Navigator.push(...);  // ❌
  }
}
```

### ✅ Правильно - callback:
```dart
// ХОРОШО
class MyService {
  void doSomething() {
    // Обработка
    _notifyUI(); // ✅ Уведомляем через callback
  }
}
```

### ❌ Callback ДО инициализации late поля:
```dart
// ПЛОХО
void addCallback(Function() callback) {
  _lateService.addCallback(callback);  // ❌ Crash если не инициализирован!
}
```

### ✅ Правильно - pending callbacks:
```dart
// ХОРОШО
void addCallback(Function() callback) {
  if (_initialized) {
    _lateService.addCallback(callback);
  } else {
    _pendingCallbacks.add(callback);  // ✅ Сохраняем на потом
  }
}
```

### ❌ Дублирование действий callback:
```dart
// ПЛОХО
await _service.fetchData();  // → callback загружает данные
await _loadData();           // ❌ Дублирование!
```

### ✅ Правильно - callback делает всё:
```dart
// ХОРОШО
await _service.fetchData();  // → callback сам загрузит данные
// Только показываем уведомление
```

---

## ЧЕКЛИСТ ПЕРЕД КОММИТОМ

- [ ] Вся бизнес-логика в сервисах?
- [ ] UI только вызывает методы сервисов?
- [ ] Нет обработки данных в UI?
- [ ] Нет UI кода в сервисах?
- [ ] Логи добавлены?
- [ ] Код компилируется?
- [ ] Следую паттернам выше?

---

## ЗАПОМНИ

Используй эти паттерны как шаблоны. Не изобретай велосипед - копируй структуру и адаптируй под свою задачу.
