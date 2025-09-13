@echo off
REM AdmasAfroLink Docker Commands
REM Usage: make.bat [command]

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="dev" goto dev
if "%1"=="prod" goto prod
if "%1"=="build" goto build
if "%1"=="up" goto up
if "%1"=="down" goto down
if "%1"=="logs" goto logs
if "%1"=="shell" goto shell
if "%1"=="test" goto test
if "%1"=="clean" goto clean
if "%1"=="install" goto install
if "%1"=="backup" goto backup
echo Unknown command: %1
goto help

:help
echo.
echo AdmasAfroLink Docker Commands
echo =============================
echo.
echo Development:
echo   make dev     - Start development environment
echo   make install - Install dependencies
echo   make shell   - Open shell in development container
echo   make test    - Run tests
echo.
echo Production:
echo   make prod    - Start production environment
echo   make build   - Build all images
echo.
echo Management:
echo   make up      - Start all services
echo   make down    - Stop all services
echo   make logs    - View logs
echo   make clean   - Clean up containers and images
echo   make backup  - Create backup of data
echo.
echo Examples:
echo   make.bat dev
echo   make.bat prod
echo   make.bat logs
echo.
goto end

:dev
echo Starting development environment...
docker-compose up --build frontend-dev redis
goto end

:prod
echo Starting production environment...
docker-compose --profile production up --build -d
goto end

:build
echo Building all images...
docker-compose build
docker-compose --profile production build
goto end

:up
echo Starting all services...
docker-compose up -d
goto end

:down
echo Stopping all services...
docker-compose --profile production down
docker-compose down
goto end

:logs
if "%2"=="" (
    docker-compose logs -f
) else (
    docker-compose logs -f %2
)
goto end

:shell
if "%2"=="" (
    docker-compose exec frontend-dev sh
) else (
    docker-compose exec %2 sh
)
goto end

:test
echo Running tests in container...
docker-compose run --rm frontend-dev npm test
goto end

:clean
echo Cleaning up Docker resources...
docker-compose down --rmi all --volumes --remove-orphans
docker-compose --profile production down --rmi all --volumes --remove-orphans
docker system prune -f
goto end

:install
echo Installing dependencies...
docker run --rm -v "%cd%":/app -w /app node:22-alpine npm install
goto end

:backup
echo Creating backup...
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%
set timestamp=%timestamp: =0%
mkdir backups 2>nul
docker run --rm -v admasafrolink-mongo-data:/source -v "%cd%\backups":/backup alpine tar czf /backup/mongo_%timestamp%.tar.gz -C /source .
echo Backup created: backups\mongo_%timestamp%.tar.gz
goto end

:end
