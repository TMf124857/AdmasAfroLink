# AdmasAfroLink Server Deployment Steps

## 🚀 Complete Deployment Guide for Ubuntu Server 24 LTS

### Phase 1: Server Preparation

#### 1.1 Initial Server Setup
```bash
# Connect to your server
ssh ubuntu@your-server-ip

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git vim nano htop ufw
```

#### 1.2 Install Docker and Docker Compose
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

#### 1.3 Configure Firewall
```bash
# Configure UFW firewall
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8069/tcp
sudo ufw enable
```

### Phase 2: Project Deployment

#### 2.1 Clone Repository
```bash
# Clone your repository
cd /home/ubuntu
git clone https://github.com/TMf124857/AdmasAfroLink.git
cd AdmasAfroLink

# Set permissions
chmod +x deploy deployment-agent.sh extract-enterprise-addons.sh
```

#### 2.2 Configure Environment
```bash
# Copy environment file
cp .env.example .env

# Edit environment variables for production
nano .env
```

**Edit these values in .env:**
```bash
# Database settings
POSTGRES_DB=admasafrolink_prod
POSTGRES_USER=odoo_user
POSTGRES_PASSWORD=your_secure_password_here

# Odoo settings
ODOO_DB_HOST=db
ODOO_DB_PASSWORD=your_secure_password_here
ODOO_ADMIN_PASSWORD=your_admin_password_here

# Production settings
ODOO_WORKERS=4
ODOO_MAX_CRON_THREADS=2
```

#### 2.3 Set Up Enterprise Addons
```bash
# Extract enterprise addons
./extract-enterprise-addons.sh

# Verify extraction
ls -la enterprise/
```

### Phase 3: Deployment Execution

#### 3.1 Configure Deployment Agent
```bash
# Edit deployment configuration
nano deployment-agent.conf
```

**Update these settings:**
```bash
SERVER_HOST="localhost"  # Since we're on the server
SERVER_USER="ubuntu"
SERVER_PATH="/home/ubuntu/AdmasAfroLink"
REPO_BRANCH="main"
HEALTH_CHECK_URL="http://localhost:8069"
```

#### 3.2 Initial Deployment
```bash
# Run initial setup
./deploy setup

# Deploy the application
./deploy deploy
```

#### 3.3 Start Services
```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f odoo
```

### Phase 4: Verification and Testing

#### 4.1 Health Checks
```bash
# Test deployment
./deploy test

# Check service health
curl http://localhost:8069/web/health

# Verify database connection
docker-compose exec odoo odoo shell -d admasafrolink_prod
```

#### 4.2 Access Verification
```bash
# Check if Odoo is accessible
curl -I http://localhost:8069

# Test from external (replace with your server IP)
curl -I http://your-server-ip:8069
```

### Phase 5: Production Configuration

#### 5.1 Set Up Nginx (Optional but Recommended)
```bash
# Install Nginx
sudo apt install nginx -y

# Create Odoo site configuration
sudo nano /etc/nginx/sites-available/admasafrolink
```

**Nginx configuration:**
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8069;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Enable site and restart Nginx
sudo ln -s /etc/nginx/sites-available/admasafrolink /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 5.2 Set Up SSL (Optional)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d your-domain.com
```

#### 5.3 Configure Auto-Start
```bash
# Create systemd service for auto-start
sudo nano /etc/systemd/system/admasafrolink.service
```

**Service configuration:**
```ini
[Unit]
Description=AdmasAfroLink Odoo Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/AdmasAfroLink
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=ubuntu

[Install]
WantedBy=multi-user.target
```

```bash
# Enable auto-start
sudo systemctl enable admasafrolink.service
sudo systemctl start admasafrolink.service
```

### Phase 6: Monitoring and Maintenance

#### 6.1 Set Up Monitoring
```bash
# Enable auto-deployment monitoring
./deploy auto &

# Create log rotation
sudo nano /etc/logrotate.d/admasafrolink
```

**Log rotation configuration:**
```
/home/ubuntu/AdmasAfroLink/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 ubuntu ubuntu
}
```

#### 6.2 Backup Configuration
```bash
# Create backup script
nano backup-odoo.sh
```

**Backup script:**
```bash
#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
docker-compose exec -T db pg_dump -U odoo_user admasafrolink_prod > $BACKUP_DIR/db_backup_$DATE.sql

# Backup file store
tar -czf $BACKUP_DIR/filestore_backup_$DATE.tar.gz -C /home/ubuntu/AdmasAfroLink/volumes/odoo .

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

```bash
# Make backup script executable
chmod +x backup-odoo.sh

# Set up daily backup cron job
(crontab -l 2>/dev/null; echo "0 2 * * * /home/ubuntu/AdmasAfroLink/backup-odoo.sh") | crontab -
```

## 🔧 Troubleshooting Common Issues

### Database Connection Issues
```bash
# Check database container
docker-compose logs db

# Reset database password
docker-compose exec db psql -U postgres -c "ALTER USER odoo_user PASSWORD 'new_password';"
```

### Port Access Issues
```bash
# Check if port is open
sudo netstat -tulpn | grep :8069

# Check firewall
sudo ufw status

# Check Docker port mapping
docker-compose ps
```

### Enterprise Addon Issues
```bash
# Re-extract enterprise addons
rm -rf enterprise/*
./extract-enterprise-addons.sh

# Check addon permissions
ls -la enterprise/
sudo chown -R ubuntu:ubuntu enterprise/
```

### Performance Issues
```bash
# Monitor resources
htop
docker stats

# Adjust worker count in .env
nano .env
# Increase ODOO_WORKERS based on CPU cores
```

## 📋 Post-Deployment Checklist

- [ ] Odoo accessible at http://your-server-ip:8069
- [ ] Database connection working
- [ ] Enterprise addons loaded
- [ ] SSL certificate installed (if applicable)
- [ ] Firewall configured
- [ ] Auto-start service enabled
- [ ] Backup system configured
- [ ] Monitoring enabled
- [ ] DNS pointing to server (if using domain)
- [ ] Email configuration tested

## 🚀 Quick Commands Reference

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Deploy updates
./deploy deploy

# Check status
./deploy status

# Backup data
./backup-odoo.sh

# Monitor auto-deployment
./deploy auto
```

## 📞 Support Commands

If you need help during deployment:

```bash
# Check deployment agent status
./deploy status

# View detailed logs
./deploy logs

# Test connectivity
./deploy test

# Get system information
uname -a
docker --version
docker-compose --version
```

Your AdmasAfroLink Odoo Enterprise application should now be fully deployed and running on your Ubuntu server! 🎉
