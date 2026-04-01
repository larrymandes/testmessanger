# Secure Messenger - E2EE over Email

Защищённый мессенджер с end-to-end шифрованием через email протоколы.

## Особенности

- ✅ E2EE шифрование (ECDH P-256 + AES-256-GCM)
- ✅ Без собственных серверов - только IMAP/SMTP
- ✅ IMAP IDLE для мгновенных уведомлений
- ✅ QR-коды для обмена ключами
- ✅ Современный UI (Flyer Chat)
- ✅ Кросс-платформа (Android, iOS, Windows, Linux, macOS)

## Установка

1. Установите Flutter: https://flutter.dev/docs/get-started/install

2. Клонируйте репозиторий и установите зависимости:
```bash
cd flutter_app
flutter pub get
```

3. Запустите приложение:
```bash
flutter run
```

## Сборка для Windows

```bash
flutter build windows --release
```

Готовый .exe будет в `build/windows/x64/runner/Release/`

## Сборка для Android

```bash
flutter build apk --release
```

## Сборка для iOS

```bash
flutter build ios --release
```

## Архитектура

```
lib/
├── main.dart                    # Точка входа
├── screens/
│   ├── account_select_screen.dart  # Выбор аккаунта
│   ├── chat_list_screen.dart       # Список чатов
│   └── chat_screen.dart            # Экран чата
└── services/
    ├── crypto_service.dart         # E2EE криптография
    ├── email_service.dart          # IMAP/SMTP
    └── storage_service.dart        # Локальное хранилище
```

## TODO

- [ ] Реализовать полную интеграцию криптографии
- [ ] QR-коды для обмена ключами
- [ ] Локальное хранилище (SQLite)
- [ ] Read receipts
- [ ] Группы (рассылка)
- [ ] Файлы и изображения
- [ ] Push уведомления (Android/iOS)

## Безопасность

- Приватные ключи хранятся только локально
- Сервер email видит только зашифрованные данные
- Forward secrecy через ephemeral ключи
- MITM защита через QR-коды

## Лицензия

MIT
