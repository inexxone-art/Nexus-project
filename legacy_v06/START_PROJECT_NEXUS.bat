@echo off
chcp 65001 >nul
cd /d "%~dp0"
title PROJECT NEXUS - ALPINE WORLD V0.6
echo PROJECT NEXUS V0.6 - OFFLINE 3D ALPHA
echo Erforderlich: Chrome oder Microsoft Edge mit WebGL2.
echo Die Grafik im Startbildschirm ist ein KONZEPTBILD, keine Ingame-Aufnahme.
start "" "%~dp0index.html"
if errorlevel 1 (
  echo Bitte index.html manuell mit Chrome oder Edge oeffnen.
  pause
)
