# Анализ: Как работает FETCH

## 🔄 Наша текущая реализация

### Архитектура:

```
1. IDLE Loop (фоновый)
   ↓ EXISTS увеличился
2. Уведомление UI через Stream
   ↓
3. UI вызывает fetchNewMessages()
   ↓
4. SELECT INBOX → получаем UIDNEXT
   ↓
5. Сравниваем с _lastUidNext
   ↓
6. UID FETCH lastUidNext:* BODY.PEEK[]
   ↓
7. Фильтруем [chat] письма
   ↓
8. Обрабатываем каждое письмо
   ↓
9. Обновляем _lastUidNext
```

### Ключевые моменты:

**✅ Правильно:**
- Используем UIDNEXT для отслеживания
- UIDVALIDITY проверка
- BODY.PEEK[] (не помечает как \Seen)
- Батчинг по 50 писем
- Защита от повторного fetch (_isFetching flag)

**⚠️ Проблемы:**
1. **Fetch вызывается только из UI** - если UI не активен, fetch не происходит
2. **IDLE только уведомляет** - не делает fetch автоматически
3. **Нет автоматического периодического fetch** - полагаемся только на IDLE

## 🎯 Delta Chat реализация

### Архитектура Delta Chat:

```
1. IDLE Loop (фоновый)
   ↓ EXISTS увеличился ИЛИ таймаут 29 мин
2. АВТОМАТИЧЕСКИЙ fetch_new_messages()
   ↓
3. SELECT INBOX → получаем UIDNEXT
   ↓
4. Сравниваем с сохранённым uid_next
   ↓
5. UID FETCH с батчингом (~1000 символов в команде)
   ↓
6. Prefetch headers (ENVELOPE, FLAGS)
   ↓
7. Фильтрация (spam, DeltaChat folder)
   ↓
8. Полный fetch только нужных писем
   ↓
9. Обработка + сохранение в БД
   ↓
10. Обновление uid_next в БД
```

### Ключевые отличия:

| Аспект | Наша реализация | Delta Chat |
|--------|-----------------|------------|
| **Триггер fetch** | UI вызывает вручную | Автоматически в IDLE loop |
| **Периодичность** | Только при IDLE событии | IDLE событие + каждые 29 мин |
| **Prefetch** | Нет - сразу BODY.PEEK[] | Да - сначала ENVELOPE |
| **Батчинг** | По 50 писем | По ~1000 символов команды |
| **Фоновая работа** | Нет | Да - работает без UI |
| **Папки** | Только INBOX | INBOX + DeltaChat + Spam |

## 🔧 Что нужно исправить

### Проблема 1: Fetch не работает в фоне

**Сейчас:**
```dart
// IDLE только уведомляет UI
_emailService.listenForNewMessages().listen((_) {
  _fetchNewMessages(); // ← Вызывается только если UI слушает
});
```

**Должно быть:**
```dart
// IDLE сам делает fetch
void _startIdleLoop() async {
  while (_isIdleRunning) {
    // ... IDLE ...
    
    // Если было событие ИЛИ таймаут - делаем fetch
    if (completer.isCompleted || timeout) {
      await _fetchNewMessagesInternal(); // ← Внутренний fetch
      _notifyUI(); // ← Потом уведомляем UI
    }
  }
}
```

### Проблема 2: Нет периодического fetch

**Delta Chat:**
- Каждые 29 минут делает fetch даже если нет IDLE событий
- Защита от "застрявших" соединений
- Гарантия получения писем

**Наше решение:**
```dart
// После IDLE таймаута (29 мин) - всегда fetch
await Future.any([
  completer.future,
  Future.delayed(const Duration(minutes: 29)),
]);

// ВСЕГДА делаем fetch после IDLE
await _fetchNewMessagesInternal();
```

### Проблема 3: Fetch зависит от UI

**Сейчас:**
- ChatListScreen слушает stream и вызывает fetch
- Если экран не активен - fetch не происходит
- Если приложение в фоне - ничего не работает

**Решение:**
- EmailService сам делает fetch внутри IDLE loop
- UI только слушает уведомления о НОВЫХ сообщениях
- Fetch работает независимо от UI

## ✅ План исправления

### 1. Переместить fetch внутрь IDLE loop

```dart
void _startIdleLoop() async {
  while (_isIdleRunning) {
    try {
      // ... IDLE setup ...
      
      await Future.any([
        completer.future,
        Future.delayed(const Duration(minutes: 29)),
      ]);
      
      await _imapClient!.idleDone();
      await _imapClient!.noop();
      
      // АВТОМАТИЧЕСКИЙ FETCH
      final newMessages = await _fetchNewMessagesInternal();
      
      // Уведомляем UI только если есть новые
      if (newMessages.isNotEmpty) {
        _newMessageController!.add(newMessages);
      }
      
    } catch (e) {
      // ...
    }
  }
}
```

### 2. Разделить fetch на internal и public

```dart
// Внутренний - вызывается из IDLE
Future<List<MimeMessage>> _fetchNewMessagesInternal() async {
  // ... логика fetch ...
}

// Публичный - для ручного обновления из UI
Future<List<MimeMessage>> fetchNewMessages({int lastSeenUid = 0}) async {
  return await _fetchNewMessagesInternal();
}
```

### 3. Изменить Stream

```dart
// Было: Stream<void> - просто уведомление
Stream<void> listenForNewMessages()

// Должно быть: Stream<List<MimeMessage>> - сами сообщения
Stream<List<MimeMessage>> listenForNewMessages()
```

### 4. Упростить UI

```dart
// ChatListScreen
_emailService.listenForNewMessages().listen((newMessages) {
  // Сообщения уже получены и обработаны
  // Просто обновляем UI
  _loadContacts();
});
```

## 📊 Сравнение производительности

### Текущая реализация:
```
IDLE событие → Уведомление UI → UI вызывает fetch → Обработка
Задержка: ~100-500ms (зависит от UI)
```

### После исправления:
```
IDLE событие → Fetch → Обработка → Уведомление UI
Задержка: ~50-100ms (не зависит от UI)
```

## 🎯 Итог

**Главная проблема:** Fetch зависит от UI, не работает в фоне.

**Решение:** Переместить fetch внутрь IDLE loop, как в Delta Chat.

**Результат:**
- ✅ Сообщения приходят даже если не в чате
- ✅ Работает в фоне
- ✅ Периодический fetch каждые 29 минут
- ✅ Меньше задержка
- ✅ Как Delta Chat

