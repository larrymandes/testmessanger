@echo off
chcp 65001 >nul
echo ═══════════════════════════════════════════════════════════
echo   ЗАГРУЗКА НА GITHUB
echo ═══════════════════════════════════════════════════════════
echo.

cd /d "%~dp0"

echo [1/5] Добавление всех файлов...
git add .

echo [2/5] Создание коммита...
git commit -m "Flutter app ready - E2EE messenger with IMAP/SMTP"

echo [3/5] Проверка remote...
git remote -v

echo [4/5] Загрузка на GitHub...
git push origin main

echo.
echo ═══════════════════════════════════════════════════════════
echo   ✅ ГОТОВО! КОД ЗАГРУЖЕН НА GITHUB
echo ═══════════════════════════════════════════════════════════
echo.
echo Теперь:
echo.
echo 1. Иди на https://github.com/larrymandes/testmessanger/actions
echo 2. Жди 5-10 минут пока соберутся приложения
echo 3. Скачай из Artifacts:
echo    • windows-exe (для Windows)
echo    • android-apk (для Android)
echo    • ios-app (для iOS)
echo.
pause
