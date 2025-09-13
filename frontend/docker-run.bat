@echo off
setlocal

echo.
echo ========================================
echo   AdmasAfroLink Docker Management
echo ========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running or not installed
    echo Please start Docker Desktop or install Docker
    echo Visit: https://docker.com/get-started/
    pause
    exit /b 1
)

echo Docker is running ✓
echo.

REM Show menu
:menu
echo Choose an option:
echo.
echo === DEVELOPMENT ===
echo 1. Start Development Environment (Frontend + Redis)
echo 2. Start Development Frontend Only
echo 3. View Development Logs
echo.
echo === PRODUCTION ===
echo 4. Start Full Production Stack
echo 5. Start Production Frontend Only
echo 6. View Production Logs
echo.
echo === MANAGEMENT ===
echo 7. Stop All Services
echo 8. Restart Services
echo 9. View System Status
echo 10. Open Shell in Container
echo.
echo === MAINTENANCE ===
echo 11. Clean Up (Remove containers/images)
echo 12. Reset Database
echo 13. Backup Data
echo 14. View Docker Stats
echo 15. Fix Network Issues
echo.
echo 16. Exit
echo.
set /p choice="Enter your choice (1-16): "

if "%choice%"=="1" goto dev-full
if "%choice%"=="2" goto dev-frontend
if "%choice%"=="3" goto dev-logs
if "%choice%"=="4" goto prod-full
if "%choice%"=="5" goto prod-frontend
if "%choice%"=="6" goto prod-logs
if "%choice%"=="7" goto stop
if "%choice%"=="8" goto restart
if "%choice%"=="9" goto status
if "%choice%"=="10" goto shell
if "%choice%"=="11" goto cleanup
if "%choice%"=="12" goto reset-db
if "%choice%"=="13" goto backup
if "%choice%"=="14" goto stats
if "%choice%"=="15" goto fix-network
if "%choice%"=="16" goto exit
echo Invalid choice. Please try again.
goto menu

:dev-full
echo.
echo Starting Development Environment...
echo - Frontend with hot reload: http://localhost:3000
echo - Redis cache: localhost:6379
echo.
docker-compose up --build frontend-dev redis
goto menu

:dev-frontend
echo.
echo Starting Development Frontend Only...
echo Access at: http://localhost:3000
echo.
docker-compose up --build frontend-dev
goto menu

:dev-logs
echo.
echo Development Logs (Press Ctrl+C to exit)...
docker-compose logs -f frontend-dev
goto menu

:prod-full
echo.
echo Starting Full Production Stack...
echo - Frontend: http://localhost:3001
echo - Backend API: http://localhost:8000
echo - Nginx Proxy: http://localhost:80
echo - MongoDB: localhost:27017
echo - Redis: localhost:6379
echo - MinIO Storage: http://localhost:9000
echo.
docker-compose --profile production up --build -d
echo.
echo ✅ Production stack started!
echo.
echo Access points:
echo 🌐 Main Application: http://localhost
echo 📊 Admin Dashboard: http://localhost:9001
echo 📈 API Health: http://localhost:8000/health
echo.
goto menu

:prod-frontend
echo.
echo Starting Production Frontend Only...
echo Access at: http://localhost:3001
echo.
docker-compose --profile production up --build frontend-prod
goto menu

:prod-logs
echo.
echo Production Logs (Press Ctrl+C to exit)...
docker-compose --profile production logs -f
goto menu

:stop
echo.
echo Stopping all services...
docker-compose --profile production down
docker-compose down
echo Services stopped ✓
goto menu

:restart
echo.
echo Restarting services...
docker-compose restart
docker-compose --profile production restart 2>nul
echo Services restarted ✓
goto menu

:status
echo.
echo === Docker Container Status ===
docker-compose ps
echo.
echo === Docker Images ===
docker images | findstr admasafrolink
echo.
echo === Network Status ===
docker network ls | findstr admasafrolink
echo.
echo === Volume Status ===
docker volume ls | findstr admasafrolink
echo.
goto menu

:shell
echo.
echo Choose container to access:
echo 1. Frontend Development
echo 2. Frontend Production
echo 3. Backend
echo 4. MongoDB
echo 5. Redis
echo.
set /p shell_choice="Enter choice (1-5): "

if "%shell_choice%"=="1" (
    echo Opening shell in Frontend Dev container...
    docker-compose exec frontend-dev sh
) else if "%shell_choice%"=="2" (
    echo Opening shell in Frontend Prod container...
    docker-compose --profile production exec frontend-prod sh
) else if "%shell_choice%"=="3" (
    echo Opening shell in Backend container...
    docker-compose --profile production exec backend sh
) else if "%shell_choice%"=="4" (
    echo Opening MongoDB shell...
    docker-compose --profile production exec mongo mongosh
) else if "%shell_choice%"=="5" (
    echo Opening Redis CLI...
    docker-compose --profile production exec redis redis-cli
) else (
    echo Invalid choice
)
goto menu

:cleanup
echo.
echo WARNING: This will remove all containers, images, and networks
echo This will NOT remove volumes (data will be preserved)
echo.
set /p confirm="Are you sure? (y/N): "
if /i "%confirm%"=="y" (
    echo Cleaning up...
    docker-compose --profile production down --rmi all --remove-orphans
    docker-compose down --rmi all --remove-orphans
    docker system prune -f
    echo Cleanup completed ✓
) else (
    echo Cleanup cancelled
)
goto menu

:reset-db
echo.
echo WARNING: This will delete all database data
set /p confirm="Are you sure? (y/N): "
if /i "%confirm%"=="y" (
    echo Stopping database...
    docker-compose --profile production stop mongo
    echo Removing database volume...
    docker volume rm admasafrolink-mongo-data 2>nul
    echo Database reset completed ✓
    echo Start the services again to create a fresh database
) else (
    echo Database reset cancelled
)
goto menu

:backup
echo.
echo Creating backup...
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%
set timestamp=%timestamp: =0%
echo Backup timestamp: %timestamp%
echo.
echo Backing up MongoDB...
docker-compose --profile production exec mongo mongodump --out /tmp/backup_%timestamp%
echo.
echo Backing up volumes...
docker run --rm -v admasafrolink-mongo-data:/source -v %cd%\backups:/backup alpine tar czf /backup/mongo_%timestamp%.tar.gz -C /source .
docker run --rm -v admasafrolink-minio-data:/source -v %cd%\backups:/backup alpine tar czf /backup/minio_%timestamp%.tar.gz -C /source .
echo.
echo ✅ Backup completed: %timestamp%
goto menu

:stats
echo.
echo === Real-time Docker Stats ===
echo Press Ctrl+C to exit
docker stats
goto menu

:fix-network
echo.
echo Fixing network issues...
echo Stopping all containers...
docker-compose --profile production down 2>nul
docker-compose down 2>nul
echo.
echo Removing conflicting networks...
docker network rm admasafrolink-network 2>nul
echo.
echo Pruning unused networks...
docker network prune -f
echo.
echo ✅ Network issues fixed!
echo You can now start the services again.
goto menu

:exit
echo.
echo Goodbye!
exit /b 0
