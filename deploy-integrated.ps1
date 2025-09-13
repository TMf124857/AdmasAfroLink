# AdmasAfroLink Integrated Platform Deployment Script (PowerShell)
# This script sets up and runs the complete AdmasAfroLink platform on Windows

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "health", "cleanup", "help")]
    [string]$Command = "help",
    
    [Parameter(Position=1)]
    [ValidateSet("dev", "prod", "full")]
    [string]$Profile = "dev",
    
    [Parameter(Position=2)]
    [string]$Service = ""
)

# Colors for output
$Script:Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
    White = "White"
}

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Script:Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Script:Colors.Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Script:Colors.Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Script:Colors.Red
}

function Test-Docker {
    Write-Status "Checking Docker installation..."
    
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker is not installed. Please install Docker Desktop first."
        exit 1
    }
    
    try {
        docker info | Out-Null
    }
    catch {
        Write-Error "Docker is not running. Please start Docker Desktop first."
        exit 1
    }
    
    Write-Success "Docker is installed and running"
}

function Test-DockerCompose {
    Write-Status "Checking Docker Compose..."
    
    $Script:DockerComposeCmd = "docker-compose"
    
    if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        try {
            docker compose version | Out-Null
            $Script:DockerComposeCmd = "docker compose"
        }
        catch {
            Write-Error "Docker Compose is not available. Please install Docker Compose."
            exit 1
        }
    }
    
    Write-Success "Docker Compose is available"
}

function Initialize-Environment {
    Write-Status "Setting up environment configuration..."
    
    if (-not (Test-Path ".env")) {
        Write-Warning ".env file not found. Creating from .env.example..."
        Copy-Item ".env.example" ".env"
        Write-Success "Created .env file. Please review and update the values."
    }
    else {
        Write-Success "Environment file already exists"
    }
}

function New-Directories {
    Write-Status "Creating necessary directories..."
    
    $directories = @(
        "nginx\ssl",
        "logs",
        "uploads",
        "backups"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Success "Created directory: $dir"
        }
    }
}

function Start-Services {
    param([string]$Profile)
    
    Write-Status "Starting AdmasAfroLink services with profile: $Profile"
    
    $composeFile = "docker-compose.integrated.yml"
    
    switch ($Profile) {
        "dev" {
            & $Script:DockerComposeCmd -f $composeFile --profile dev up -d --build
        }
        "prod" {
            & $Script:DockerComposeCmd -f $composeFile --profile prod up -d --build
        }
        "full" {
            & $Script:DockerComposeCmd -f $composeFile --profile dev --profile tools --profile monitoring up -d --build
        }
        default {
            Write-Error "Invalid profile. Use: dev, prod, or full"
            exit 1
        }
    }
    
    Write-Success "Services started successfully"
}

function Get-ServiceStatus {
    Write-Status "Checking service status..."
    & $Script:DockerComposeCmd -f "docker-compose.integrated.yml" ps
}

function Get-ServiceLogs {
    param([string]$Service)
    
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Status "Showing logs for all services..."
        & $Script:DockerComposeCmd -f "docker-compose.integrated.yml" logs -f
    }
    else {
        Write-Status "Showing logs for service: $Service"
        & $Script:DockerComposeCmd -f "docker-compose.integrated.yml" logs -f $Service
    }
}

function Stop-Services {
    Write-Status "Stopping AdmasAfroLink services..."
    & $Script:DockerComposeCmd -f "docker-compose.integrated.yml" down
    Write-Success "Services stopped"
}

function Remove-Platform {
    Write-Warning "This will remove all containers, volumes, and data. Are you sure? (y/N)"
    $response = Read-Host
    
    if ($response -match "^[Yy]$") {
        Write-Status "Cleaning up AdmasAfroLink platform..."
        & $Script:DockerComposeCmd -f "docker-compose.integrated.yml" down -v --remove-orphans
        docker system prune -f
        Write-Success "Cleanup completed"
    }
    else {
        Write-Status "Cleanup cancelled"
    }
}

function Test-Health {
    Write-Status "Performing health check..."
    
    $services = @("postgres", "redis", "api", "frontend-dev")
    
    foreach ($service in $services) {
        Write-Status "Checking $service..."
        
        $status = & $Script:DockerComposeCmd -f "docker-compose.integrated.yml" ps $service
        if ($status -match "Up") {
            Write-Success "$service is running"
        }
        else {
            Write-Error "$service is not running"
        }
    }
    
    # Test API endpoint
    Write-Status "Testing API endpoint..."
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:7001/api/health" -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "API is responding"
        }
    }
    catch {
        Write-Warning "API health check failed"
    }
    
    # Test Frontend
    Write-Status "Testing Frontend..."
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "Frontend is responding"
        }
    }
    catch {
        Write-Warning "Frontend health check failed"
    }
}

function Show-Help {
    Write-Host @"
AdmasAfroLink Integrated Platform Management

Usage: .\deploy-integrated.ps1 [COMMAND] [PROFILE] [SERVICE]

Commands:
  start [profile]    Start the platform (profiles: dev, prod, full)
  stop              Stop all services
  restart [profile] Restart the platform
  status            Show service status
  logs [service]    Show logs (optionally for specific service)
  health            Perform health check
  cleanup           Remove all containers and volumes
  help              Show this help message

Examples:
  .\deploy-integrated.ps1 start dev      Start development environment
  .\deploy-integrated.ps1 start prod     Start production environment
  .\deploy-integrated.ps1 start full     Start with all tools and monitoring
  .\deploy-integrated.ps1 logs api       Show API service logs
  .\deploy-integrated.ps1 health         Check if all services are healthy

Service URLs (development):
  Frontend:         http://localhost:3000
  API:              http://localhost:7001
  pgAdmin:          http://localhost:5050
  Redis Commander:  http://localhost:8081
  Portainer:        http://localhost:9000
"@ -ForegroundColor $Script:Colors.White
}

# Main execution
Write-Host "🚀 AdmasAfroLink Integrated Platform Deployment" -ForegroundColor $Script:Colors.Blue
Write-Host "=================================================" -ForegroundColor $Script:Colors.Blue

switch ($Command) {
    "start" {
        Test-Docker
        Test-DockerCompose
        Initialize-Environment
        New-Directories
        Start-Services $Profile
        Get-ServiceStatus
        Test-Health
        Write-Host ""
        Write-Success "AdmasAfroLink platform is running!"
        Write-Host "Frontend: http://localhost:3000" -ForegroundColor $Script:Colors.Green
        Write-Host "API: http://localhost:7001" -ForegroundColor $Script:Colors.Green
        Write-Host "pgAdmin: http://localhost:5050" -ForegroundColor $Script:Colors.Green
    }
    "stop" {
        Test-DockerCompose
        Stop-Services
    }
    "restart" {
        Test-DockerCompose
        Stop-Services
        Start-Sleep -Seconds 2
        Start-Services $Profile
        Get-ServiceStatus
    }
    "status" {
        Test-DockerCompose
        Get-ServiceStatus
    }
    "logs" {
        Test-DockerCompose
        Get-ServiceLogs $Service
    }
    "health" {
        Test-DockerCompose
        Test-Health
    }
    "cleanup" {
        Test-DockerCompose
        Remove-Platform
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Show-Help
        exit 1
    }
}
