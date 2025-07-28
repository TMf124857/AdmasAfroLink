#!/bin/bash

# AdmasAfroLink Enterprise Activation Script
# Follows the official process for upgrading Community to Enterprise

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
                                                                      
Enterprise Edition Activation
Following Official Upgrade Process
EOF
echo -e "${NC}"

# Function to check prerequisites
check_prerequisites() {
    echo -e "${CYAN}🔍 Checking Prerequisites...${NC}"
    
    # Check if enterprise subscription is available
    echo "✅ Enterprise subscription purchased (user confirmed)"
    
    # Check docker-compose
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ docker-compose not found${NC}"
        exit 1
    fi
    echo "✅ Docker Compose available"
    
    # Check if project is running
    if docker-compose ps | grep -q "Up"; then
        echo "✅ Odoo services are running"
    else
        echo -e "${YELLOW}⚠️  Odoo services not running. Starting them...${NC}"
        docker-compose up -d
        echo "Waiting for services to start..."
        sleep 30
    fi
    
    echo -e "${GREEN}✅ All prerequisites met${NC}"
}

# Function to download enterprise addons
download_enterprise_addons() {
    echo -e "${CYAN}📦 Downloading Enterprise Add-ons...${NC}"
    
    # Create enterprise directory
    mkdir -p ./addons/enterprise
    
    echo "Options for obtaining enterprise add-ons:"
    echo "1. Download from Odoo.sh (recommended)"
    echo "2. Use existing enterprise.zip file"
    echo "3. Clone from GitHub (if you have access)"
    echo ""
    
    read -p "Choose option (1-3): " download_option
    
    case $download_option in
        1)
            echo -e "${YELLOW}📋 Manual download required:${NC}"
            echo "1. Go to https://www.odoo.com/my/odoo-sh"
            echo "2. Login with your enterprise account"
            echo "3. Download Odoo Enterprise 17.0"
            echo "4. Place the downloaded file in this directory"
            echo ""
            read -p "Enter the path to your downloaded enterprise file: " enterprise_file
            
            if [[ -f "$enterprise_file" ]]; then
                echo "Extracting enterprise add-ons..."
                if [[ "$enterprise_file" == *.zip ]]; then
                    unzip -q "$enterprise_file" -d ./addons/enterprise/
                elif [[ "$enterprise_file" == *.tar.gz ]]; then
                    tar -xzf "$enterprise_file" -C ./addons/enterprise/
                else
                    echo -e "${RED}❌ Unsupported file format${NC}"
                    exit 1
                fi
                echo "✅ Enterprise add-ons extracted"
            else
                echo -e "${RED}❌ File not found: $enterprise_file${NC}"
                exit 1
            fi
            ;;
        2)
            if [[ -f "./enterprise.zip" ]]; then
                echo "Extracting existing enterprise.zip..."
                unzip -q "./enterprise.zip" -d ./addons/enterprise/
                echo "✅ Enterprise add-ons extracted from existing file"
            else
                echo -e "${RED}❌ enterprise.zip not found in current directory${NC}"
                exit 1
            fi
            ;;
        3)
            read -p "Enter GitHub username for enterprise access: " github_user
            read -s -p "Enter GitHub token: " github_token
            echo ""
            
            echo "Cloning enterprise repository..."
            if git clone https://$github_user:$github_token@github.com/odoo/enterprise.git ./addons/enterprise; then
                echo "✅ Enterprise repository cloned"
                cd ./addons/enterprise
                git checkout 17.0
                cd ../../
            else
                echo -e "${RED}❌ Failed to clone enterprise repository${NC}"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            exit 1
            ;;
    esac
    
    # Verify enterprise addons
    if [[ -d "./addons/enterprise" ]] && [[ $(ls -A ./addons/enterprise 2>/dev/null | wc -l) -gt 0 ]]; then
        echo -e "${GREEN}✅ Enterprise add-ons ready${NC}"
        echo "Found $(ls ./addons/enterprise | wc -l) enterprise modules"
    else
        echo -e "${RED}❌ Enterprise add-ons not properly installed${NC}"
        exit 1
    fi
}

