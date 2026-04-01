# Установка и запуск

## Быстрый старт (без установки Flutter локально)

1. Загрузи код на GitHub используя `UPLOAD_TO_GITHUB.bat`
2. Иди на https://github.com/larrymandes/testmessanger/actions
3. Жди пока GitHub Actions соберёт приложения
4. Скачай готовые .exe, .apk, .ipa из Artifacts

## Локальная разработка

### Требования

- Flutter SDK 3.0+
- Dart 3.0+
- Windows 10/11 (для Windows сборки)
- Android Studio (для Android)
- Xcode (для iOS, только на macOS)

### Установка Flutter

#### Windows

1. Скачай Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Распакуй в `C:\flutter`
3. Добавь в PATH: `C:\flutter\bin`
4. Проверь: `flutter doctor`

### Инициализация проекта

```bash
cd flutter_app
flutter create . --platforms=windows,android,ios
flutter pub get
```

### Запуск

```bash
flutter run
```

## Сборка для разных платформ

### Windows (.exe)

```bash
flutter build windows --release
```

Готовый .exe: `build/windows/x64/runner/Release/secure_messenger.exe`

### Android (.apk)

```bash
flutter build apk --release
```

Готовый .apk: `build/app/outputs/flutter-apk/app-release.apk`

### iOS (.ipa)

```bash
flutter build ios --release
```

## Настройка аккаунтов

Пароли уже прописаны в `account_select_screen.dart` для двух тестовых аккаунтов Mail.ru.

Для production используй `flutter_secure_storage` для безопасного хранения паролей.

## Структура проекта

```
lib/
├── main.dart                       # Точка входа
├── screens/
│   ├── account_select_screen.dart  # Выбор аккаунта
│   ├── chat_list_screen.dart       # Список чатов
│   ├── chat_screen.dart            # Экран чата
│   └── qr_screen.dart              # QR-коды
└── services/
    ├── crypto_service.dart         # E2EE криптография
    ├── email_service.dart          # IMAP/SMTP
    └── storage_service.dart        # SQLite хранилище
```

## Troubleshooting

### Ошибка "SDK not found"
```bash
flutter doctor
flutter config --android-sdk <path>
```

### Ошибка сборки Windows
Установи Visual Studio 2022 с C++ workload

### Ошибка IMAP/SMTP
Проверь пароли приложений в Mail.ru

## Размеры сборок

- Windows: ~15-20 MB
- Android: ~20-25 MB
- iOS: ~25-30 MB
