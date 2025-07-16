# Odoo Enterprise Ubuntu Server 24 LTS Deployment Guide

This guide provides step-by-step instructions for deploying Odoo Enterprise on Ubuntu Server 24 LTS using Docker Compose.

## 🖥️ System Requirements

### Minimum Requirements:
- **OS**: Ubuntu Server 24.04 LTS
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 50GB SSD
- **Network**: Stable internet connection

### Recommended for Production:
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: 100GB+ SSD
- **Network**: 1Gbps connection

## 🚀 Quick Deployment

### Option 1: Automated Installation (Recommended)

1. **Download the deployment script:**
   ```bash
   wget https://raw.githubusercontent.com/yourusername/AdmasAfroLink/main/deploy-ubuntu.sh
   chmod +x deploy-ubuntu.sh
   ```

2. **Run complete installation:**
   ```bash
   ./deploy-ubuntu.sh full-install
   ```

3. **Log out and log back in, then deploy:**
   ```bash
   ./deploy-ubuntu.sh deploy
   ```

### Option 2: Manual Installation

Follow the manual steps below for a controlled installation process.

## 📋 Manual Installation Steps

### Step 1: Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### Step 2: Install Docker
```bash
# Remove old versions
sudo apt remove docker.io docker-doc docker-compose podman-docker containerd runc

# Install prerequisites
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker
```

### Step 3: Install Docker Compose (Standalone)
```bash
# Get latest version
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')

# Download and install
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
```

### Step 4: Configure Firewall
```bash
# Install and configure UFW
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8069/tcp  # Optional: Direct Odoo access
sudo ufw --force enable
```

### Step 5: System Optimization
```bash
# Increase file limits
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "root soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "root hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Configure sysctl
sudo tee /etc/sysctl.d/99-docker-performance.conf > /dev/null <<EOF
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
EOF

sudo sysctl -p /etc/sysctl.d/99-docker-performance.conf
```

### Step 6: Deploy Odoo Enterprise
```bash
# Clone or copy your project files
git clone https://github.com/yourusername/AdmasAfroLink.git
cd AdmasAfroLink

# Set up environment
cp .env.example .env
nano .env  # Edit configuration as needed

# Create directories
mkdir -p logs addons enterprise nginx/ssl
chmod 755 logs addons enterprise nginx
chmod 700 nginx/ssl

# Deploy services
docker-compose up -d

# Check status
docker-compose ps
```

## 🔧 Configuration

### Environment Variables (.env)
```env
# Database Configuration
POSTGRES_DB=odoo
POSTGRES_USER=odoo
POSTGRES_PASSWORD=your_secure_database_password

# pgAdmin Configuration
PGADMIN_EMAIL=admin@yourdomain.com
PGADMIN_PASSWORD=your_secure_pgadmin_password

# Odoo Configuration
ODOO_ADMIN_PASSWORD=your_secure_admin_password
ODOO_DB_FILTER=^your_database_name$

# SSL Configuration
ENABLE_SSL=true
SSL_CERT_PATH=./nginx/ssl/cert.pem
SSL_KEY_PATH=./nginx/ssl/key.pem

# Environment
ENVIRONMENT=production
```

### Service Profiles

Start different service combinations:

```bash
# Core services only (Odoo + PostgreSQL + Redis)
docker-compose up -d

# With database administration tools
docker-compose --profile tools up -d

# With reverse proxy (Nginx)
docker-compose --profile proxy up -d

# All services
docker-compose --profile tools --profile proxy up -d
```

## 🔒 Security Configuration

### 1. SSL/TLS Setup
```bash
# Generate self-signed certificate (for testing)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem

# For production, use Let's Encrypt:
sudo apt install certbot
sudo certbot certonly --standalone -d yourdomain.com
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem nginx/ssl/key.pem
```

### 2. Update Nginx Configuration
Edit `nginx/nginx.conf` and uncomment the HTTPS server block, then:
```bash
docker-compose restart nginx
```

### 3. Database Security
```bash
# Change default passwords in .env file
nano .env

# Restart services
docker-compose down
docker-compose up -d
```

## 🗄️ Database Management

### Backup Database
```bash
# Create backup
docker-compose exec db pg_dump -U odoo odoo > backup_$(date +%Y%m%d_%H%M%S).sql

# Automated backup script
crontab -e
# Add: 0 2 * * * /path/to/backup-script.sh
```

### Restore Database
```bash
# Stop Odoo
docker-compose stop odoo

# Restore database
docker-compose exec -T db psql -U odoo odoo < backup_file.sql

# Start Odoo
docker-compose start odoo
```

## 📊 Monitoring and Maintenance

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f odoo
docker-compose logs -f db
docker-compose logs -f nginx
```

### Health Checks
```bash
# Check service status
docker-compose ps

# Check system resources
docker stats

# Check disk usage
df -h
du -sh /var/lib/docker/
```

### Updates
```bash
# Update images
docker-compose pull

# Recreate containers
docker-compose up -d --force-recreate

# Clean up old images
docker image prune -a
```

## 🚨 Troubleshooting

### Common Issues

1. **Permission Denied Errors**
   ```bash
   sudo chown -R 1000:1000 logs addons enterprise
   ```

2. **Port Already in Use**
   ```bash
   sudo netstat -tulpn | grep :8069
   sudo systemctl stop apache2  # If Apache is running
   ```

3. **Database Connection Issues**
   ```bash
   docker-compose logs db
   docker-compose restart db
   ```

4. **SSL Certificate Issues**
   ```bash
   # Check certificate validity
   openssl x509 -in nginx/ssl/cert.pem -text -noout
   ```

### Performance Optimization

1. **Increase Worker Processes**
   Edit `config/odoo.conf`:
   ```ini
   workers = 4  # Adjust based on CPU cores
   ```

2. **Database Tuning**
   ```bash
   # Connect to database
   docker-compose exec db psql -U odoo odoo
   
   # Run VACUUM and ANALYZE
   VACUUM ANALYZE;
   ```

3. **Log Rotation**
   ```bash
   sudo tee /etc/logrotate.d/odoo-docker > /dev/null <<EOF
   /path/to/logs/*.log {
       daily
       missingok
       rotate 52
       compress
       delaycompress
       notifempty
       create 644 1000 1000
   }
   EOF
   ```

## 🔄 Systemd Service (Optional)

To manage Odoo as a system service:

1. **Create service file:**
   ```bash
   sudo cp odoo-enterprise.service /etc/systemd/system/
   sudo systemctl daemon-reload
   ```

2. **Enable and start service:**
   ```bash
   sudo systemctl enable odoo-enterprise
   sudo systemctl start odoo-enterprise
   ```

3. **Service management:**
   ```bash
   sudo systemctl status odoo-enterprise
   sudo systemctl restart odoo-enterprise
   sudo systemctl stop odoo-enterprise
   ```

## 📝 Post-Deployment Checklist

- [ ] Change all default passwords
- [ ] Configure SSL certificates
- [ ] Set up database backups
- [ ] Configure email settings in Odoo
- [ ] Test all functionality
- [ ] Set up monitoring
- [ ] Configure log rotation
- [ ] Document your configuration
- [ ] Test disaster recovery procedures

## 🆘 Support and Resources

- **Odoo Documentation**: https://www.odoo.com/documentation/
- **Docker Documentation**: https://docs.docker.com/
- **Ubuntu Server Guide**: https://ubuntu.com/server/docs
- **Project Repository**: https://github.com/yourusername/AdmasAfroLink

---

**Note**: This deployment is optimized for Ubuntu Server 24 LTS and includes production-ready configurations. Always test in a staging environment before deploying to production.