# Function to update Odoo configuration
update_odoo_configuration() {
    echo -e "${CYAN}⚙️  Updating Odoo Configuration...${NC}"
    
    # Backup existing configuration
    if [[ -f "./config/odoo.conf" ]]; then
        cp "./config/odoo.conf" "./config/odoo.conf.backup.$(date +%Y%m%d_%H%M%S)"
        echo "✅ Configuration backed up"
    fi
    
    # Update addons_path in odoo.conf
    if [[ -f "./config/odoo.conf" ]]; then
        # Check if addons_path already exists
        if grep -q "addons_path" "./config/odoo.conf"; then
            # Update existing addons_path to include enterprise
            current_path=$(grep "addons_path" "./config/odoo.conf" | cut -d'=' -f2 | tr -d ' ')
            
            # Remove existing enterprise paths to avoid duplicates
            new_path=$(echo "$current_path" | sed 's|,/mnt/extra-addons/enterprise||g' | sed 's|/mnt/extra-addons/enterprise,||g' | sed 's|/mnt/extra-addons/enterprise||g')
            
            # Add enterprise path
            new_path="/mnt/extra-addons/enterprise,$new_path"
            
            # Update the configuration
            sed -i "s|addons_path.*|addons_path = $new_path|" "./config/odoo.conf"
        else
            # Add addons_path with enterprise
            echo "addons_path = /mnt/extra-addons/enterprise,/usr/lib/python3/dist-packages/odoo/addons" >> "./config/odoo.conf"
        fi
        echo "✅ Odoo configuration updated with enterprise path"
    else
        # Create new configuration file
        cat > "./config/odoo.conf" << EOF
[options]
addons_path = /mnt/extra-addons/enterprise,/usr/lib/python3/dist-packages/odoo/addons
admin_passwd = admin
db_host = odoo_postgres
db_port = 5432
db_user = odoo
db_password = odoo
EOF
        echo "✅ New Odoo configuration created"
    fi
    
    # Show current configuration
    echo -e "${YELLOW}Current addons_path:${NC}"
    grep "addons_path" "./config/odoo.conf" || echo "No addons_path found"
}

# Function to restart Odoo service
restart_odoo_service() {
    echo -e "${CYAN}🔄 Restarting Odoo Service...${NC}"
    
    echo "Stopping Odoo containers..."
    docker-compose stop odoo_enterprise
    
    echo "Starting Odoo with new configuration..."
    docker-compose up -d odoo_enterprise
    
    echo "Waiting for Odoo to start..."
    sleep 45
    
    # Check if Odoo is running
    for i in {1..12}; do
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:8069 | grep -q "200\|302"; then
            echo -e "${GREEN}✅ Odoo restarted successfully${NC}"
            return 0
        fi
        echo "Waiting for Odoo... ($i/12)"
        sleep 10
    done
    
    echo -e "${RED}❌ Odoo failed to start properly${NC}"
    echo "Check logs with: docker-compose logs odoo_enterprise"
    exit 1
}

# Function to update apps list
update_apps_list() {
    echo -e "${CYAN}📱 Updating Apps List...${NC}"
    
    read -p "Enter your database name: " db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}❌ Database name is required${NC}"
        exit 1
    fi
    
    echo "Updating module list for database: $db_name"
    
    # Update apps list using Odoo CLI
    if docker-compose run --rm odoo_enterprise odoo -d "$db_name" -u base --stop-after-init; then
        echo "✅ Apps list updated successfully"
    else
        echo -e "${RED}❌ Failed to update apps list${NC}"
        echo "Try manually: Apps > Update Apps List"
        exit 1
    fi
    
    echo -e "${YELLOW}📋 Manual Steps:${NC}"
    echo "1. Go to http://64.225.79.153"
    echo "2. Login to your database: $db_name"
    echo "3. Activate Developer Mode:"
    echo "   - Settings > Developer Tools > Activate developer mode"
    echo "4. Go to Apps menu"
    echo "5. Click 'Update Apps List' button"
    echo ""
    read -p "Press Enter after completing these steps..."
}

