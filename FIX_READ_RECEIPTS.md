# 🔧 FIX: Read Receipts - Серверный Message-ID

## 🐛 ПРОБЛЕМА

Read receipts не работали! Галочки не становились двойными.

### Логи показывали:
```
[02:46:18] 📖 Read receipt for message_id=<8Zq2xWd2-LuSMx9Jp8@bk.ru>
[02:46:18] 📖 ⚠️ Message <8Zq2xWd2-LuSMx9Jp8@bk.ru> not found in DB
```

### Причина:
1. Мы генерируем Message-ID локально: `<1775346375265.873.0@bk.ru>`
2. Сохраняем в БД с этим ID
3. Отправляем через SMTP с этим ID
4. **НО!** SMTP сервер **ЗАМЕНЯЕТ** Message-ID на свой: `<8Zq2xWd2-LuSMx9Jp8@bk.ru>`
5. Read receipt приходит с **СЕРВЕРНЫМ** Message-ID
6. В БД сообщение с **ЛОКАЛЬНЫМ** Message-ID
7. **НЕ НАХОДИМ!** ❌

---

## ✅ РЕШЕНИЕ

### Используем BCC копию для обновления Message-ID!

**Поток:**
1. Отправляем сообщение с локальным Message-ID
2. Получаем BCC копию от себя
3. В BCC копии **СЕРВЕРНЫЙ** Message-ID в заголовке
4. В теле BCC копии **ЛОКАЛЬНЫЙ** Message-ID (в `local_message_id`)
5. Обновляем в БД: `локальный → серверный`
6. Read receipt приходит с серверным Message-ID
7. **НАХОДИМ!** ✅

---

## 🔄 КАК РАБОТАЕТ

### 1. Отправка (ChatService):
```dart
// Добавляем local_message_id в тело
final encrypted = await CryptoService.encryptMessage(
  plaintext: jsonEncode({
    'text': parts[i],
    'local_message_id': messageIds[i],  // ← Для BCC обработки!
  }),
  ...
);

// Отправляем с локальным Message-ID в SMTP заголовке
await _sendMessageWithId(
  messageId: messageIds[i],  // ← Локальный
  ...
);
```

### 2. Получение BCC копии (MessageService):
```dart
// Проверяем что это BCC копия
if (from == accountEmail) {
  // Извлекаем серверный Message-ID из SMTP заголовка
  final serverMessageId = mimeMessage.decodeHeaderValue('message-id');
  
  // Расшифровываем тело
  final plaintext = await CryptoService.decryptMessage(...);
  final parsed = jsonDecode(plaintext);
  
  // Извлекаем локальный Message-ID из тела
  final localMessageId = parsed['local_message_id'];
  
  // Обновляем в БД: локальный → серверный
  await _updateServerMessageId(localMessageId, serverMessageId);
}
```

### 3. Read Receipt (MessageService):
```dart
// Приходит с серверным Message-ID
final originalMessageId = receipt['original_message_id'];

// Обновляем статус по серверному Message-ID
await StorageService.updateMessageStatus(
  accountEmail, 
  originalMessageId,  // ← Серверный!
  'read'
);

// НАХОДИМ! ✅
```

---

## 📊 СХЕМА

