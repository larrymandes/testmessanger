@echo off
echo ========================================
echo Загрузка на GitHub
echo ========================================
echo.

cd /d "%~dp0"

echo Проверка структуры проекта...
if not exist "android" (
    echo.
    echo ВНИМАНИЕ: Проект не инициализирован!
    echo Это нормально - GitHub Actions создаст структуру автоматически
    echo.
    echo Если хочешь собрать локально, сначала запусти BEFORE_UPLOAD.bat
    echo.
    timeout /t 3 >nul
)

echo Инициализация git...
git init

echo Добавление файлов...
git add .

echo Создание коммита...
git commit -m "Initial commit - Secure Messenger"

echo Настройка ветки...
git branch -M main

echo Добавление remote...
git remote remove origin 2>nul
git remote add origin git@github.com:larrymandes/testmessanger.git

echo Загрузка на GitHub...
git push -u origin main --force

echo.
echo ========================================
echo Готово! Код загружен на GitHub
echo ========================================
echo.
echo Теперь иди на https://github.com/larrymandes/testmessanger/actions
echo и жди пока соберутся приложения (5-10 минут)
echo.
echo Скачай готовые файлы из Artifacts:
echo - windows-exe (для Windows)
echo - android-apk (для Android)
echo - ios-app (для iOS)
echo.
pause
