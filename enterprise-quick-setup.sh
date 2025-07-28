#!/bin/bash

# AdmasAfroLink Enterprise Quick Setup
# Run this after enterprise upgrade to quickly configure your system

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
   ___      _                   ___   __           _     _       _    
  / _ \  __| | _ __  ___  __ _ / _ \ / _|_ __ ___ | |   (_)_ __ | | __
 / /_\ |/ _` || '__|/ __|/ _` | | | | |_| '__/ _ \| |   | | '_ \| |/ /
 /  _  | (_| || |   \__ | (_| | |_| |  _| | | (_) | |___| | | | |   < 
 \_/ \_|\__,_||_|   |___/\__,_|\___/|_| |_|  \___/|_____|_|_| |_|_|\_\
                                                                      
Enterprise Quick Setup
EOF
echo -e "${NC}"

# Function to enable essential enterprise modules
enable_enterprise_modules() {
    echo -e "${GREEN}📦 Enabling Essential Enterprise Modules...${NC}"
    
    read -p "Enter your database name: " db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}❌ Database name is required${NC}"
        return 1
    fi
    
    echo "Installing core enterprise modules..."
    
    # Core enterprise modules
    modules=(
        "account_enterprise"
        "hr_enterprise" 
        "sale_enterprise"
        "project_enterprise"
        "stock_enterprise"
        "website_enterprise"
    )
    
    for module in "${modules[@]}"; do
        echo "Installing: $module"
        if docker-compose run --rm odoo_enterprise odoo -d "$db_name" -i "$module" --stop-after-init --log-level=error; then
            echo "✅ $module installed"
        else
            echo "⚠️  $module failed or already installed"
        fi
    done
    
    echo "Restarting Odoo Enterprise..."
    docker-compose restart odoo_enterprise
    
    echo -e "${GREEN}✅ Enterprise modules enabled!${NC}"
}

# Function to create admin user
create_admin_user() {
    echo -e "${GREEN}👤 Creating Admin User...${NC}"
    
    read -p "Enter database name: " db_name
    read -p "Enter admin email: " admin_email
    read -s -p "Enter admin password: " admin_password
    echo ""
    
    # Create admin user
    cat > /tmp/create_admin.py << EOF
import xmlrpc.client

url = 'http://localhost:8069'
db = '$db_name'
username = 'admin'
password = '$admin_password'

common = xmlrpc.client.ServerProxy('{}/xmlrpc/2/common'.format(url))
uid = common.authenticate(db, username, 'admin', {})

if uid:
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    # Update admin user
    models.execute_kw(db, uid, 'admin', 'res.users', 'write', [[uid], {
        'email': '$admin_email',
        'name': 'AdmasAfroLink Admin'
    }])
    print("✅ Admin user updated")
else:
    print("❌ Could not authenticate")
EOF
    
    python3 /tmp/create_admin.py
    rm /tmp/create_admin.py
}

# Function to configure company
configure_company() {
    echo -e "${GREEN}🏢 Company Configuration${NC}"
    
    echo "Configure your company details in Odoo:"
    echo "1. Go to: http://64.225.79.153/web#action=base.action_res_company_form"
    echo "2. Update company name, address, logo"
    echo "3. Set currency and timezone"
    echo "4. Configure email settings"
    echo ""
    echo "Or use the web interface to configure manually."
}

# Function to check system status
check_system_status() {
    echo -e "${GREEN}🔍 System Status Check${NC}"
    
    echo "Docker containers status:"
    docker-compose ps
    echo ""
    
    echo "Testing Odoo connection..."
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8069 | grep -q "200\|302"; then
        echo "✅ Odoo is running"
    else
        echo "❌ Odoo is not accessible"
    fi
    
    echo ""
    echo "Database status:"
    docker-compose exec odoo_postgres psql -U odoo -l
}

# Function to show next steps
show_next_steps() {
    echo -e "${BLUE}"
    cat << EOF
🎉 Enterprise Setup Complete!

Next Steps:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 🌐 Access your system:
   http://64.225.79.153

2. 🔧 Run configuration wizard:
   ./enterprise-config-wizard.sh

3. 📊 Configure specific modules:
   - Accounting: Enable multi-currency, chart of accounts
   - HR: Set up employees, time off policies
   - Sales: Configure products, pricing rules
   - Project: Set up project templates, timesheets

4. 📱 Mobile app setup:
   Download Odoo app and connect to: http://64.225.79.153

5. 🔒 Security (Recommended):
   - Setup SSL certificate
   - Configure firewall rules
   - Enable two-factor authentication

6. 💾 Backup (Essential):
   - Test backup/restore procedures
   - Schedule regular backups

📖 Documentation: https://www.odoo.com/documentation/17.0/
🎯 Enterprise Features: https://www.odoo.com/app

EOF
    echo -e "${NC}"
}

# Main execution
main() {
    echo "🚀 Starting AdmasAfroLink Enterprise Quick Setup..."
    echo ""
    
    # Check prerequisites
    if [[ ! -f "docker-compose.yml" ]]; then
        echo -e "${RED}❌ Please run from AdmasAfroLink directory${NC}"
        exit 1
    fi
    
    # Menu
    echo "Select setup options:"
    echo "1. 📦 Enable Enterprise Modules"
    echo "2. 👤 Configure Admin User"
    echo "3. 🏢 Company Configuration Guide"
    echo "4. 🔍 Check System Status"
    echo "5. 🎯 All Steps + Next Steps"
    echo ""
    
    read -p "Choose option (1-5): " choice
    
    case $choice in
        1)
            enable_enterprise_modules
            ;;
        2)
            create_admin_user
            ;;
        3)
            configure_company
            ;;
        4)
            check_system_status
            ;;
        5)
            enable_enterprise_modules
            echo ""
            configure_company
            echo ""
            check_system_status
            echo ""
            show_next_steps
            ;;
        *)
            echo "❌ Invalid option"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ Quick setup completed!${NC}"
    echo "Run './enterprise-config-wizard.sh' for detailed configuration."
}

main "$@"
