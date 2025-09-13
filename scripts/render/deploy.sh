#!/bin/bash

# Render Deployment Script for AdmasAfroLink
# This script helps deploy the application to Render.com

set -e

echo "🎨 Render Deployment Configuration for AdmasAfroLink"
echo "=" * 60

# Create render.yaml for Infrastructure as Code
cat > render.yaml << EOF
services:
  - type: web
    name: admasafrolink-api
    env: docker
    repo: https://github.com/TMf124857/AdmasAfroLink
    region: oregon
    plan: starter
    buildCommand: docker build -t admasafrolink-api .
    startCommand: dotnet AdmasAfroLink.dll
    envVars:
      - key: ASPNETCORE_ENVIRONMENT
        value: Production
      - key: ASPNETCORE_URLS
        value: http://0.0.0.0:10000
      - key: JwtSettings__Issuer
        value: https://admasafrolink-api.onrender.com
      - key: JwtSettings__Audience
        value: https://admasafrolink-api.onrender.com
      - key: JwtSettings__ExpiryInMinutes
        value: "60"
      - key: ConnectionStrings__DefaultConnection
        fromDatabase:
          name: admasafrolink-postgres
          property: connectionString
      - key: JwtSettings__Key
        generateValue: true
    healthCheckPath: /health
    
  - type: pserv
    name: admasafrolink-postgres
    env: docker
    repo: https://github.com/render-examples/postgresql
    region: oregon
    plan: starter
    envVars:
      - key: POSTGRES_DB
        value: admasafrolink
      - key: POSTGRES_USER
        value: admasadmin
      - key: POSTGRES_PASSWORD
        generateValue: true
    disk:
      name: postgres-data
      mountPath: /var/lib/postgresql/data
      sizeGB: 1

databases:
  - name: admasafrolink-postgres
    databaseName: admasafrolink
    user: admasadmin
    region: oregon
    plan: starter
EOF

echo "✅ render.yaml created successfully!"
echo ""
echo "📋 Manual Deployment Steps for Render:"
echo ""
echo "1. 🌐 Go to https://render.com and sign up/login"
echo "2. 🔗 Connect your GitHub repository (TMf124857/AdmasAfroLink)"
echo "3. 🗄️ Create PostgreSQL Database:"
echo "   - Service Type: PostgreSQL"
echo "   - Name: admasafrolink-postgres"
echo "   - Database: admasafrolink"
echo "   - User: admasadmin"
echo "   - Region: Oregon (or preferred)"
echo ""
echo "4. 🚀 Create Web Service:"
echo "   - Service Type: Web Service"
echo "   - Repository: TMf124857/AdmasAfroLink"
echo "   - Name: admasafrolink-api"
echo "   - Environment: Docker"
echo "   - Region: Oregon (same as database)"
echo "   - Instance Type: Starter ($7/month)"
echo ""
echo "5. ⚙️ Configure Environment Variables:"
echo "   ASPNETCORE_ENVIRONMENT=Production"
echo "   ASPNETCORE_URLS=http://0.0.0.0:10000"
echo "   JwtSettings__Issuer=https://admasafrolink-api.onrender.com"
echo "   JwtSettings__Audience=https://admasafrolink-api.onrender.com"
echo "   JwtSettings__ExpiryInMinutes=60"
echo "   JwtSettings__Key=[Generate random 32-byte key]"
echo "   ConnectionStrings__DefaultConnection=[Copy from PostgreSQL service]"
echo ""
echo "6. 🔧 Advanced Settings:"
echo "   - Health Check Path: /health"
echo "   - Auto Deploy: Yes"
echo "   - Build Command: (leave empty - using Dockerfile)"
echo "   - Start Command: (leave empty - using Dockerfile)"
echo ""
echo "7. 🏗️ Deploy:"
echo "   - Click 'Create Web Service'"
echo "   - Wait for deployment to complete"
echo "   - Check logs for any issues"
echo ""
echo "🔗 Alternative: Use render.yaml for Infrastructure as Code"
echo "   - Commit render.yaml to your repository"
echo "   - Use Render's Blueprint feature"
echo "   - Connect repository and select render.yaml"
echo ""
echo "💡 Tips:"
echo "   - Free tier available with limitations (sleeps after 15 min inactivity)"
echo "   - Starter plan recommended for production ($7/month per service)"
echo "   - Database connection string format: postgresql://user:pass@host:port/db"
echo "   - Enable 'Auto Deploy' for continuous deployment"
echo ""
echo "✅ Configuration complete! Ready for Render deployment."
