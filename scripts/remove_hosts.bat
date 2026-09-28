@echo off
chcp 65001 >nul
title LikeProxy - Удаление настроек

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ОШИБКА: Запустите этот скрипт от имени Администратора!
    pause
    exit /b
)

echo [+] Удаление настроек LikeProxy...
set HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts
set TEMP_HOSTS=%TEMP%\hosts_temp

:: Удаляем блок между LIKEPROXY START и LIKEPROXY END с помощью PowerShell (встроен в Windows)
powershell -Command "(Get-Content '%HOSTS_FILE%') | Where-Object { $_ -notmatch '# === LIKEPROXY (START|END) ===' -and $_ -notmatch '^(193\.233\.112\.68|103\.137\.248\.179|149\.154\.167\.220|91\.108\.56\.130|216\.24\.57\.7|18\.65\.39\.105)\s' } | Set-Content '%TEMP_HOSTS%'"

:: Заменяем оригинальный файл очищенным
copy /Y "%TEMP_HOSTS%" "%HOSTS_FILE%" >nul
del "%TEMP_HOSTS%"

:: Очистка DNS-кэша
echo [+] Очистка DNS-кэша Windows...
ipconfig /flushdns >nul

echo.
echo [!] ГОТОВО! Настройки LikeProxy удалены из файла hosts.
pause