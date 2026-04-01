# Secure Messenger - E2EE over Email

Защищённый мессенджер с end-to-end шифрованием через email протоколы.

## Особенности

- ✅ E2EE шифрование (ECDH P-256 + AES-256-GCM)
- ✅ Без собственных серверов - только IMAP/SMTP
- ✅ IMAP IDLE для мгновенных уведомлений
- ✅ QR-коды для обмена ключами (MITM защита)
- ✅ Read receipts (статусы прочитано/не прочитано)
- ✅ Современный UI в стиле Telegram
- ✅ Кросс-платформа (Android, iOS, Windows)
- ✅ Forward secrecy через ephemeral ключи
- ✅ Автоматическая сборка через GitHub Actions

## Установка

Самый простой способ - использовать GitHub Actions для автоматической сборки:

1. Загрузи код на GitHub: запусти `UPLOAD_TO_GITHUB.bat`
2. Иди на https://github.com/larrymandes/testmessanger/actions
3. Скачай готовые приложения из Artifacts

Для локальной разработки смотри [SETUP.md](SETUP.md)

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

- [ ] Группы (рассылка на несколько контактов)
- [ ] Файлы и изображения
- [ ] Push уведомления (Android/iOS)
- [ ] Голосовые сообщения
- [ ] Поиск по сообщениям

## Безопасность

- Приватные ключи хранятся только локально
- Сервер email видит только зашифрованные данные
- Forward secrecy через ephemeral ключи
- MITM защита через QR-коды

## Лицензия

MIT
