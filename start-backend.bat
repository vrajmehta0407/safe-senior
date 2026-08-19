@echo off
title Safe Senior Backend
echo.
echo  ╔══════════════════════════════════════════╗
echo  ║     Safe Senior — Starting Backend       ║
echo  ╚══════════════════════════════════════════╝
echo.

cd /d "D:\safe senior\backend"

:: Check if port 3000 is already in use
netstat -ano | findstr ":3000 " | findstr "LISTENING" >nul 2>&1
if %errorlevel%==0 (
  echo  [WARNING] Port 3000 is already in use!
  echo  If the backend is already running, you can close this window.
  echo.
  pause
  exit /b 0
)

echo  Starting backend on port 3000...
echo  Admin Panel: http://localhost:3000/api/ops-4e9f2c1a
echo  Press Ctrl+C to stop.
echo.

node src/index.js
pause