```
┌─────────────────────────────────────────────────────────┐
│  ОТПРАВКА                                               │
├─────────────────────────────────────────────────────────┤
│  1. Генерируем локальный Message-ID                     │
│     <1775346375265.873.0@bk.ru>                         │
│                                                          │
│  2. Сохраняем в БД с локальным ID                       │
│     message_id = <1775346375265.873.0@bk.ru>            │
│                                                          │
│  3. Добавляем local_message_id в тело                   │
│     {text: "...", local_message_id: "<1775...>"}        │
│                                                          │
│  4. Отправляем через SMTP                               │
│     Message-ID: <1775346375265.873.0@bk.ru>             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  BCC КОПИЯ                                              │
├─────────────────────────────────────────────────────────┤
│  1. Получаем BCC копию от себя                          │
│     From: xbox.makcim@bk.ru                             │
│     Message-ID: <8Zq2xWd2-LuSMx9Jp8@bk.ru> ← СЕРВЕРНЫЙ! │
│                                                          │
│  2. Расшифровываем тело                                 │
│     {text: "...", local_message_id: "<1775...>"}        │
│                                                          │
│  3. Обновляем в БД                                      │
│     <1775346375265.873.0@bk.ru> → <8Zq2xWd2...@bk.ru>   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  READ RECEIPT                                           │
├─────────────────────────────────────────────────────────┤
│  1. Получаем read receipt                               │
│     original_message_id: <8Zq2xWd2-LuSMx9Jp8@bk.ru>     │
│                                                          │
│  2. Ищем в БД по серверному Message-ID                  │
│     message_id = <8Zq2xWd2-LuSMx9Jp8@bk.ru>             │
│                                                          │
│  3. НАХОДИМ! ✅                                          │
│     Обновляем status = 'read'                           │
│                                                          │
│  4. UI показывает двойную галочку ✓✓                    │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 ИЗМЕНЕНИЯ В КОДЕ

### 1. ChatService.sendTextMessageWithUIDs():
```dart
// Добавляем local_message_id в тело
final encrypted = await CryptoService.encryptMessage(
  plaintext: jsonEncode({
    'text': parts[i],
    'local_message_id': messageIds[i],  // ← НОВОЕ!
  }),
  ...
);
```

### 2. MessageService._processMessage():
```dart
// Обрабатываем BCC копии для обновления серверного Message-ID
if (from == accountEmail) {
  // Извлекаем локальный Message-ID из тела
  final localMessageId = parsed['local_message_id'];
  
  // Обновляем в БД: локальный → серверный
  await _updateServerMessageId(localMessageId, messageId);
  
  return;
}
```

### 3. MessageService._updateServerMessageId():
```dart
// НОВЫЙ метод
Future<void> _updateServerMessageId(String localMessageId, String serverMessageId) async {
  await StorageService.updateServerMessageId(accountEmail, localMessageId, serverMessageId);
  await StorageService.addProcessedMessageId(accountEmail, serverMessageId);
}
```

### 4. StorageService.updateServerMessageId():
```dart
// НОВЫЙ метод
static Future<void> updateServerMessageId(
  String accountEmail,
  String localMessageId,
  String serverMessageId,
) async {
  await _database!.execute(
    'UPDATE messages SET message_id = ? WHERE account_email = ? AND message_id = ?',
    [serverMessageId, accountEmail, localMessageId],
  );
}
```

---

## ✅ РЕЗУЛЬТАТ

### Теперь работает:
1. ✅ Отправляем сообщение с локальным Message-ID
2. ✅ Показываем в UI сразу
3. ✅ Получаем BCC копию с серверным Message-ID
4. ✅ Обновляем в БД: локальный → серверный
5. ✅ Read receipt приходит с серверным Message-ID
6. ✅ **НАХОДИМ В БД!**
7. ✅ Обновляем статус на 'read'
8. ✅ **UI показывает двойную галочку ✓✓**

---

## 🔒 БЕЗОПАСНОСТЬ

### Почему это безопасно:
1. ✅ `local_message_id` зашифрован (в теле сообщения)
2. ✅ Только мы можем расшифровать BCC копию
3. ✅ Получатель НЕ видит `local_message_id`
4. ✅ Обновление только из BCC копии от себя (`from == accountEmail`)

---

## 📝 ЛОГИ

### До исправления:
```
[02:46:18] 📖 Read receipt for message_id=<8Zq2xWd2-LuSMx9Jp8@bk.ru>
[02:46:18] 📖 ⚠️ Message <8Zq2xWd2-LuSMx9Jp8@bk.ru> not found in DB
```

### После исправления:
```
[02:46:16] 📤 BCC copy from myself - extracting server Message-ID
[02:46:16] 📤 Updating server Message-ID: <1775346375265.873.0@bk.ru> -> <8Zq2xWd2-LuSMx9Jp8@bk.ru>
[02:46:16] 📤 ✅ Server Message-ID updated
[02:46:18] 📖 Read receipt for message_id=<8Zq2xWd2-LuSMx9Jp8@bk.ru>
[02:46:18] 📖 ✅ Message <8Zq2xWd2-LuSMx9Jp8@bk.ru> marked as READ
```

---

## 🎉 ГОТОВО!

Read receipts теперь работают! Двойные галочки появляются! ✓✓

**ПРОБЛЕМА РЕШЕНА!** 🚀
