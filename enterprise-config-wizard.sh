#!/bin/bash

# AdmasAfroLink Enterprise Configuration Wizard
# Helps configure enterprise features after upgrade

set -e

# Colors
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
                                                                      
Enterprise Configuration Wizard
EOF
echo -e "${NC}"

# Function to configure accounting
configure_accounting() {
    echo -e "${GREEN}📊 Configuring Enterprise Accounting...${NC}"
    
    cat << EOF

🏦 Accounting Configuration Options:
1. Multi-currency support
2. Advanced financial reports
3. Budget management
4. Asset management
5. Analytic accounting

Manual steps needed:
- Go to http://64.225.79.153/web#action=base.action_res_config_settings
- Navigate to Invoicing section
- Enable desired enterprise features
- Configure chart of accounts
- Set up payment terms and methods

EOF
}

# Function to configure HR
configure_hr() {
    echo -e "${GREEN}👥 Configuring Enterprise HR...${NC}"
    
    cat << EOF

🏢 HR Configuration Options:
1. Time off management
2. Expense management  
3. Timesheet tracking
4. Payroll integration
5. Employee appraisals

Manual steps needed:
- Access http://64.225.79.153/web#action=hr.hr_employee_action
- Set up employee records
- Configure time off types
- Set up expense categories
- Configure approval workflows

EOF
}

# Function to configure sales
configure_sales() {
    echo -e "${GREEN}💼 Configuring Enterprise Sales...${NC}"
    
    cat << EOF

🛒 Sales Configuration Options:
1. Advanced quotation templates
2. Subscription management
3. Commission tracking
4. Advanced pricing rules
5. Sales forecasting

Manual steps needed:
- Go to http://64.225.79.153/web#action=sale.action_orders
- Set up product categories
- Configure pricing strategies
- Set up sales teams
- Configure quotation templates

EOF
}

# Function to configure project management
configure_project() {
    echo -e "${GREEN}📋 Configuring Enterprise Project Management...${NC}"
    
    cat << EOF

🎯 Project Management Options:
1. Gantt charts
2. Advanced task dependencies
3. Resource planning
4. Project profitability
5. Burndown charts

Manual steps needed:
- Access http://64.225.79.153/web#action=project.action_project_project_user
- Set up project templates
- Configure task stages
- Set up resource allocation
- Configure time tracking

EOF
}

# Function to install additional modules
install_additional_modules() {
    echo -e "${GREEN}📦 Installing Additional Enterprise Modules...${NC}"
    
    echo "Available enterprise modules to install:"
    echo "1. Manufacturing (mrp_enterprise)"
    echo "2. Inventory Barcode (stock_barcode)" 
    echo "3. Quality Control (quality_control)"
    echo "4. Maintenance (maintenance)"
    echo "5. Marketing Automation (marketing_automation)"
    echo "6. eCommerce Enterprise (website_sale_enterprise)"
    echo ""
    
    read -p "Enter module numbers to install (e.g., 1,3,5) or 'skip': " modules_choice
    
    if [[ "$modules_choice" != "skip" ]]; then
        # Map choices to module names
        declare -A module_map=(
            [1]="mrp_enterprise"
            [2]="stock_barcode"
            [3]="quality_control"
            [4]="maintenance"
            [5]="marketing_automation"
            [6]="website_sale_enterprise"
        )
        
        # Parse user input
        IFS=',' read -ra MODULES <<< "$modules_choice"
        for choice in "${MODULES[@]}"; do
            choice=$(echo "$choice" | tr -d ' ')
            if [[ -n "${module_map[$choice]}" ]]; then
                module_name="${module_map[$choice]}"
                echo "Installing: $module_name"
                
                # Get database name
                read -p "Enter database name: " db_name
                
                # Install module
                if docker-compose run --rm odoo_enterprise odoo -d "$db_name" -i "$module_name" --stop-after-init; then
                    echo "✅ Successfully installed: $module_name"
                else
                    echo "⚠️  Failed to install: $module_name"
                fi
            fi
        done
        
        echo "Restarting Odoo to apply changes..."
        docker-compose restart odoo_enterprise
    fi
}

# Function to create demo data
create_demo_data() {
    echo -e "${GREEN}🎭 Creating Demo Data...${NC}"
    
    read -p "Create demo data for testing enterprise features? (y/n): " create_demo
    
    if [[ "$create_demo" == "y" ]]; then
        read -p "Enter database name: " db_name
        
        echo "Creating demo data..."
        docker-compose run --rm odoo_enterprise odoo -d "$db_name" --demo=all --stop-after-init
        
        echo "✅ Demo data created. You can now explore enterprise features with sample data."
    fi
}

