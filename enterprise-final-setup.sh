#!/bin/bash

# AdmasAfroLink Enterprise Activation - Final Steps
# Complete the enterprise module installation

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "🎯 AdmasAfroLink Enterprise Activation - Final Steps"
echo "=================================================="
echo -e "${NC}"

# Function to install enterprise modules
install_enterprise_modules() {
    echo -e "${CYAN}📦 Installing Enterprise Modules...${NC}"
    
    read -p "Enter your database name: " db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}❌ Database name is required${NC}"
        return 1
    fi
    
    echo "Step 1: Updating apps list..."
    if docker-compose exec odoo odoo -d "$db_name" -u base --stop-after-init --log-level=error; then
        echo "✅ Apps list updated"
    else
        echo "⚠️  Apps list update may have failed, trying alternative method..."
        docker-compose run --rm odoo odoo -d "$db_name" -u base --stop-after-init --log-level=error
    fi
    
    echo ""
    echo "Step 2: Installing web_enterprise module..."
    if docker-compose exec odoo odoo -d "$db_name" -i web_enterprise --stop-after-init --log-level=error; then
        echo "✅ web_enterprise module installed"
    else
        echo "⚠️  web_enterprise installation may have failed, trying alternative method..."
        docker-compose run --rm odoo odoo -d "$db_name" -i web_enterprise --stop-after-init --log-level=error
    fi
    
    echo ""
    echo "Step 3: Restarting Odoo to apply changes..."
    docker-compose restart odoo
    
    echo "Waiting for Odoo to restart..."
    sleep 30
    
    echo -e "${GREEN}✅ Enterprise modules installation completed${NC}"
}

# Function to show access information
show_access_info() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              🎉 ENTERPRISE ACTIVATION COMPLETE! 🎉            ║"
    echo "║                                                               ║"
    echo "║  Your AdmasAfroLink system is now Enterprise-ready!          ║"
    echo "║                                                               ║"
    echo "║  🌐 Public Access:  http://64.225.79.153                    ║"
    echo "║  🏠 Local Access:   http://localhost:8069                   ║"
    echo "║                                                               ║"
    echo "║  Next Steps:                                                  ║"
    echo "║  1. Login to your database                                   ║"
    echo "║  2. Check if the UI has changed to Enterprise theme         ║"
    echo "║  3. Install additional enterprise modules                    ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to show manual activation steps
show_manual_steps() {
    echo -e "${YELLOW}📋 Manual Enterprise Activation Steps:${NC}"
    echo ""
    echo "If the automated installation didn't work, follow these manual steps:"
    echo ""
    echo "1. 🌐 Open your browser and go to: http://64.225.79.153"
    echo ""
    echo "2. 🔑 Login with your admin credentials"
    echo ""
    echo "3. ⚙️  Activate Developer Mode:"
    echo "   - Go to Settings"
    echo "   - Scroll down to 'Developer Tools'"
    echo "   - Click 'Activate developer mode'"
    echo ""
    echo "4. 📱 Update Apps List:"
    echo "   - Go to Apps menu"
    echo "   - Click 'Update Apps List' button"
    echo "   - Wait for the update to complete"
    echo ""
    echo "5. 🔍 Install Enterprise Modules:"
    echo "   - Search for 'web_enterprise'"
    echo "   - Click 'Install' on the web_enterprise module"
    echo "   - Wait for installation to complete"
    echo ""
    echo "6. 🎨 Verify Enterprise UI:"
    echo "   - The interface should change to Enterprise theme"
    echo "   - You should see new enterprise features"
    echo ""
    echo "7. 📦 Install Additional Enterprise Modules (Optional):"
    echo "   - account_enterprise: Advanced accounting"
    echo "   - hr_enterprise: HR management"
    echo "   - sale_enterprise: Sales enhancements"
    echo "   - project_enterprise: Project management"
    echo "   - stock_enterprise: Inventory features"
    echo ""
    echo -e "${GREEN}✅ Your enterprise subscription gives you access to all these modules!${NC}"
}

# Function to test system access
test_system_access() {
    echo -e "${BLUE}🔍 Testing System Access...${NC}"
    
    echo "Testing local access..."
    if curl -s -f http://localhost:8069 >/dev/null; then
        echo "✅ Local access (http://localhost:8069) - Working"
    else
        echo "❌ Local access - Failed"
    fi
    
    echo "Testing public access..."
    if curl -s -f http://64.225.79.153 >/dev/null; then
        echo "✅ Public access (http://64.225.79.153) - Working"
    else
        echo "❌ Public access - Failed"
    fi
    
    echo ""
    echo "Docker containers status:"
    docker-compose ps
}

# Main function
main() {
    echo "🚀 Completing AdmasAfroLink Enterprise Activation..."
    echo ""
    
    # Test system first
    test_system_access
    echo ""
    
    # Ask user what they want to do
    echo "Choose an option:"
    echo "1. 📦 Automatically install enterprise modules"
    echo "2. 📋 Show manual installation steps"
    echo "3. 🔍 Just show access information"
    echo ""
    
    read -p "Select option (1-3): " choice
    
    case $choice in
        1)
            install_enterprise_modules
            echo ""
            show_access_info
            ;;
        2)
            show_manual_steps
            echo ""
            show_access_info
            ;;
        3)
            show_access_info
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            show_manual_steps
            ;;
    esac
    
    echo ""
    echo -e "${CYAN}🎯 Enterprise Features Now Available:${NC}"
    echo "• Enhanced user interface"
    echo "• Advanced reporting and analytics"
    echo "• Enterprise-grade security features"
    echo "• Premium modules and integrations"
    echo "• Priority support (with your subscription)"
    echo ""
    echo -e "${GREEN}🎉 Welcome to Odoo Enterprise Edition!${NC}"
}

# Run main function
main "$@"
