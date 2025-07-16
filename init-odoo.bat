@echo off
REM Quick Odoo Database Initialization Script for Windows
REM Use this script to initialize the Odoo database if it's not already initialized

echo 🚀 Initializing Odoo Database...

REM Check if Docker Compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: docker-compose is not installed or not in PATH
    exit /b 1
)

REM Check if services are running
docker-compose ps | findstr "Up" >nul
if errorlevel 1 (
    echo ⚠️  Starting required services first...
    docker-compose up -d db redis
    timeout /t 15 /nobreak >nul
)

REM Check if database is already initialized
echo 🔍 Checking if database is already initialized...
docker-compose exec -T db psql -U odoo -d odoo -c "\dt" 2>nul | findstr "ir_module_module" >nul
if not errorlevel 1 (
    echo ✅ Database is already initialized!
    echo 🌐 You can access Odoo at: http://localhost:8069
    exit /b 0
)

REM Stop Odoo if it's running
echo ⏹️  Stopping Odoo service if running...
docker-compose stop odoo 2>nul

REM Initialize the database
echo 🔧 Initializing database with base modules...
echo    This may take a few minutes...

docker-compose run --rm odoo odoo --config=/etc/odoo/odoo.conf -i base --stop-after-init
if errorlevel 1 (
    echo ❌ Failed to initialize database
    echo 💡 Try running: docker-compose logs odoo
    exit /b 1
)

echo ✅ Database initialized successfully!

REM Start all services
echo 🚀 Starting all services...
docker-compose up -d

echo.
echo 🎉 Setup complete!
echo 🌐 Odoo is now available at: http://localhost:8069
echo 👤 Default admin credentials:
echo    Email: admin
echo    Password: admin123
echo.
echo ⚠️  Remember to change the default password in production!