# Function to setup SSL
setup_ssl() {
    echo -e "${GREEN}🔒 Setting up SSL Certificate...${NC}"
    
    read -p "Do you want to set up SSL with Let's Encrypt? (y/n): " setup_ssl_choice
    
    if [[ "$setup_ssl_choice" == "y" ]]; then
        read -p "Enter your domain name (e.g., admasafrolink.com): " domain_name
        
        echo "Installing Certbot..."
        sudo apt update
        sudo apt install certbot python3-certbot-nginx -y
        
        echo "Obtaining SSL certificate..."
        sudo certbot --nginx -d "$domain_name"
        
        echo "Setting up auto-renewal..."
        echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
        
        echo "✅ SSL certificate installed for $domain_name"
        echo "🌐 Your secure site: https://$domain_name"
    fi
}

# Function to configure backups
configure_backups() {
    echo -e "${GREEN}💾 Configuring Automated Backups...${NC}"
    
    cat > /tmp/backup-enterprise.sh << 'EOF'
#!/bin/bash

# AdmasAfroLink Enterprise Backup Script
BACKUP_DIR="/home/admas/backups/enterprise"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

mkdir -p "$BACKUP_DIR"

# Backup all databases
docker-compose exec -T odoo_postgres pg_dumpall -U odoo > "$BACKUP_DIR/all_databases_$DATE.sql"

# Backup filestore
tar -czf "$BACKUP_DIR/filestore_$DATE.tar.gz" -C /home/admas/AdmasAfroLink/volumes/odoo .

# Backup configuration
tar -czf "$BACKUP_DIR/config_$DATE.tar.gz" /home/admas/AdmasAfroLink/config/

# Clean old backups
find "$BACKUP_DIR" -name "*.sql" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: $DATE"
EOF

    sudo mv /tmp/backup-enterprise.sh /usr/local/bin/
    sudo chmod +x /usr/local/bin/backup-enterprise.sh
    
    # Setup cron job
    read -p "Setup daily backups at 2 AM? (y/n): " setup_cron
    if [[ "$setup_cron" == "y" ]]; then
        (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-enterprise.sh") | crontab -
        echo "✅ Daily backup scheduled at 2 AM"
    fi
}

# Function to show enterprise dashboard
show_enterprise_dashboard() {
    echo -e "${GREEN}📊 Enterprise Dashboard Links${NC}"
    
    cat << EOF

🌐 AdmasAfroLink Enterprise URLs:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏠 Main Dashboard:     http://64.225.79.153
🔑 Database Manager:   http://64.225.79.153/web/database/manager
📱 Apps Menu:          http://64.225.79.153/web#action=base.open_module_tree

📊 Enterprise Modules:
━━━━━━━━━━━━━━━━━━━━━
💰 Accounting:         http://64.225.79.153/web#action=account.action_account_config
👥 HR Management:      http://64.225.79.153/web#action=hr.menu_hr_root
💼 Sales:              http://64.225.79.153/web#action=sale.sale_menu_root
📋 Project:            http://64.225.79.153/web#action=project.menu_main_pm
🏭 Manufacturing:      http://64.225.79.153/web#action=mrp.menu_mrp_root
📦 Inventory:          http://64.225.79.153/web#action=stock.menu_stock_root

⚙️  Settings:          http://64.225.79.153/web#action=base.action_res_config_settings

EOF
}

# Main menu
main_menu() {
    while true; do
        echo -e "${BLUE}"
        echo "🎯 AdmasAfroLink Enterprise Configuration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "${NC}"
        echo "1. 📊 Configure Accounting"
        echo "2. 👥 Configure HR"
        echo "3. 💼 Configure Sales"
        echo "4. 📋 Configure Project Management"
        echo "5. 📦 Install Additional Modules"
        echo "6. 🎭 Create Demo Data"
        echo "7. 🔒 Setup SSL Certificate"
        echo "8. 💾 Configure Backups"
        echo "9. 📊 Show Enterprise Dashboard"
        echo "10. ❌ Exit"
        echo ""
        
        read -p "Choose option (1-10): " choice
        
        case $choice in
            1) configure_accounting ;;
            2) configure_hr ;;
            3) configure_sales ;;
            4) configure_project ;;
            5) install_additional_modules ;;
            6) create_demo_data ;;
            7) setup_ssl ;;
            8) configure_backups ;;
            9) show_enterprise_dashboard ;;
            10) echo "👋 Goodbye!"; exit 0 ;;
            *) echo "❌ Invalid option" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Check if we're in the right directory
if [[ ! -f "docker-compose.yml" ]]; then
    echo -e "${RED}❌ Please run this script from the AdmasAfroLink directory${NC}"
    exit 1
fi

# Start the wizard
clear
main_menu
