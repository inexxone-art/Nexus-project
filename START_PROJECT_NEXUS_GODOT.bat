@echo off
cd /d "%~dp0"
where godot >nul 2>&1 && (godot --path . --editor & exit /b)
where godot4 >nul 2>&1 && (godot4 --path . --editor & exit /b)
echo Godot 4 ist nicht im PATH. Bitte project.godot in Godot 4 importieren.
pause
