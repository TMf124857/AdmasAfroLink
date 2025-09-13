# AdmasAfroLink Integrated Platform

## 🚀 Frontend-Backend Integration Guide

This repository contains the complete AdmasAfroLink platform with integrated frontend and backend services. The platform provides a comprehensive international internship portal with modern UI/UX and robust backend API.

## 📋 Architecture Overview

```
AdmasAfroLink Platform
├── Frontend (Next.js/React)
│   ├── Website (Landing Page, Applications)
│   ├── Mobile App (Progressive Web App)
│   └── Admin Dashboard
├── Backend (ASP.NET Core API)
│   ├── Authentication & Authorization
│   ├── Application Management
│   ├── User Management
│   └── File Handling
├── Database (PostgreSQL)
│   ├── User Data
│   ├── Application Data
│   └── Analytics Data
└── Infrastructure
    ├── Docker Containers
    ├── Nginx Reverse Proxy
    └── Redis Cache
```

## 🛠️ Prerequisites

- **Docker & Docker Compose**: Latest version
- **Node.js**: 18+ (for development)
- **.NET Core**: 7.0+ (for development)
- **Git**: Latest version

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd AdmasAfroLink
```

### 2. Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit with your actual values
nano .env  # or use your preferred editor
```

### 3. Start Development Environment

**Windows (PowerShell):**
```powershell
.\deploy-integrated.ps1 start dev
```

**Linux/Mac:**
```bash
chmod +x deploy-integrated.sh
./deploy-integrated.sh start dev
```

### 4. Access Services

- **Frontend**: http://localhost:3000
- **API**: http://localhost:7001
- **pgAdmin**: http://localhost:5050
- **Redis Commander**: http://localhost:8081

## 🔧 Development Setup

### Manual Development (without Docker)

#### Backend Setup
```bash
cd backend/AdmasAfroLink.API
dotnet restore
dotnet run
```

#### Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

## 🐳 Docker Commands

### Start Services
```bash
# Development with hot reload
./deploy-integrated.sh start dev

# Production optimized
./deploy-integrated.sh start prod

# Full stack with monitoring tools
./deploy-integrated.sh start full
```

### Management Commands
```bash
# View service status
./deploy-integrated.sh status

# View logs
./deploy-integrated.sh logs
./deploy-integrated.sh logs api  # specific service

# Health check
./deploy-integrated.sh health

# Stop services
./deploy-integrated.sh stop

# Restart
./deploy-integrated.sh restart dev

# Cleanup (removes all data!)
./deploy-integrated.sh cleanup
```

## 📊 Service Configuration

### Frontend Configuration
- **Port**: 3000 (development), 3001 (production)
- **API URL**: Automatically configured based on environment
- **Features**: Hot reload, PWA, Mobile-first design

### Backend Configuration
- **Port**: 7001 (external), 8080 (internal)
- **Database**: PostgreSQL on port 5432
- **Cache**: Redis on port 6379
- **Features**: JWT auth, file uploads, real-time updates

### Database Configuration
- **Type**: PostgreSQL 15
- **Port**: 5432
- **Database**: AdmasAfroLinkDB
- **Admin**: pgAdmin on port 5050

## 🔐 Environment Variables

### Required Variables
```env
# Database
POSTGRES_DB=AdmasAfroLinkDB
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password

# API
JWT_SECRET_KEY=your_jwt_secret_key_32_chars_minimum
ASPNETCORE_ENVIRONMENT=Development

# Email
SMTP_SERVER=smtp.gmail.com
EMAIL_USERNAME=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
```

### Optional Variables
```env
# OAuth
GOOGLE_CLIENT_ID=your-google-client-id
FACEBOOK_APP_ID=your-facebook-app-id

# Analytics
NEXT_PUBLIC_GA_ID=your-analytics-id

# Cloud Storage (for production)
AWS_ACCESS_KEY_ID=your-aws-key
AWS_S3_BUCKET=your-bucket-name
```

## 🎯 Key Features

### Frontend Features
- ✅ **Responsive Design**: Mobile-first approach
- ✅ **Progressive Web App**: Offline support, installable
- ✅ **Modern UI/UX**: Clean, conversion-optimized design
- ✅ **Multi-step Forms**: Smart application flow
- ✅ **Real-time Updates**: WebSocket integration
- ✅ **SEO Optimized**: Meta tags, structured data

### Backend Features
- ✅ **RESTful API**: Clean, documented endpoints
- ✅ **Authentication**: JWT-based with refresh tokens
- ✅ **File Management**: Secure upload/download
- ✅ **Real-time**: SignalR for live updates
- ✅ **Validation**: Comprehensive input validation
- ✅ **Logging**: Structured logging with Serilog

