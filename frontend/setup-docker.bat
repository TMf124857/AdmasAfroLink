@echo off
echo Checking Docker status...
echo.

REM Check if Docker Desktop is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker Desktop is not running.
    echo.
    echo Please:
    echo 1. Start Docker Desktop from your Start Menu
    echo 2. Wait for Docker to fully start (check system tray)
    echo 3. Run this script again
    echo.
    echo If Docker Desktop is not installed:
    echo - Visit: https://docker.com/get-started/
    echo - Download Docker Desktop for Windows
    echo - Install and restart your computer
    echo.
    pause
    exit /b 1
)

echo Docker is running! ✓
echo.

REM Pull Node.js image
echo Pulling Node.js 22 Alpine image...
docker pull node:22-alpine

if %errorlevel% neq 0 (
    echo Failed to pull Node.js image
    pause
    exit /b 1
)

echo.
echo ✅ Docker setup complete!
echo.
echo Next steps:
echo 1. Run: docker-run.bat
echo 2. Choose option 1 (Start Development Server)
echo 3. Open: http://localhost:3000
echo.
pause
