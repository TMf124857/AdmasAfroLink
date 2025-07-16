# Odoo Enterprise Docker Compose Setup

This repository contains a complete Docker Compose setup for deploying Odoo Enterprise with all necessary dependencies.

## 🚀 Quick Start

1. **Clone and navigate to the directory:**
   ```bash
   cd AdmasAfroLink
   ```

2. **Start the services:**
   ```bash
   docker-compose up -d
   ```

3. **Initialize the database (first time only):**
   ```bash
   # Linux/Mac
   chmod +x init-odoo.sh
   ./init-odoo.sh
   
   # Windows
   init-odoo.bat
   ```

4. **Access Odoo:**
   - Odoo: http://localhost:8069
   - Default credentials: admin / admin123
   - pgAdmin: http://localhost:5050 (optional, use profile `tools`)

## 📁 Project Structure

```
AdmasAfroLink/
├── docker-compose.yml          # Main Docker Compose configuration
├── .env                        # Environment variables
├── config/
│   └── odoo.conf              # Odoo configuration file
├── nginx/
│   └── nginx.conf             # Nginx reverse proxy configuration
├── addons/                    # Custom Odoo addons directory
├── enterprise/                # Odoo Enterprise addons directory
└── logs/                      # Odoo logs directory
```

## 🏗️ Services Overview

### Core Services
- **Odoo**: Main application server (Port 8069)
- **PostgreSQL**: Database server (Port 5432)
- **Redis**: Session storage and caching (Port 6379)

### Optional Services (Profiles)
- **pgAdmin**: Database administration tool (Port 5050) - Profile: `tools`
- **Nginx**: Reverse proxy with SSL support (Ports 80/443) - Profile: `proxy`

## 🔧 Configuration

### Environment Variables
Edit the `.env` file to customize your deployment:

```env
# Database Configuration
POSTGRES_DB=odoo
POSTGRES_USER=odoo
POSTGRES_PASSWORD=odoo123

# pgAdmin Configuration
PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=admin123
```

### Odoo Configuration
The `config/odoo.conf` file contains Odoo-specific settings. Key configurations:
- Database connection settings
- Worker processes
- Memory limits
- Logging configuration
- Session management with Redis

## 🚦 Starting Services

### Start all core services:
```bash
docker-compose up -d
```

### Start with optional tools (pgAdmin):
```bash
docker-compose --profile tools up -d
```

### Start with reverse proxy (Nginx):
```bash
docker-compose --profile proxy up -d
```

### Start everything:
```bash
docker-compose --profile tools --profile proxy up -d
```

## 📊 Monitoring and Management

### View logs:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f odoo
```

### Check service status:
```bash
docker-compose ps
```

### Access containers:
```bash
# Odoo container
docker-compose exec odoo bash

# Database container
docker-compose exec db psql -U odoo -d odoo
```

## 🔒 Security Considerations

### For Production Deployment:

1. **Change default passwords** in `.env` file
2. **Enable SSL** by configuring certificates in `nginx/ssl/`
3. **Set proper database filters** in `config/odoo.conf`
4. **Disable development mode** in `config/odoo.conf`
5. **Configure proper email settings**

### SSL Setup:
1. Place your SSL certificates in `nginx/ssl/`
2. Uncomment the HTTPS server block in `nginx/nginx.conf`
3. Update the `.env` file to enable SSL

## 📦 Adding Custom Addons

1. **Community addons**: Place in `./addons/` directory
2. **Enterprise addons**: Place in `./enterprise/` directory
3. **Restart Odoo** to load new addons:
   ```bash
   docker-compose restart odoo
   ```

## 🗄️ Database Management

### Backup database:
```bash
docker-compose exec db pg_dump -U odoo odoo > backup.sql
```

### Restore database:
```bash
docker-compose exec -T db psql -U odoo odoo < backup.sql
```

### Access pgAdmin:
1. Start with tools profile: `docker-compose --profile tools up -d`
2. Navigate to http://localhost:5050
3. Login with credentials from `.env` file
4. Add server connection:
   - Host: `db`
   - Port: `5432`
   - Database: `odoo`
   - Username/Password: from `.env` file

## 🔧 Troubleshooting

### Common Issues:

1. **Port conflicts**: Ensure ports 8069, 5432, 6379 are available
2. **Permission issues**: Check file permissions in mounted volumes
3. **Database connection**: Verify PostgreSQL is running and accessible
4. **Memory issues**: Adjust worker and memory settings in `odoo.conf`

### Useful Commands:
```bash
# Restart all services
docker-compose restart

# Rebuild and restart specific service
docker-compose up -d --build odoo

# Remove all containers and volumes (CAUTION: Data loss)
docker-compose down -v

# View resource usage
docker stats
```

## 📋 Production Checklist

- [ ] Change all default passwords
- [ ] Configure SSL certificates
- [ ] Set up regular database backups
- [ ] Configure email settings
- [ ] Set proper memory limits
- [ ] Enable monitoring and logging
- [ ] Configure firewall rules
- [ ] Set up domain name and DNS
- [ ] Test disaster recovery procedures

## 🤝 Support

For issues and questions:
1. Check the logs: `docker-compose logs -f`
2. Verify configuration files
3. Ensure all required ports are available
4. Check Odoo official documentation

---

**Note**: This setup is configured for development by default. Please review and adjust all security settings before using in production.
