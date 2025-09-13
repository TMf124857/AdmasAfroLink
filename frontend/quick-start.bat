@echo off
echo.
echo ==========================================
echo   AdmasAfroLink Quick Docker Install
echo ==========================================
echo.

REM Create a temporary container to install dependencies
echo Step 1: Installing dependencies using Docker...
echo.

docker run --rm -v "%cd%":/app -w /app node:22-alpine npm install

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to install dependencies
    echo.
    echo Please make sure:
    echo 1. Docker Desktop is running
    echo 2. You have internet connection
    echo 3. You're in the correct directory
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Dependencies installed successfully!
echo.

echo Step 2: Starting development server...
echo.
echo The AdmasAfroLink frontend will be available at:
echo 🌐 http://localhost:3000
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start development server
docker run --rm -it -v "%cd%":/app -w /app -p 3000:3000 node:22-alpine npm run dev
