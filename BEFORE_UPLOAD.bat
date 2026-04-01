@echo off
echo ========================================
echo Подготовка Flutter проекта
echo ========================================
echo.

cd /d "%~dp0"

echo Проверка Flutter...
flutter --version
if errorlevel 1 (
    echo.
    echo ОШИБКА: Flutter не установлен!
    echo Скачай с https://flutter.dev/docs/get-started/install
    echo.
    echo Или используй GitHub Actions для сборки без установки Flutter
    echo Просто запусти UPLOAD_TO_GITHUB.bat
    echo.
    pause
    exit /b 1
)

echo.
echo Создание структуры проекта...
flutter create . --platforms=windows,android,ios

echo.
echo Установка зависимостей...
flutter pub get

echo.
echo ========================================
echo Готово! Теперь можешь:
echo ========================================
echo 1. Запустить локально: flutter run
echo 2. Собрать для Windows: flutter build windows --release
echo 3. Загрузить на GitHub: UPLOAD_TO_GITHUB.bat
echo.
pause
