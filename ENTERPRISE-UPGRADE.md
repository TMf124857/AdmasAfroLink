# Odoo Community to Enterprise Upgrade Guide

This guide walks you through upgrading your Docker-based Odoo Community installation to Odoo Enterprise.

## 📋 Prerequisites

Before starting the upgrade:

1. **Valid Odoo Enterprise Subscription** - You need a valid subscription from Odoo
2. **Enterprise Addons Access** - Access to enterprise addons repository or download
3. **Running Community Installation** - Your current setup should be working
4. **Backup Strategy** - Ensure you can restore if needed

## 🔄 Upgrade Process

### Step 1: Backup Your Current Installation

```bash
# Create a backup of your current database
docker-compose exec -T db pg_dump -U odoo odoo > community_backup_$(date +%Y%m%d_%H%M%S).sql

# Also backup your current configuration
cp -r config config_backup_$(date +%Y%m%d_%H%M%S)
```

### Step 2: Obtain Enterprise Addons

You have several options to get enterprise addons:

#### Option A: Git Repository (if you have access)
```bash
# Clone enterprise repository (requires subscription access)
git clone https://github.com/odoo/enterprise.git enterprise-temp
cp -r enterprise-temp/* enterprise/
rm -rf enterprise-temp
```

#### Option B: Download from Odoo.com
1. Login to your Odoo account at odoo.com
2. Go to your subscription/downloads section
3. Download the enterprise addons for version 17.0
4. Extract to the `./enterprise/` directory

#### Option C: Request Access
Contact Odoo support to get access to enterprise addons.

### Step 3: Verify Enterprise Addons

```bash
# Check if enterprise addons are in place
ls -la enterprise/

# You should see directories like:
# - web_enterprise
# - account_accountant
# - project_enterprise
# - etc.
```

### Step 4: Run the Upgrade Script

```bash
# Make the script executable
chmod +x upgrade-to-enterprise.sh

# Run the full upgrade
./upgrade-to-enterprise.sh full-upgrade
```

### Step 5: Manual Upgrade (Alternative)

If you prefer manual steps:

```bash
# 1. Stop Odoo service
docker-compose stop odoo

# 2. Install web_enterprise module
docker-compose run --rm odoo odoo --config=/etc/odoo/odoo.conf -d odoo -i web_enterprise --stop-after-init

# 3. Start all services
docker-compose up -d

# 4. Wait for services to be ready
sleep 30
```

## 🔑 Activating Enterprise Features

After the upgrade:

1. **Access Odoo**: Go to http://localhost:8069
2. **Login**: Use your existing credentials (admin/admin123)
3. **Navigate to Settings**: Go to Settings > General Settings
4. **Find Enterprise Section**: Look for "Odoo Enterprise" section
5. **Enter Subscription Code**: Input the code from your Odoo subscription email
6. **Activate**: Click activate to enable enterprise features

## 🏢 Enterprise Features Available

After activation, you'll have access to:

### Core Enterprise Modules:
- **Web Enterprise**: Enhanced web interface
- **Accounting**: Advanced accounting features
- **Project**: Project management enhancements
- **Manufacturing**: MRP and manufacturing
- **Marketing**: Advanced marketing tools
- **Field Service**: Field service management
- **Studio**: Custom app builder

### To Install Enterprise Apps:
1. Go to **Apps** menu
2. Remove "Apps" filter to see all available apps
3. Look for apps with "Enterprise" badge
4. Install the ones you need

## 🔧 Troubleshooting

### Common Issues:

#### 1. Enterprise Addons Not Found
```bash
# Check if addons are in the right place
ls -la enterprise/
# Ensure the path is correctly mounted in docker-compose.yml
```

#### 2. Module Installation Fails
```bash
# Check logs for detailed error
docker-compose logs odoo

# Try manual installation
docker-compose exec odoo odoo --config=/etc/odoo/odoo.conf -d odoo -i web_enterprise --stop-after-init
```

#### 3. Subscription Code Not Accepted
- Verify your subscription is active
- Check if code was entered correctly
- Ensure your database name matches subscription
- Contact Odoo support if issues persist

#### 4. Services Won't Start
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart
```

## 🔄 Rollback Process

If you need to rollback to Community:

```bash
# 1. Stop services
docker-compose down

# 2. Restore community backup
docker-compose up -d db
cat community_backup_YYYYMMDD_HHMMSS.sql | docker-compose exec -T db psql -U odoo odoo

# 3. Remove enterprise addons (optional)
rm -rf enterprise/*

# 4. Restart services
docker-compose up -d
```

## 📞 Support

### Getting Help:
1. **Check Logs**: `docker-compose logs -f odoo`
2. **Odoo Documentation**: https://www.odoo.com/documentation/
3. **Odoo Support**: Contact through your subscription
4. **Community Forum**: https://www.odoo.com/forum/

### Useful Commands:
```bash
# View current modules
docker-compose exec odoo odoo shell --config=/etc/odoo/odoo.conf
# In shell: self.env['ir.module.module'].search([('state', '=', 'installed')])

# Update module list
docker-compose exec odoo odoo --config=/etc/odoo/odoo.conf -d odoo -u all --stop-after-init

# Check enterprise status
grep -r "web_enterprise" enterprise/
```

---

**Note**: Always test the upgrade process in a development environment before applying to production. Keep backups and have a rollback plan ready.
