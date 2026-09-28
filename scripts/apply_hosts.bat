@echo off
chcp 65001 >nul
title LikeProxy - Применение настроек

:: 1. Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ОШИБКА: Запустите этот скрипт от имени Администратора!
    echo Нажмите правой кнопкой мыши на apply_hosts.bat и выберите "Запуск от имени администратора".
    pause
    exit /b
)

echo [+] Начало применения настроек LikeProxy...
set HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts
:: Путь к файлу относительно папки scripts (поднимается на уровень выше, в папку hosts)
set CUSTOM_HOSTS=..\hosts\custom_hosts.txt

:: 2. Создание резервной копии
echo [+] Создание резервной копии исходного файла hosts...
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
copy "%HOSTS_FILE%" "%HOSTS_FILE%.backup_%datetime:~0,8%" >nul

:: 3. Добавление наших записей
echo [+] Добавление записей из custom_hosts.txt...
echo. >> "%HOSTS_FILE%"
echo # === LIKEPROXY START === >> "%HOSTS_FILE%"
type "%CUSTOM_HOSTS%" >> "%HOSTS_FILE%"
echo # === LIKEPROXY END === >> "%HOSTS_FILE%"

:: 4. Очистка DNS-кэша
echo [+] Очистка DNS-кэша Windows...
ipconfig /flushdns >nul

echo.
echo [!] ГОТОВО! Теперь запросы к ИИ будут перенаправляться через прокси.
echo [!] Чтобы отменить изменения, запустите скрипт remove_hosts.bat от имени администратора.
echo.
pause