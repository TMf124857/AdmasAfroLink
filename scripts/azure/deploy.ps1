# Azure Deployment PowerShell Script for AdmasAfroLink
# This script deploys the application to Azure App Service with PostgreSQL

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "admasafrolink-rg",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = "admasafrolink-api"
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Azure deployment for AdmasAfroLink..." -ForegroundColor Green

# Configuration
$APP_SERVICE_PLAN = "admasafrolink-plan"
$POSTGRES_SERVER = "admasafrolink-postgres"
$POSTGRES_DB = "admasafrolink"
$REGISTRY_NAME = "admasafrolinkregistry"
$IMAGE_NAME = "admasafrolink-api"

# Check if Azure CLI is installed
if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Azure CLI is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Login to Azure (if not already logged in)
Write-Host "📝 Checking Azure login status..." -ForegroundColor Yellow
try {
    az account show | Out-Null
} catch {
    Write-Host "Please login to Azure..." -ForegroundColor Yellow
    az login
}

# Create Resource Group
Write-Host "🏗️ Creating resource group..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location

# Create Azure Container Registry
Write-Host "🐳 Creating Azure Container Registry..." -ForegroundColor Yellow
az acr create --resource-group $ResourceGroup --name $REGISTRY_NAME --sku Basic --admin-enabled true

# Build and push Docker image
Write-Host "🔨 Building and pushing Docker image..." -ForegroundColor Yellow
az acr build --registry $REGISTRY_NAME --image "${IMAGE_NAME}:latest" .

# Create PostgreSQL Server
Write-Host "🗄️ Creating PostgreSQL server..." -ForegroundColor Yellow
az postgres flexible-server create `
    --resource-group $ResourceGroup `
    --name $POSTGRES_SERVER `
    --location $Location `
    --admin-user admasadmin `
    --admin-password "AdmasAfro2024!" `
    --sku-name Standard_B1ms `
    --tier Burstable `
    --version 14 `
    --storage-size 32 `
    --public-access 0.0.0.0

# Create database
Write-Host "📊 Creating database..." -ForegroundColor Yellow
az postgres flexible-server db create `
    --resource-group $ResourceGroup `
    --server-name $POSTGRES_SERVER `
    --database-name $POSTGRES_DB

# Create App Service Plan
Write-Host "⚙️ Creating App Service Plan..." -ForegroundColor Yellow
az appservice plan create `
    --name $APP_SERVICE_PLAN `
    --resource-group $ResourceGroup `
    --is-linux `
    --sku B1

# Create Web App
Write-Host "🌐 Creating Web App..." -ForegroundColor Yellow
az webapp create `
    --resource-group $ResourceGroup `
    --plan $APP_SERVICE_PLAN `
    --name $AppName `
    --deployment-container-image-name "${REGISTRY_NAME}.azurecr.io/${IMAGE_NAME}:latest"

# Generate JWT key
$JwtKey = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((New-Guid).ToString() + (New-Guid).ToString()))

# Configure App Settings
Write-Host "🔧 Configuring application settings..." -ForegroundColor Yellow
$POSTGRES_CONNECTION = "Host=${POSTGRES_SERVER}.postgres.database.azure.com;Database=${POSTGRES_DB};Username=admasadmin;Password=AdmasAfro2024!;SSL Mode=Require;"

az webapp config appsettings set `
    --resource-group $ResourceGroup `
    --name $AppName `
    --settings `
        "ConnectionStrings__DefaultConnection=$POSTGRES_CONNECTION" `
        "ASPNETCORE_ENVIRONMENT=Production" `
        "JwtSettings__Key=$JwtKey" `
        "JwtSettings__Issuer=https://${AppName}.azurewebsites.net" `
        "JwtSettings__Audience=https://${AppName}.azurewebsites.net" `
        "JwtSettings__ExpiryInMinutes=60" `
        "WEBSITES_PORT=8080"

# Configure continuous deployment
Write-Host "🔄 Configuring continuous deployment..." -ForegroundColor Yellow
az webapp config container set `
    --resource-group $ResourceGroup `
    --name $AppName `
    --docker-custom-image-name "${REGISTRY_NAME}.azurecr.io/${IMAGE_NAME}:latest" `
    --docker-registry-server-url "https://${REGISTRY_NAME}.azurecr.io"

# Enable logging
Write-Host "📋 Enabling application logging..." -ForegroundColor Yellow
az webapp log config `
    --resource-group $ResourceGroup `
    --name $AppName `
    --application-logging true `
    --level information

Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host "🌍 Your application is available at: https://${AppName}.azurewebsites.net" -ForegroundColor Cyan
Write-Host "📊 PostgreSQL server: ${POSTGRES_SERVER}.postgres.database.azure.com" -ForegroundColor Cyan
Write-Host "🔗 To view logs: az webapp log tail --resource-group $ResourceGroup --name $AppName" -ForegroundColor Cyan
