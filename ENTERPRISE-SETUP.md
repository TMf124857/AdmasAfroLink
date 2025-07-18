# Odoo Enterprise Setup Guide

## 🏢 Odoo Enterprise Configuration

Your Docker Compose setup is now configured for **Odoo Enterprise**. Here's what you need to know:

### ✅ Current Configuration

1. **Docker Image**: `odoo:17.0` (Official Odoo image)
2. **Enterprise Addons Path**: `./enterprise` → `/mnt/enterprise-addons`
3. **Community Addons Path**: `./addons` → `/mnt/extra-addons`
4. **Configuration**: `addons_path` includes both enterprise and community addons

### 📦 Getting Enterprise Addons

#### Option 1: Official Odoo Enterprise (Recommended)
If you have an **Odoo Enterprise subscription**:

1. **Download from Odoo.com**:
   - Go to [Odoo.com](https://www.odoo.com/my/home)
   - Login to your account
   - Download Odoo Enterprise 17.0
   - Extract the `addons` folder to `./enterprise/`

2. **Git Clone (with access)**:
   ```bash
   # If you have access to the private repository
   git clone https://github.com/odoo/enterprise.git ./enterprise
   cd ./enterprise
   git checkout 17.0
   ```

#### Option 2: Community Alternatives
For **community/open-source** alternatives:

1. **OCA (Odoo Community Association)**:
   ```bash
   # Install OCA modules that provide similar functionality
   git clone https://github.com/OCA/server-tools.git ./addons/server-tools
   git clone https://github.com/OCA/web.git ./addons/web
   git clone https://github.com/OCA/reporting-engine.git ./addons/reporting-engine
   ```

2. **Third-party Enterprise-like modules**:
   - Search for specific modules on [apps.odoo.com](https://apps.odoo.com)
   - Download and place in `./addons/` directory

### 🔧 Configuration Details

#### Docker Compose Changes Made:
- ✅ Added Redis dependency to Odoo service
- ✅ Fixed enterprise addons mounting path
- ✅ Increased Redis memory to 512MB for better performance
- ✅ Added ADDONS_PATH environment variable

#### Odoo Configuration (`config/odoo.conf`):
```ini
# Enterprise addons are included in the path
addons_path = /mnt/extra-addons,/mnt/enterprise-addons,/usr/lib/python3/dist-packages/odoo/addons

# Session storage with Redis (required for multi-worker setup)
session_store = redis
session_redis_host = redis
session_redis_port = 6379
```

### 🚀 Starting Your Enterprise Setup

1. **Ensure Enterprise addons are in place**:
   ```bash
   # Check if enterprise directory has modules
   ls -la ./enterprise/
   ```

2. **Start the services**:
   ```bash
   # Start all services
   docker-compose up -d
   
   # Or with tools (pgAdmin)
   docker-compose --profile tools up -d
   ```

3. **Initialize database** (first time only):
   ```bash
   # Linux/Mac
   ./init-odoo.sh
   
   # Windows
   init-odoo.bat
   ```

4. **Access Odoo**:
   - URL: http://localhost:8069
   - Admin: admin
   - Password: admin123

### 🔍 Verifying Enterprise Setup

1. **Check loaded modules**:
   - Go to Apps menu in Odoo
   - Look for Enterprise modules (they usually have "Enterprise" in the name)
   - Examples: Accounting, CRM, HR, Manufacturing, etc.

2. **Check logs**:
   ```bash
   docker-compose logs odoo | grep -i enterprise
   ```

3. **Database Apps**:
   - Enable Developer Mode
   - Go to Apps → Update Apps List
   - Search for enterprise-specific modules

### 📋 Enterprise Modules Examples

Common Odoo Enterprise modules include:
- **Accounting**: Advanced accounting features
- **CRM**: Customer relationship management
- **HR**: Human resources management
- **Manufacturing**: MRP and manufacturing
- **Inventory**: Advanced inventory management
- **Project**: Project management
- **Marketing**: Email marketing, social media
- **Website**: Advanced website builder
- **Studio**: Custom app builder
- **Documents**: Document management

### 🛠️ Troubleshooting

1. **No Enterprise modules visible**:
   - Check if `./enterprise/` has module folders
   - Verify `addons_path` in `odoo.conf`
   - Restart Odoo: `docker-compose restart odoo`

2. **Module loading errors**:
   - Check compatibility with Odoo 17.0
   - Review logs: `docker-compose logs odoo`

3. **Performance issues**:
   - Increase worker count in `odoo.conf`
   - Monitor Redis usage
   - Check resource limits

### 🔒 Security Note

- **Never commit enterprise addons to public repositories**
- Add `enterprise/` to `.gitignore` if using official enterprise addons
- Use secure passwords in production

### 📖 Documentation

- [Odoo Enterprise Documentation](https://www.odoo.com/documentation/17.0/)
- [Docker Hub Odoo](https://hub.docker.com/_/odoo)
- [OCA GitHub](https://github.com/OCA)

---

**Ready to deploy!** Your setup is now configured for Odoo Enterprise. Simply add your enterprise addons to the `./enterprise/` directory and start the services.
