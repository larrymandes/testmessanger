# Быстрый старт

## Вариант 1: Сборка через GitHub Actions (БЕЗ установки Flutter)

Самый простой способ - GitHub Actions соберёт всё автоматически:

1. Запусти `UPLOAD_TO_GITHUB.bat`
2. Иди на https://github.com/larrymandes/testmessanger/actions
3. Жди 5-10 минут пока соберутся приложения
4. Скачай из Artifacts:
   - `windows-exe` - для Windows
   - `android-apk` - для Android
   - `ios-app` - для iOS

## Вариант 2: Локальная сборка (нужен Flutter)

Если хочешь собрать локально:

1. Установи Flutter: https://flutter.dev/docs/get-started/install
2. Запусти `BEFORE_UPLOAD.bat` (создаст структуру проекта)
3. Запусти приложение: `flutter run`

## Что внутри

- E2EE шифрование (ECDH P-256 + AES-256-GCM)
- IMAP IDLE для мгновенных уведомлений
- QR-коды для обмена ключами
- Read receipts (✓ / ✓✓)
- SQLite для хранения
- Работает БЕЗ серверов - только IMAP/SMTP

## Тестовые аккаунты

Уже прописаны в коде:
- Аккаунт 1: makcim.evgenevich@bk.ru
- Аккаунт 2: xbox.makcim@bk.ru

## Troubleshooting

### GitHub Actions не запускается

Проверь что:
1. Репозиторий публичный или у тебя есть GitHub Actions minutes
2. Файл `.github/workflows/build.yml` загружен
3. В настройках репо включены Actions

### Ошибка при локальной сборке

Запусти `flutter doctor` и исправь проблемы.

Для Windows нужен Visual Studio 2022 с C++ workload.
