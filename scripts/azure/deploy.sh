#!/bin/bash

# Azure Deployment Script for AdmasAfroLink
# This script deploys the application to Azure App Service with PostgreSQL

set -e

# Configuration
RESOURCE_GROUP="admasafrolink-rg"
LOCATION="East US"
APP_SERVICE_PLAN="admasafrolink-plan"
APP_NAME="admasafrolink-api"
POSTGRES_SERVER="admasafrolink-postgres"
POSTGRES_DB="admasafrolink"
REGISTRY_NAME="admasafrolinkregistry"
IMAGE_NAME="admasafrolink-api"

echo "🚀 Starting Azure deployment for AdmasAfroLink..."

# Login to Azure (if not already logged in)
echo "📝 Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo "Please login to Azure..."
    az login
fi

# Create Resource Group
echo "🏗️ Creating resource group..."
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Create Azure Container Registry
echo "🐳 Creating Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $REGISTRY_NAME --sku Basic --admin-enabled true

# Build and push Docker image
echo "🔨 Building and pushing Docker image..."
az acr build --registry $REGISTRY_NAME --image $IMAGE_NAME:latest .

# Create PostgreSQL Server
echo "🗄️ Creating PostgreSQL server..."
az postgres flexible-server create \
    --resource-group $RESOURCE_GROUP \
    --name $POSTGRES_SERVER \
    --location "$LOCATION" \
    --admin-user admasadmin \
    --admin-password "AdmasAfro2024!" \
    --sku-name Standard_B1ms \
    --tier Burstable \
    --version 14 \
    --storage-size 32 \
    --public-access 0.0.0.0

# Create database
echo "📊 Creating database..."
az postgres flexible-server db create \
    --resource-group $RESOURCE_GROUP \
    --server-name $POSTGRES_SERVER \
    --database-name $POSTGRES_DB

# Create App Service Plan
echo "⚙️ Creating App Service Plan..."
az appservice plan create \
    --name $APP_SERVICE_PLAN \
    --resource-group $RESOURCE_GROUP \
    --is-linux \
    --sku B1

# Create Web App
echo "🌐 Creating Web App..."
az webapp create \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN \
    --name $APP_NAME \
    --deployment-container-image-name $REGISTRY_NAME.azurecr.io/$IMAGE_NAME:latest

# Configure App Settings
echo "🔧 Configuring application settings..."
POSTGRES_CONNECTION="Host=$POSTGRES_SERVER.postgres.database.azure.com;Database=$POSTGRES_DB;Username=admasadmin;Password=AdmasAfro2024!;SSL Mode=Require;"

az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --settings \
        ConnectionStrings__DefaultConnection="$POSTGRES_CONNECTION" \
        ASPNETCORE_ENVIRONMENT="Production" \
        JwtSettings__Key="$(openssl rand -base64 32)" \
        JwtSettings__Issuer="https://$APP_NAME.azurewebsites.net" \
        JwtSettings__Audience="https://$APP_NAME.azurewebsites.net" \
        JwtSettings__ExpiryInMinutes="60" \
        WEBSITES_PORT="8080"

# Configure continuous deployment
echo "🔄 Configuring continuous deployment..."
az webapp config container set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --docker-custom-image-name $REGISTRY_NAME.azurecr.io/$IMAGE_NAME:latest \
    --docker-registry-server-url https://$REGISTRY_NAME.azurecr.io

# Enable logging
echo "📋 Enabling application logging..."
az webapp log config \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --application-logging true \
    --level information

echo "✅ Deployment completed successfully!"
echo "🌍 Your application is available at: https://$APP_NAME.azurewebsites.net"
echo "📊 PostgreSQL server: $POSTGRES_SERVER.postgres.database.azure.com"
echo "🔗 To view logs: az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME"
