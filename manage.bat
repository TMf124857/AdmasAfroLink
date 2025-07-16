@echo off
REM Odoo Enterprise Docker Setup Script for Windows
REM This script helps set up and manage the Odoo Enterprise Docker environment

setlocal enabledelayedexpansion

REM Function to print colored output (simplified for Windows)
:print_status
echo [INFO] %~1
goto :eof

:print_warning
echo [WARNING] %~1
goto :eof

:print_error
echo [ERROR] %~1
goto :eof

:print_header
echo %~1
goto :eof

REM Function to check if Docker is running
:check_docker
docker info >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker is not running. Please start Docker and try again."
    exit /b 1
)
call :print_status "Docker is running"
goto :eof

REM Function to check if docker-compose is available
:check_docker_compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    call :print_error "docker-compose is not installed. Please install docker-compose and try again."
    exit /b 1
)
call :print_status "docker-compose is available"
goto :eof

REM Function to create .env file from example
:setup_env
if not exist .env (
    if exist .env.example (
        copy .env.example .env >nul
        call :print_warning "Created .env file from .env.example. Please review and update the values."
    ) else (
        call :print_error ".env.example file not found. Cannot create .env file."
        exit /b 1
    )
) else (
    call :print_status ".env file already exists"
)
goto :eof

REM Function to start services
:start_services
set "profile="
set "profile_name=%~1"

if "%profile_name%"=="all" (
    set "profile=--profile tools --profile proxy"
) else if "%profile_name%"=="tools" (
    set "profile=--profile tools"
) else if "%profile_name%"=="proxy" (
    set "profile=--profile proxy"
)

if "%profile_name%"=="" set "profile_name=core"

call :print_status "Starting services with profile: %profile_name%"
docker-compose %profile% up -d

call :print_status "Services started successfully!"
call :print_status "Odoo will be available at: http://localhost:8069"

if "%profile_name%"=="tools" (
    call :print_status "pgAdmin will be available at: http://localhost:5050"
)
if "%profile_name%"=="all" (
    call :print_status "pgAdmin will be available at: http://localhost:5050"
)
goto :eof

REM Function to stop services
:stop_services
call :print_status "Stopping all services..."
docker-compose down
call :print_status "Services stopped successfully!"
goto :eof

REM Function to show status
:show_status
call :print_header "=== Service Status ==="
docker-compose ps
goto :eof

REM Function to show logs
:show_logs
set "service=%~1"
if "%service%"=="" (
    docker-compose logs -f
) else (
    docker-compose logs -f %service%
)
goto :eof

REM Function to backup database
:backup_database
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do set "mydate=%%c%%a%%b"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "mytime=%%a%%b"
set "backup_file=backup_%mydate%_%mytime%.sql"

call :print_status "Creating database backup: %backup_file%"
docker-compose exec -T db pg_dump -U odoo odoo > %backup_file%
call :print_status "Backup created successfully: %backup_file%"
goto :eof

REM Function to restore database
:restore_database
set "backup_file=%~1"
if "%backup_file%"=="" (
    call :print_error "Please specify backup file to restore"
    exit /b 1
)

if not exist "%backup_file%" (
    call :print_error "Backup file not found: %backup_file%"
    exit /b 1
)

call :print_warning "This will overwrite the current database. Are you sure? (y/N)"
set /p confirm=
if /i "%confirm%"=="y" (
    call :print_status "Restoring database from: %backup_file%"
    docker-compose exec -T db psql -U odoo odoo < %backup_file%
    call :print_status "Database restored successfully"
) else (
    call :print_status "Database restore cancelled"
)
goto :eof

REM Function to update Odoo image
:update_odoo
call :print_status "Pulling latest Odoo image..."
docker-compose pull odoo

call :print_status "Recreating Odoo container..."
docker-compose up -d --force-recreate odoo

call :print_status "Odoo updated successfully!"
goto :eof

REM Function to show help
:show_help
call :print_header "=== Odoo Enterprise Docker Management Script ==="
echo.
echo Usage: %0 [COMMAND] [OPTIONS]
echo.
echo Commands:
echo   setup           - Initial setup (create .env file)
echo   start [PROFILE] - Start services (core/tools/proxy/all)
echo   stop            - Stop all services
echo   restart         - Restart all services
echo   status          - Show service status
echo   logs [SERVICE]  - Show logs (all services or specific service)
echo   backup          - Create database backup
echo   restore FILE    - Restore database from backup file
echo   update          - Update Odoo to latest version
echo   clean           - Remove all containers and volumes (CAUTION)
echo   help            - Show this help message
echo.
echo Examples:
echo   %0 setup
echo   %0 start
echo   %0 start tools
echo   %0 start all
echo   %0 logs odoo
echo   %0 backup
echo   %0 restore backup_20231216_143022.sql
goto :eof

REM Main script logic
set "command=%~1"
set "option=%~2"

if "%command%"=="setup" (
    call :check_docker
    call :check_docker_compose
    call :setup_env
) else if "%command%"=="start" (
    call :check_docker
    call :check_docker_compose
    call :setup_env
    call :start_services %option%
) else if "%command%"=="stop" (
    call :stop_services
) else if "%command%"=="restart" (
    call :stop_services
    timeout /t 2 /nobreak >nul
    call :start_services %option%
) else if "%command%"=="status" (
    call :show_status
) else if "%command%"=="logs" (
    call :show_logs %option%
) else if "%command%"=="backup" (
    call :backup_database
) else if "%command%"=="restore" (
    call :restore_database %option%
) else if "%command%"=="update" (
    call :update_odoo
) else if "%command%"=="clean" (
    call :print_warning "This will remove all containers and volumes. All data will be lost!"
    call :print_warning "Are you sure? Type 'DELETE' to confirm:"
    set /p confirm=
    if "!confirm!"=="DELETE" (
        docker-compose down -v
        docker system prune -f
        call :print_status "Cleanup completed"
    ) else (
        call :print_status "Cleanup cancelled"
    )
) else if "%command%"=="help" (
    call :show_help
) else if "%command%"=="" (
    call :show_help
) else (
    call :print_error "Unknown command: %command%"
    call :show_help
    exit /b 1
)
