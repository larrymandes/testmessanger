@echo off
echo ========================================
echo Загрузка на GitHub
echo ========================================
echo.

cd /d "%~dp0"

git init
git add .
git commit -m "Initial commit - Secure Messenger"
git branch -M main
git remote add origin https://github.com/larrymandes/testmessanger.git
git push -u origin main

echo.
echo ========================================
echo Готово! Код загружен на GitHub
echo ========================================
echo.
echo Теперь иди на https://github.com/larrymandes/testmessanger/actions
echo и жди пока соберутся приложения
echo.
pause
