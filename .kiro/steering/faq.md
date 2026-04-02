---
inclusion: always
---

# FAQ - Частые вопросы

## Вопрос: Где добавить новую функцию?

**Ответ**: Спроси себя - это бизнес-логика или UI?

- **Бизнес-логика** (обработка данных, работа с сервером/БД):
  - → Добавь в сервис (`lib/services/`)
  - → UI только вызывает метод сервиса

- **UI логика** (отображение, анимации, навигация):
  - → Добавь в экран (`lib/screens/`)
  - → Но если нужны данные - вызови сервис

---

## Вопрос: Как сделать fetch при открытии приложения?

**Ответ**: Уже реализовано!

```dart
// В ChatListScreen.didChangeAppLifecycleState
if (state == AppLifecycleState.resumed) {
  _chatService.fetchAndProcessNewMessages();
}
```

Также fetch делается при первом запуске в `_initialize()`.

---

## Вопрос: Как добавить новый тип сообщений?

**Ответ**: 

1. В `MessageService._processMessage()` добавь:
```dart
if (parsed['type'] == 'my_type') {
  await _handleMyType(parsed, from);
}
```

2. Создай handler в `MessageService`:
```dart
Future<void> _handleMyType(Map<String, dynamic> data, String from) async {
  // Обработка и сохранение в БД
}
```

3. В UI просто загружай из БД:
```dart
final data = await StorageService.getMyTypeData(email);
```

---

## Вопрос: Почему сообщения не приходят когда приложение закрыто?

**Ответ**: Это нормально! IDLE loop останавливается когда приложение закрыто.

**Решение**: При открытии приложения делается fetch:
- `AppLifecycleState.resumed` → `fetchAndProcessNewMessages()`
- Первый запуск → `fetchAndProcessNewMessages()`

---

## Вопрос: Как обновить UI после изменения данных?

**Ответ**: Через callbacks!

1. Сервис обрабатывает данные и сохраняет в БД
2. Сервис вызывает `_notifyUI()`
3. UI callback загружает из БД
4. UI вызывает `setState()`

```dart
// В сервисе
_notifyUI(); // Уведомляем UI

// В UI callback
_chatService.addUICallback(() {
  if (mounted) {
    _loadData(); // Загружаем из БД
  }
});
```

---

## Вопрос: Где хранить состояние?

**Ответ**: 

- **Данные приложения** (сообщения, контакты) → БД (StorageService)
- **UI состояние** (loading, selected item) → State в экране
- **Бизнес-логика** → Сервисы

**НЕ храни данные приложения в State!**

---

## Вопрос: Как сделать чтобы экран обновлялся автоматически?

**Ответ**: Зарегистрируй callback!

```dart
@override
void initState() {
  super.initState();
  
  _callback = () {
    if (mounted) {
      _loadData(); // Загружаем из БД
    }
  };
  
  _chatService.addUICallback(_callback);
  _loadData(); // Начальная загрузка
}

@override
void dispose() {
  _chatService.removeUICallback(_callback);
  super.dispose();
}
```

---

## Вопрос: Можно ли вызывать сервис напрямую из UI?

**Ответ**: ДА! Это правильно!

```dart
// ✅ ПРАВИЛЬНО
void _onButtonPressed() {
  _chatService.myMethod();
}
```

**НО** не делай обработку в UI:

```dart
// ❌ НЕПРАВИЛЬНО
void _onButtonPressed() {
  final data = await _emailService.fetch(); // ❌
  final decrypted = await decrypt(data);    // ❌
  await StorageService.save(decrypted);     // ❌
}
```

---

## Вопрос: Как отлаживать проблемы?

**Ответ**: 

1. Открой LogsScreen (кнопка в AppBar)
2. Все логи имеют префикс сервиса
3. Проверь поток: Событие → Сервис → БД → UI
4. Проверь что callbacks зарегистрированы

Типичные проблемы:
- Callback не зарегистрирован → UI не обновляется
- Обработка в UI → дублирование логики
- Нет логов → непонятно что происходит

---

## Вопрос: Как добавить периодическую задачу?

**Ответ**: Используй Timer в UI (для UI задач) или в сервисе (для бизнес-логики).

```dart
// В UI (для периодического обновления UI)
Timer.periodic(Duration(seconds: 30), (timer) {
  if (mounted) {
    _loadData(); // Загружаем из БД
  }
});

// В сервисе (для периодического fetch)
Timer.periodic(Duration(minutes: 5), (timer) async {
  await fetchAndProcessNewMessages();
});
```

---

## Вопрос: Почему нельзя делать обработку в UI?

**Ответ**: 

1. **Дублирование кода** - если обработка в нескольких экранах
2. **Сложно тестировать** - UI тесты сложнее unit тестов
3. **Сложно поддерживать** - логика размазана по экранам
4. **Race conditions** - разные экраны обрабатывают параллельно

**Правильно**: Одна точка обработки в сервисе, UI только отображает.

---

## Вопрос: Как работает IDLE?

**Ответ**: 

1. EmailService подключается к IMAP
2. Запускается IDLE loop
3. При новом письме IDLE событие
4. Вызывается `_messageProcessor`
5. Fetch + обработка через MessageService
6. Уведомление UI через callbacks

**Важно**: IDLE работает только когда приложение открыто!

---

## Вопрос: Что делать если приложение крашится?

**Ответ**: 

1. Проверь логи (LogsScreen)
2. Проверь что все `await` на месте
3. Проверь что `mounted` проверяется перед `setState`
4. Проверь что нет null pointer exceptions
5. Добавь try-catch с логированием

```dart
try {
  await _chatService.myMethod();
} catch (e) {
  LoggerService.log('Error: $e');
  if (mounted) {
    _showError(e.toString());
  }
}
```

---

## Вопрос: Как добавить новый экран?

**Ответ**: 

1. Создай файл в `lib/screens/`
2. Передай `ChatService` в конструктор
3. Зарегистрируй callback в `initState`
4. Загружай данные из БД
5. Вызывай методы сервиса для действий

```dart
class MyScreen extends StatefulWidget {
  final ChatService chatService;
  
  const MyScreen({required this.chatService});
}
```

---

## Вопрос: Можно ли использовать Provider/Riverpod?

**Ответ**: Можно, но не обязательно.

Текущая архитектура с callbacks работает отлично. Если хочешь добавить state management:

1. Оберни `ChatService` в Provider
2. UI получает через `context.read<ChatService>()`
3. Callbacks можно заменить на `notifyListeners()`

Но это не обязательно - текущая архитектура production-ready.

---

## ЗАПОМНИ

- Вся бизнес-логика в сервисах
- UI только вызывает методы и отображает
- Один источник истины - БД
- Callbacks для уведомления UI
- Логи для отладки

Если сомневаешься - посмотри существующий код и сделай аналогично!