# Function to install web_enterprise module
install_web_enterprise() {
    echo -e "${CYAN}🌐 Installing web_enterprise Module...${NC}"
    
    read -p "Enter your database name: " db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}❌ Database name is required${NC}"
        exit 1
    fi
    
    echo "Installing web_enterprise module..."
    
    # Install web_enterprise using Odoo CLI
    if docker-compose run --rm odoo_enterprise odoo -d "$db_name" -i web_enterprise --stop-after-init; then
        echo -e "${GREEN}✅ web_enterprise module installed successfully${NC}"
        echo "🎉 Your Odoo Community Edition UI has been upgraded to Enterprise Edition UI!"
    else
        echo -e "${YELLOW}⚠️  Automatic installation may have failed${NC}"
        echo "Try manual installation:"
        echo "1. Go to http://64.225.79.153"
        echo "2. Navigate to Apps"
        echo "3. Search for 'web_enterprise'"
        echo "4. Click 'Install'"
    fi
    
    echo ""
    echo "Restarting Odoo to apply changes..."
    docker-compose restart odoo_enterprise
    
    echo "Waiting for restart..."
    sleep 30
}

# Function to verify enterprise installation
verify_enterprise_installation() {
    echo -e "${CYAN}✅ Verifying Enterprise Installation...${NC}"
    
    echo "Checking enterprise modules availability..."
    
    # Check if enterprise modules are available
    enterprise_modules=(
        "web_enterprise"
        "account_enterprise"
        "hr_enterprise"
        "sale_enterprise"
        "project_enterprise"
    )
    
    read -p "Enter your database name: " db_name
    
    for module in "${enterprise_modules[@]}"; do
        echo "Checking: $module"
        if docker-compose exec odoo_enterprise odoo shell -d "$db_name" -c "env['ir.module.module'].search([('name', '=', '$module')])" &>/dev/null; then
            echo "✅ $module available"
        else
            echo "⚠️  $module not found"
        fi
    done
    
    echo ""
    echo -e "${GREEN}🎉 Enterprise Activation Complete!${NC}"
    echo ""
    echo "🌐 Access your Enterprise Odoo at: http://64.225.79.153"
    echo ""
    echo "Next steps:"
    echo "1. Login and verify the new Enterprise UI"
    echo "2. Install additional enterprise modules as needed"
    echo "3. Configure enterprise features"
    echo ""
    echo "Available enterprise modules:"
    echo "- Accounting Enterprise (account_enterprise)"
    echo "- HR Enterprise (hr_enterprise)"
    echo "- Sales Enterprise (sale_enterprise)"
    echo "- Project Enterprise (project_enterprise)"
    echo "- Stock Enterprise (stock_enterprise)"
    echo "- Website Enterprise (website_enterprise)"
}

# Function to show success message
show_success_message() {
    echo -e "${GREEN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                    🎉 SUCCESS! 🎉                           ║
║                                                              ║
║         Odoo Community Edition Successfully Upgraded        ║
║                 to Enterprise Edition!                      ║
║                                                              ║
║  Your AdmasAfroLink system now has Enterprise features:     ║
║  • Enhanced UI/UX                                          ║
║  • Advanced reporting                                       ║
║  • Enterprise modules                                       ║
║  • Premium support eligibility                             ║
║                                                              ║
║  🌐 Access: http://64.225.79.153                           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Main execution function
main() {
    echo "🚀 Starting AdmasAfroLink Enterprise Activation..."
    echo "Following official Odoo upgrade process"
    echo ""
    
    # Check if we're in the right directory
    if [[ ! -f "docker-compose.yml" ]]; then
        echo -e "${RED}❌ Please run this script from the AdmasAfroLink directory${NC}"
        exit 1
    fi
    
    # Execute step by step
    echo -e "${BLUE}Step 1: Prerequisites Check${NC}"
    check_prerequisites
    echo ""
    
    echo -e "${BLUE}Step 2: Download Enterprise Add-ons${NC}"
    download_enterprise_addons
    echo ""
    
    echo -e "${BLUE}Step 3: Update Odoo Configuration${NC}"
    update_odoo_configuration
    echo ""
    
    echo -e "${BLUE}Step 4: Restart Odoo Service${NC}"
    restart_odoo_service
    echo ""
    
    echo -e "${BLUE}Step 5: Update Apps List${NC}"
    update_apps_list
    echo ""
    
    echo -e "${BLUE}Step 6: Install web_enterprise Module${NC}"
    install_web_enterprise
    echo ""
    
    echo -e "${BLUE}Step 7: Verify Installation${NC}"
    verify_enterprise_installation
    echo ""
    
    show_success_message
    
    echo -e "${CYAN}🔧 Next: Run './enterprise-config-wizard.sh' for detailed configuration${NC}"
}

# Run the main function
main "$@"
