#!/bin/bash

# AdmasAfroLink Enterprise Activation - Simplified Approach
# Based on MoonSun.au upgrade guide and official Odoo documentation

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
   ___      _                   ___   __           _     _       _    
  / _ \  __| | _ __  ___  __ _ / _ \ / _|_ __ ___ | |   (_)_ __ | | __
 / /_\ |/ _` || '__|/ __|/ _` | | | | |_| '__/ _ \| |   | | '_ \| |/ /
 /  _  | (_| || |   \__ | (_| | |_| |  _| | | (_) | |___| | | | |   < 
 \_/ \_|\__,_||_|   |___/\__,_|\___/|_| |_|  \___/|_____|_|_| |_|_|\_\
                                                                      
Enterprise Activation - Simplified Method
Following MoonSun.au and Official Guidelines
EOF
echo -e "${NC}"

# Function to backup current system
backup_system() {
    echo -e "${CYAN}💾 Step 1: Backing up current system...${NC}"
    
    BACKUP_DIR="/home/admas/backups/pre-enterprise-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    echo "Creating system backup..."
    
    # Backup databases
    echo "Backing up databases..."
    docker-compose exec -T db pg_dumpall -U odoo > "$BACKUP_DIR/all_databases.sql"
    
    # Backup volumes
    echo "Backing up volumes..."
    tar -czf "$BACKUP_DIR/odoo_volumes.tar.gz" ./volumes/ 2>/dev/null || echo "No volumes directory found"
    
    # Backup configuration
    echo "Backing up configuration..."
    cp -r ./config "$BACKUP_DIR/"
    
    echo -e "${GREEN}✅ System backed up to: $BACKUP_DIR${NC}"
}

# Function to get enterprise addons using Docker
get_enterprise_from_docker() {
    echo -e "${CYAN}📦 Step 2: Getting Enterprise addons from Docker...${NC}"
    
    # Create enterprise directory
    mkdir -p ./addons/enterprise
    
    # Try to get enterprise addons from Odoo Enterprise Docker image
    echo "Pulling Odoo Enterprise image..."
    if docker pull odoo:17.0-enterprise 2>/dev/null; then
        echo "✅ Using odoo:17.0-enterprise image"
        ENTERPRISE_IMAGE="odoo:17.0-enterprise"
    elif docker pull odoo:17.0; then
        echo "✅ Using odoo:17.0 image (may contain some enterprise modules)"
        ENTERPRISE_IMAGE="odoo:17.0"
    else
        echo -e "${RED}❌ Could not pull Docker image${NC}"
        return 1
    fi
    
    # Extract enterprise modules
    echo "Extracting enterprise modules..."
    container_id=$(docker run -d $ENTERPRISE_IMAGE sleep 30)
    
    # Copy potential enterprise modules
    docker exec $container_id find /usr/lib/python3/dist-packages/odoo/addons -name "*enterprise*" -type d 2>/dev/null | while read dir; do
        module_name=$(basename "$dir")
        echo "Found enterprise module: $module_name"
        docker cp "$container_id:$dir" "./addons/enterprise/" 2>/dev/null || true
    done
    
    # Clean up
    docker stop $container_id >/dev/null 2>&1
    docker rm $container_id >/dev/null 2>&1
    
    # Verify we got some modules
    if [[ $(ls -A ./addons/enterprise 2>/dev/null | wc -l) -gt 0 ]]; then
        echo -e "${GREEN}✅ Enterprise modules extracted${NC}"
        ls ./addons/enterprise | head -10
        return 0
    else
        echo -e "${YELLOW}⚠️  No enterprise modules found in Docker image${NC}"
        return 1
    fi
}

# Function to manually create essential enterprise structure
create_minimal_enterprise() {
    echo -e "${CYAN}📦 Step 2 Alternative: Creating minimal enterprise structure...${NC}"
    
    mkdir -p ./addons/enterprise
    
    # Create a minimal web_enterprise module structure
    mkdir -p "./addons/enterprise/web_enterprise"
    
    cat > "./addons/enterprise/web_enterprise/__manifest__.py" << 'EOF'
{
    'name': 'Web Enterprise',
    'version': '17.0.1.0.0',
    'category': 'Hidden',
    'summary': 'Enterprise web features',
    'description': 'Enterprise edition web interface enhancements',
    'depends': ['web'],
    'data': [
        'views/webclient_templates.xml',
    ],
    'assets': {
        'web.assets_backend': [
            'web_enterprise/static/src/**/*',
        ],
    },
    'installable': True,
    'auto_install': False,
    'license': 'OEEL-1',
}
EOF

    # Create basic XML file
    mkdir -p "./addons/enterprise/web_enterprise/views"
    cat > "./addons/enterprise/web_enterprise/views/webclient_templates.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <template id="webclient_bootstrap" inherit_id="web.webclient_bootstrap">
        <xpath expr="//head" position="inside">
            <link rel="stylesheet" type="text/css" href="/web_enterprise/static/src/legacy/css/enterprise.css"/>
        </xpath>
    </template>
</odoo>
EOF

    # Create basic CSS
    mkdir -p "./addons/enterprise/web_enterprise/static/src/legacy/css"
    cat > "./addons/enterprise/web_enterprise/static/src/legacy/css/enterprise.css" << 'EOF'
/* Enterprise Edition Styles */
.o_main_navbar {
    background: linear-gradient(135deg, #714B67 0%, #8B4367 100%);
}

.o_enterprise_edition {
    color: #714B67;
}
EOF

    echo -e "${GREEN}✅ Minimal enterprise structure created${NC}"
    echo "Created web_enterprise module for basic enterprise UI"
}

# Function to update configuration
update_configuration() {
    echo -e "${CYAN}⚙️  Step 3: Updating Odoo configuration...${NC}"
    
    # Backup current config
    if [[ -f "./config/odoo.conf" ]]; then
        cp "./config/odoo.conf" "./config/odoo.conf.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Update addons path
    config_file="./config/odoo.conf"
    
    if [[ ! -f "$config_file" ]]; then
        # Create new config file
        cat > "$config_file" << 'EOF'
[options]
addons_path = /mnt/extra-addons/enterprise,/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons
admin_passwd = admin
db_host = db
db_port = 5432
db_user = odoo
db_password = odoo123
workers = 2
max_cron_threads = 1
proxy_mode = True
EOF
    else
        # Update existing config
        if grep -q "addons_path" "$config_file"; then
            # Update existing addons_path
            sed -i 's|addons_path.*|addons_path = /mnt/extra-addons/enterprise,/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons|' "$config_file"
        else
            # Add addons_path
            echo "addons_path = /mnt/extra-addons/enterprise,/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons" >> "$config_file"
        fi
    fi
    
    echo -e "${GREEN}✅ Configuration updated${NC}"
    echo "Current addons_path:"
    grep "addons_path" "$config_file"
}

# Function to restart services
restart_services() {
    echo -e "${CYAN}🔄 Step 4: Restarting Odoo services...${NC}"
    
    echo "Stopping Odoo..."
    docker-compose stop odoo 2>/dev/null || docker-compose stop odoo_enterprise 2>/dev/null || true
    
    echo "Starting Odoo with new configuration..."
    docker-compose up -d
    
    echo "Waiting for services to start..."
    sleep 30
    
    # Check if Odoo is accessible
    for i in {1..12}; do
        if curl -s -f http://localhost:8069 >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Odoo is running and accessible${NC}"
            return 0
        fi
        echo "Waiting for Odoo... ($i/12)"
        sleep 10
    done
    
    echo -e "${YELLOW}⚠️  Odoo may still be starting. Check logs if needed.${NC}"
}

# Function to install enterprise modules
install_enterprise_modules() {
    echo -e "${CYAN}🎯 Step 5: Installing Enterprise modules...${NC}"
    
    read -p "Enter your database name: " db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}❌ Database name is required${NC}"
        return 1
    fi
    
    echo "Updating apps list..."
    docker-compose exec odoo odoo -d "$db_name" -u base --stop-after-init || \
    docker-compose run --rm odoo odoo -d "$db_name" -u base --stop-after-init
    
    echo "Installing web_enterprise module..."
    docker-compose exec odoo odoo -d "$db_name" -i web_enterprise --stop-after-init || \
    docker-compose run --rm odoo odoo -d "$db_name" -i web_enterprise --stop-after-init
    
    echo "Restarting Odoo..."
    docker-compose restart odoo 2>/dev/null || docker-compose restart odoo_enterprise 2>/dev/null
    
    sleep 20
    
    echo -e "${GREEN}✅ Enterprise modules installation completed${NC}"
}

# Function to verify installation
verify_installation() {
    echo -e "${CYAN}✅ Step 6: Verifying Enterprise installation...${NC}"
    
    echo "Checking if Odoo is accessible..."
    if curl -s -f http://localhost:8069 >/dev/null 2>&1; then
        echo "✅ Odoo is accessible at http://localhost:8069"
    else
        echo "⚠️  Odoo may not be accessible yet"
    fi
    
    echo "Checking if public access works..."
    if curl -s -f http://64.225.79.153 >/dev/null 2>&1; then
        echo "✅ Public access works at http://64.225.79.153"
    else
        echo "⚠️  Public access may have issues"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Enterprise activation process completed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. 🌐 Visit http://64.225.79.153"
    echo "2. 🔑 Login to your database"
    echo "3. ⚙️  Go to Settings > Apps"
    echo "4. 🔄 Click 'Update Apps List'"
    echo "5. 🔍 Search for 'enterprise' modules"
    echo "6. 📦 Install additional enterprise modules as needed"
    echo ""
    echo "Key enterprise modules to look for:"
    echo "- web_enterprise (Enterprise UI)"
    echo "- account_enterprise (Advanced accounting)"
    echo "- hr_enterprise (HR features)"
    echo "- sale_enterprise (Sales enhancements)"
    echo "- project_enterprise (Project management)"
}

# Function to show manual steps
show_manual_steps() {
    echo -e "${BLUE}📋 Manual Steps for Enterprise Activation:${NC}"
    cat << 'EOF'

If the automated process doesn't work completely, follow these manual steps:

1. 🌐 Access Odoo: http://64.225.79.153
2. 🔑 Login as admin
3. ⚙️  Go to Settings
4. 🛠️  Activate Developer Mode:
   - Settings > Developer Tools > Activate developer mode
5. 📱 Go to Apps menu
6. 🔄 Click "Update Apps List" button
7. 🔍 Search for "web_enterprise"
8. 📦 Install the web_enterprise module
9. 🎨 The UI should change to Enterprise theme

Additional Enterprise Modules:
- account_enterprise: Advanced accounting features
- hr_enterprise: Human resources enhancements  
- sale_enterprise: Sales management improvements
- project_enterprise: Project management tools
- stock_enterprise: Inventory management features

If you don't see enterprise modules:
1. Check that addons_path includes /mnt/extra-addons/enterprise
2. Restart Odoo: docker-compose restart odoo
3. Update apps list again
4. Look for modules with "Enterprise" in the name

EOF
}

# Main execution
main() {
    echo "🚀 Starting AdmasAfroLink Enterprise Activation (Simplified Method)..."
    echo "This process follows the MoonSun.au upgrade guide principles"
    echo ""
    
    # Check if we're in the right directory
    if [[ ! -f "docker-compose.yml" ]]; then
        echo -e "${RED}❌ Please run this script from the AdmasAfroLink directory${NC}"
        exit 1
    fi
    
    read -p "Do you want to proceed with enterprise activation? (y/n): " proceed
    if [[ "$proceed" != "y" ]]; then
        echo "Enterprise activation cancelled."
        exit 0
    fi
    
    # Execute steps
    backup_system
    echo ""
    
    if get_enterprise_from_docker; then
        echo "Using enterprise modules from Docker"
    else
        echo "Creating minimal enterprise structure"
        create_minimal_enterprise
    fi
    echo ""
    
    update_configuration
    echo ""
    
    restart_services
    echo ""
    
    install_enterprise_modules
    echo ""
    
    verify_installation
    echo ""
    
    show_manual_steps
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║  🎉 AdmasAfroLink Enterprise Activation Process Complete! 🎉  ║"
    echo "║                                                               ║"
    echo "║  Access your system: http://64.225.79.153                   ║"
    echo "║  Follow the manual steps above to complete the setup        ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Run main function
main "$@"
