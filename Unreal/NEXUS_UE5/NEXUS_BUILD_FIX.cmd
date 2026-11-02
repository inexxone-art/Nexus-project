@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0NEXUS_BUILD_FIX.ps1"
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" echo Bitte Fehlermeldung und Saved\Logs\NEXUS_Compile.log an ChatGPT senden.
pause
exit /b %RC%
