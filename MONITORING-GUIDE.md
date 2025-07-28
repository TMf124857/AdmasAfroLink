# AdmasAfroLink Monitoring & Troubleshooting Guide

## 📊 Current Status: ✅ WORKING PERFECTLY

Based on your nginx logs, your system is now functioning correctly:

### Log Analysis:
- **16:00:35-38**: 502 errors (startup phase - normal)
- **16:02:04**: 303 redirects (Odoo ready)
- **16:18:08**: 200 OK (fully operational)

## 🔍 Monitoring Commands

### Real-time Log Monitoring:
```bash
# Nginx access logs
sudo tail -f /var/log/nginx/odoo.access.log

# Nginx error logs  
sudo tail -f /var/log/nginx/odoo.error.log

# Odoo application logs
docker-compose logs -f odoo_enterprise

# All services logs
docker-compose logs -f
```

### System Status Checks:
```bash
# Check all services
docker-compose ps

# Check Nginx status
sudo systemctl status nginx

# Check system resources
htop
df -h
free -h

# Check network connections
sudo netstat -tulpn | grep -E "(80|8069|8072|5432|6379)"
```

### Health Check Script:
```bash
#!/bin/bash
echo "=== AdmasAfroLink Health Check ==="
echo "Date: $(date)"
echo ""

# Check Docker services
echo "🐳 Docker Services:"
docker-compose ps

echo ""
echo "🌐 Nginx Status:"
sudo systemctl is-active nginx

echo ""
echo "📡 Network Tests:"
echo "Local Odoo: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:8069)"
echo "External Access: $(curl -s -o /dev/null -w '%{http_code}' http://64.225.79.153)"

echo ""
echo "💾 System Resources:"
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)% used"
echo "RAM: $(free | grep Mem | awk '{printf "%.1f%% used", $3/$2 * 100.0}')"
echo "Disk: $(df -h / | awk 'NR==2{printf "%s used", $5}')"

echo ""
echo "🔗 Recent Access (last 5 requests):"
sudo tail -5 /var/log/nginx/odoo.access.log
```

## 🚨 Troubleshooting Common Issues

### 502 Bad Gateway:
```bash
# Check if Odoo is running
docker-compose ps odoo_enterprise

# Restart Odoo if needed
docker-compose restart odoo_enterprise

# Check Odoo logs for errors
docker-compose logs odoo_enterprise --tail=50
```

### 503 Service Unavailable:
```bash
# Check Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Check if backend is accessible
curl -I http://localhost:8069
```

### Performance Issues:
```bash
# Check resource usage
docker stats

# Check database connections
docker-compose exec odoo_postgres psql -U odoo -c "SELECT count(*) FROM pg_stat_activity;"

# Check Redis memory usage
docker-compose exec odoo_redis redis-cli info memory
```

## 📈 Performance Monitoring

### Database Performance:
```bash
# Check slow queries
docker-compose exec odoo_postgres psql -U odoo -c "
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;"
```

### Nginx Performance:
```bash
# Check response times
sudo tail -1000 /var/log/nginx/odoo.access.log | awk '{print $NF}' | sort -n | tail -10

# Count response codes
sudo tail -1000 /var/log/nginx/odoo.access.log | awk '{print $9}' | sort | uniq -c
```

## 🔐 Security Monitoring

### Check Failed Login Attempts:
```bash
# Check Odoo authentication logs
docker-compose logs odoo_enterprise | grep -i "authentication\|login\|failed"

# Monitor unusual access patterns
sudo tail -100 /var/log/nginx/odoo.access.log | awk '{print $1}' | sort | uniq -c | sort -nr
```

### Firewall Status:
```bash
sudo ufw status verbose
```

## 📋 Daily Maintenance Tasks

### Backup Script:
```bash
#!/bin/bash
BACKUP_DIR="/home/admas/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
docker-compose exec -T odoo_postgres pg_dump -U odoo -d odoo > $BACKUP_DIR/db_backup_$DATE.sql

# Backup filestore
tar -czf $BACKUP_DIR/filestore_backup_$DATE.tar.gz -C /home/admas/AdmasAfroLink/volumes/odoo .

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

### Log Rotation:
```bash
# Add to /etc/logrotate.d/admasafrolink
/var/log/nginx/odoo.*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 www-data www-data
    postrotate
        systemctl reload nginx
    endscript
}
```

## 🎯 Performance Optimization Tips

### Nginx Optimization:
```nginx
# Add to your nginx config
worker_processes auto;
worker_connections 1024;

# Enable gzip compression
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

# Enable browser caching
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Docker Optimization:
```bash
# Limit container resources if needed
# Add to docker-compose.yml:
services:
  odoo_enterprise:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

## 📞 Emergency Response

### If Site Goes Down:
1. Check service status: `docker-compose ps`
2. Check nginx: `sudo systemctl status nginx`
3. Check logs: `docker-compose logs --tail=50`
4. Restart services: `docker-compose restart`
5. Check external access: `curl -I http://64.225.79.153`

### Contact Information:
- Server IP: 64.225.79.153
- Admin User: admas
- Project Path: /home/admas/AdmasAfroLink
- Nginx Config: /etc/nginx/sites-available/odoo.conf

Your AdmasAfroLink system is now fully operational and production-ready! 🚀