### Integration Features
- ✅ **API Service**: Unified frontend-backend communication
- ✅ **Error Handling**: Graceful error management
- ✅ **Health Checks**: Service monitoring
- ✅ **Caching**: Redis for performance
- ✅ **Load Balancing**: Nginx reverse proxy
- ✅ **Security**: CORS, headers, rate limiting

## 📡 API Endpoints

### Authentication
```
POST /api/auth/login          - User login
POST /api/auth/register       - User registration
POST /api/auth/refresh        - Refresh token
POST /api/auth/logout         - User logout
```

### Applications
```
GET  /api/applications        - List applications
POST /api/applications        - Submit application
GET  /api/applications/{id}   - Get application
PUT  /api/applications/{id}   - Update application
```

### Users
```
GET  /api/users/profile       - Get user profile
PUT  /api/users/update        - Update profile
```

### Files
```
POST /api/files/upload        - Upload file
GET  /api/files/{id}         - Download file
```

## 🔍 Monitoring & Debugging

### Health Checks
```bash
# API Health
curl http://localhost:7001/api/health

# Frontend Health
curl http://localhost:3000

# Database Health
docker exec admasafrolink-postgres pg_isready
```

### Logs
```bash
# All services
./deploy-integrated.sh logs

# Specific service
./deploy-integrated.sh logs api
./deploy-integrated.sh logs frontend-dev
./deploy-integrated.sh logs postgres
```

### Admin Tools
- **pgAdmin**: Database management at http://localhost:5050
- **Redis Commander**: Cache management at http://localhost:8081
- **Portainer**: Container management at http://localhost:9000

## 🚢 Production Deployment

### Environment Setup
```bash
# Copy production environment
cp .env.example .env.production

# Update with production values
# - Strong passwords
# - Production domain
# - SSL certificates
# - External database (optional)
```

### Production Start
```bash
# Start production services
./deploy-integrated.sh start prod

# With SSL/monitoring
./deploy-integrated.sh start full
```

### SSL Configuration
1. Place SSL certificates in `nginx/ssl/`
2. Update `nginx/conf.d/admasafrolink.conf`
3. Set `ENABLE_SSL=true` in `.env`

## 🧪 Testing

### Frontend Testing
```bash
cd frontend
npm test                 # Unit tests
npm run test:e2e        # End-to-end tests
npm run lighthouse      # Performance audit
```

### Backend Testing
```bash
cd backend/AdmasAfroLink.API
dotnet test             # Unit tests
```

### Integration Testing
```bash
# Health check all services
./deploy-integrated.sh health

# Test API endpoints
curl -X POST http://localhost:7001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

## 🐛 Troubleshooting

### Common Issues

#### Port Conflicts
```bash
# Check which ports are in use
netstat -an | grep :3000
netstat -an | grep :7001
netstat -an | grep :5432

# Stop conflicting services
docker stop $(docker ps -q)
```

#### Database Connection Issues
```bash
# Check database status
docker logs admasafrolink-postgres

# Reset database
docker-compose down -v
docker-compose up postgres -d
```

#### Build Failures
```bash
# Clean Docker cache
docker system prune -f

# Rebuild without cache
docker-compose build --no-cache
```

### Performance Issues
```bash
# Check resource usage
docker stats

# Increase memory limits in docker-compose.yml
# Monitor logs for memory issues
./deploy-integrated.sh logs api | grep -i memory
```

## 📚 Development Guide

### Adding New Features

#### Frontend Components
1. Create component in `frontend/src/components/`
2. Add styles in `frontend/src/styles/`
3. Import in `index.html`
4. Test integration with API

#### Backend Endpoints
1. Create controller in `Controllers/`
2. Add models in `Models/`
3. Create DTOs in `DTOs/`
4. Add validation in `Validators/`
5. Update API documentation

### Database Migrations
```bash
# Create migration
cd backend/AdmasAfroLink.API
dotnet ef migrations add MigrationName

# Apply migration
dotnet ef database update
```

### API Integration
```javascript
// Use the integrated API service
await window.apiService.submitApplication(formData);
await window.apiService.getPrograms();
await window.apiService.uploadFile(file);
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Email**: support@admasafrolink.com
- **Phone**: +256 750 554 808
- **Documentation**: [docs.admasafrolink.com](https://docs.admasafrolink.com)
- **Issues**: [GitHub Issues](https://github.com/TMf124857/AdmasAfroLink/issues)

---

**AdmasAfroLink** - Transforming Global Career Opportunities 🌍
