# Nginx Configuration for AdmasAfroLink Odoo

## Your current configuration looks good! Here's an optimized version:

```nginx
server {
    listen       80;
    listen       [::]:80;
    server_name  64.225.79.153;

    access_log  /var/log/nginx/odoo.access.log;
    error_log   /var/log/nginx/odoo.error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Increase client max body size for file uploads
    client_max_body_size 100M;

    # Main location block
    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr; 
        proxy_set_header X-Forwarded-Host $host; 
        proxy_set_header X-Forwarded-Proto $scheme;  # Use $scheme instead of hardcoded https
        proxy_set_header Host $host;
        
        # Important: Don't add /web here, let Odoo handle routing
        proxy_pass http://localhost:8069;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Handle longpolling separately for better performance
    location /longpolling {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;
        
        proxy_pass http://localhost:8072;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Longer timeout for longpolling
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }

    # Static files caching (optional optimization)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:8069;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Cache static files
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

## Complete Setup Commands:

### 1. Install Nginx (if not already installed):
```bash
sudo apt update
sudo apt install nginx -y
```

### 2. Create the Nginx configuration:
```bash
sudo nano /etc/nginx/sites-available/admasafrolink
```

### 3. Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/admasafrolink /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default  # Remove default site
```

### 4. Test and restart Nginx:
```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 5. Update firewall:
```bash
sudo ufw allow 'Nginx Full'
sudo ufw status
```

## SSL Setup (Recommended for Production):

### Option 1: Let's Encrypt (Free SSL):
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Option 2: Manual SSL Configuration:
```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name 64.225.79.153;

    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;
    
    # SSL Security settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    # Rest of configuration same as above...
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name 64.225.79.153;
    return 301 https://$server_name$request_uri;
}
```

## Testing Your Setup:

```bash
# Test Nginx configuration
sudo nginx -t

# Check if Nginx is running
sudo systemctl status nginx

# Test external access
curl -I http://64.225.79.153

# Check logs if issues
sudo tail -f /var/log/nginx/odoo.access.log
sudo tail -f /var/log/nginx/odoo.error.log
```

## Key Improvements Made:

1. **Removed `/web` from proxy_pass** - Let Odoo handle all routing
2. **Added longpolling support** - Better real-time performance  
3. **Security headers** - XSS protection, frame options
4. **Proper timeout settings** - Handle long requests
5. **Static file optimization** - Better caching
6. **WebSocket support** - For real-time features
7. **Used `$scheme`** - Automatically detects HTTP/HTTPS

Your Odoo should now be accessible via http://64.225.79.153 with better performance and security!
