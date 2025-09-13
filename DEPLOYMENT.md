# AdmasAfroLink Deployment Guide

This guide provides comprehensive deployment instructions for the AdmasAfroLink application across multiple platforms.

## 🚀 Quick Start - Local Development

### Prerequisites
- Docker Desktop installed
- .NET 9.0 SDK
- Git

### Local Docker Deployment

1. **Clone and navigate to the project:**
```bash
git clone https://github.com/TMf124857/AdmasAfroLink.git
cd AdmasAfroLink
```

2. **Set up environment variables:**
```bash
cp .env.example .env
# Edit .env file with your configuration
```

3. **Build and run with Docker Compose:**
```bash
docker-compose up -d
```

4. **Check application status:**
```bash
# Check if services are running
docker-compose ps

# View logs
docker-compose logs -f api

# Test the API
curl http://localhost:8080/health
```

5. **Stop the application:**
```bash
docker-compose down
```

## ☁️ Cloud Platform Deployments

### 🔵 Azure App Service

**Automated Deployment:**
- Push to `main` branch triggers automatic deployment via GitHub Actions
- Requires Azure credentials setup in GitHub Secrets

**Manual Deployment:**
```bash
# Windows PowerShell
.\scripts\azure\deploy.ps1

# Linux/macOS
chmod +x scripts/azure/deploy.sh
./scripts/azure/deploy.sh
```

**Required GitHub Secrets:**
- `AZURE_CREDENTIALS`
- `ACR_USERNAME`
- `ACR_PASSWORD`

### 🟠 AWS ECS

**Manual Deployment:**
```bash
# Windows PowerShell
.\scripts\aws\deploy.ps1 -Region "us-east-1" -ClusterName "admasafrolink-cluster"

# Linux/macOS
chmod +x scripts/aws/deploy.sh
./scripts/aws/deploy.sh
```

**Required AWS Configuration:**
- AWS CLI configured (`aws configure`)
- Appropriate IAM permissions for ECS, ECR, RDS

**GitHub Secrets (for CI/CD):**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 🚂 Railway

**Automated Deployment:**
1. Connect GitHub repository to Railway
2. Use the configuration from `scripts/railway/railway.json`
3. Set environment variables in Railway dashboard

**Manual Deployment:**
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway link
railway up
```

**Required Railway Configuration:**
- PostgreSQL service
- Environment variables as specified in `scripts/railway/railway.json`

### 🎨 Render

**Automated Deployment:**
1. Connect GitHub repository to Render
2. Use the configuration from `scripts/render/render.yaml`
3. Create PostgreSQL database service
4. Deploy web service

**Manual Steps:**
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Create PostgreSQL database
3. Create web service with Docker environment
4. Configure environment variables

## 🔐 Environment Variables

### Required Variables
```env
# Database
ConnectionStrings__DefaultConnection=Host=localhost;Database=admasafrolink;Username=admasadmin;Password=YourPassword;

# JWT Configuration
JwtSettings__Key=YourSecretKeyHere
JwtSettings__Issuer=https://your-domain.com
JwtSettings__Audience=https://your-domain.com
JwtSettings__ExpiryInMinutes=60

# Application
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://0.0.0.0:8080

# OAuth (Optional)
Authentication__Google__ClientId=your-google-client-id
Authentication__Google__ClientSecret=your-google-client-secret
Authentication__Facebook__AppId=your-facebook-app-id
Authentication__Facebook__AppSecret=your-facebook-app-secret
```

### Platform-Specific Variables
- **Azure**: Uses Key Vault integration for secrets
- **AWS**: Uses Parameter Store or Secrets Manager
- **Railway**: Set in Railway dashboard
- **Render**: Set in service environment variables

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

1. **Deploy Workflow** (`.github/workflows/deploy.yml`)
   - Triggered on push to `main` branch
   - Runs tests, builds Docker image, deploys to Azure
   - Optional deployments to AWS, Railway, Render

2. **Quality Workflow** (`.github/workflows/quality.yml`)
   - Code quality analysis with SonarCloud
   - Security scanning with CodeQL
   - Dependency vulnerability checks

### Setting Up CI/CD

1. **Configure GitHub Secrets:**
   ```
   AZURE_CREDENTIALS         # Azure service principal
   ACR_USERNAME              # Azure Container Registry username
   ACR_PASSWORD              # Azure Container Registry password
   AWS_ACCESS_KEY_ID         # AWS access key (optional)
   AWS_SECRET_ACCESS_KEY     # AWS secret key (optional)
   RAILWAY_TOKEN             # Railway API token (optional)
   RENDER_TOKEN              # Render API token (optional)
   SONAR_TOKEN               # SonarCloud token (optional)
   ```

2. **Enable Desired Deployments:**
   - Edit `.github/workflows/deploy.yml`
   - Change `&& false` to `&& true` for platforms you want to enable

## 🏥 Health Checks and Monitoring

### Health Endpoints
- **Health Check**: `/health`
- **Readiness**: `/health/ready`
- **Liveness**: `/health/live`

### Monitoring Setup
1. **Application Insights** (Azure)
2. **CloudWatch** (AWS)
3. **Built-in monitoring** (Railway/Render)

### Log Aggregation
- Structured logging with Serilog
- JSON format for cloud parsing
- Correlation IDs for request tracing

## 🛠️ Troubleshooting

### Common Issues

1. **Database Connection Issues:**
   ```bash
   # Check connection string format
   # Ensure database is accessible
   # Verify credentials
   ```

2. **Docker Build Failures:**
   ```bash
   # Clear Docker cache
   docker system prune -a
   
   # Rebuild without cache
   docker build --no-cache -t admasafrolink-api .
   ```

3. **Memory Issues:**
   - Increase container memory limits
   - Optimize Docker image size
   - Use multi-stage builds

### Debug Commands

```bash
# Check application logs
docker-compose logs -f api

# Execute commands in container
docker-compose exec api bash

# Check database connectivity
docker-compose exec postgres psql -U admasadmin -d admasafrolink

# Monitor resource usage
docker stats
```

## 📊 Performance Optimization

### Production Optimizations
1. **Enable response compression**
2. **Configure HTTP/2**
3. **Set up CDN for static assets**
4. **Database connection pooling**
5. **Redis caching** (included in docker-compose)

### Scaling Considerations
- **Horizontal scaling**: Multiple container instances
- **Database scaling**: Read replicas, connection pooling
- **Caching**: Redis for session and data caching
- **Load balancing**: Nginx reverse proxy included

## 🔒 Security Checklist

- [ ] HTTPS enabled in production
- [ ] Strong JWT secret keys
- [ ] Database credentials secured
- [ ] CORS properly configured
- [ ] Rate limiting implemented
- [ ] Input validation enabled
- [ ] Security headers configured
- [ ] Dependency vulnerabilities checked

## 📞 Support

For deployment issues:
1. Check the logs for specific error messages
2. Verify environment variables are correctly set
3. Ensure all prerequisites are installed
4. Review platform-specific documentation

---

🎉 **Congratulations!** Your AdmasAfroLink application is now ready for deployment across multiple platforms!
