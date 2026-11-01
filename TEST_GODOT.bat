@echo off
setlocal
cd /d "%~dp0"
set "ENGINE=godot"
where godot.exe >nul 2>&1 || (where godot4.exe >nul 2>&1 && set "ENGINE=godot4")
where %ENGINE% >nul 2>&1 || (
  echo Godot ist nicht im PATH. Bitte erst project.godot einmal im Godot-Editor importieren.
  pause
  exit /b 2
)
%ENGINE% --headless --editor --import --path "%~dp0" --quit
if errorlevel 1 (
  echo Asset-Import fehlgeschlagen.
  pause
  exit /b 3
)
%ENGINE% --headless --path "%~dp0" --script res://tests/smoke.gd
if errorlevel 1 (
  echo Godot-Test nicht bestanden. Bitte Fehlermeldung senden.
  pause
  exit /b 1
)
echo Projekt Smoke-Test bestanden.
pause
endlocal
