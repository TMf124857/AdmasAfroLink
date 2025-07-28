#!/bin/bash

# Fix Enterprise Module Installation and Static Assets
# This script will properly install web_enterprise and fix static asset issues

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}"
echo "🔧 AdmasAfroLink Enterprise Module Installation & Asset Fix"
echo "=========================================================="
echo -e "${NC}"

# Function to install web_enterprise module
install_web_enterprise() {
    echo -e "${CYAN}📦 Installing web_enterprise module...${NC}"
    
    read -p "Enter your database name: " db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}❌ Database name is required${NC}"
        return 1
    fi
    
    echo "Step 1: Updating apps list..."
    docker-compose exec odoo odoo -d "$db_name" -u base --stop-after-init --log-level=warn
    
    echo "Step 2: Installing web_enterprise..."
    docker-compose exec odoo odoo -d "$db_name" -i web_enterprise --stop-after-init --log-level=warn
    
    echo "Step 3: Updating web module to refresh assets..."
    docker-compose exec odoo odoo -d "$db_name" -u web --stop-after-init --log-level=warn
    
    echo -e "${GREEN}✅ web_enterprise module installed${NC}"
}

# Function to fix static assets
fix_static_assets() {
    echo -e "${CYAN}🎨 Fixing static assets...${NC}"
    
    read -p "Enter your database name: " db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}❌ Database name is required${NC}"
        return 1
    fi
    
    echo "Regenerating assets bundle..."
    
    # Force regenerate assets
    docker-compose exec odoo odoo -d "$db_name" -c "
import odoo
from odoo import api, SUPERUSER_ID
from odoo.addons.base.models.ir_attachment import IrAttachment

with api.Environment.manage():
    env = api.Environment(odoo.registry('$db_name'), SUPERUSER_ID, {})
    # Clear existing assets
    env['ir.attachment'].search([
        ('res_model', '=', 'ir.ui.view'),
        ('name', 'ilike', 'assets_%')
    ]).unlink()
    
    # Force regenerate
    env['ir.qweb']._get_asset_bundle('web.assets_backend', {}, True)
    env.cr.commit()
print('Assets regenerated')
" --stop-after-init
    
    echo -e "${GREEN}✅ Static assets regenerated${NC}"
}

# Function to restart and verify
restart_and_verify() {
    echo -e "${CYAN}🔄 Restarting Odoo...${NC}"
    
    docker-compose restart odoo
    
    echo "Waiting for Odoo to restart..."
    sleep 30
    
    echo "Testing access..."
    if curl -s -f http://localhost:8069 >/dev/null; then
        echo -e "${GREEN}✅ Odoo is accessible${NC}"
    else
        echo -e "${RED}❌ Odoo access failed${NC}"
    fi
}

# Function to show completion steps
show_completion_steps() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║           🎉 ENTERPRISE INSTALLATION COMPLETE! 🎉             ║"
    echo "║                                                               ║"
    echo "║  Now follow these final steps:                               ║"
    echo "║                                                               ║"
    echo "║  1. 🌐 Go to: http://64.225.79.153                          ║"
    echo "║  2. 🔑 Login to your database                                ║"
    echo "║  3. 🎨 The UI should now show Enterprise theme               ║"
    echo "║  4. ⚙️  Check Settings > Apps for more enterprise modules    ║"
    echo "║                                                               ║"
    echo "║  If you still see 404 errors:                               ║"
    echo "║  • Go to Settings > Technical > Actions > Clear Assets      ║"
    echo "║  • Or Settings > Regenerate Assets                          ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to show available enterprise modules
show_enterprise_modules() {
    echo -e "${YELLOW}📦 Available Enterprise Modules:${NC}"
    echo ""
    echo "Core Enterprise Modules:"
    echo "• web_enterprise - Enterprise UI/UX"
    echo "• account_enterprise - Advanced accounting"
    echo "• sale_timesheet_enterprise - Sales & timesheet integration"
    echo "• project_enterprise - Advanced project management"
    echo "• hr_work_entry_contract_enterprise - HR contracts"
    echo "• stock_enterprise - Advanced inventory"
    echo "• crm_enterprise - Enhanced CRM"
    echo "• website_enterprise - Enterprise website features"
    echo ""
    echo "To install any of these:"
    echo "1. Go to Apps menu"
    echo "2. Remove 'Apps' filter to see all modules"
    echo "3. Search for the module name"
    echo "4. Click Install"
}

# Main menu
main() {
    echo "🚀 Enterprise Module Installation & Asset Fixing..."
    echo ""
    
    echo "Choose an option:"
    echo "1. 📦 Install web_enterprise module"
    echo "2. 🎨 Fix static assets (if you see 404 errors)"
    echo "3. 🔄 Restart Odoo and verify"
    echo "4. 📋 Show available enterprise modules"
    echo "5. 🎯 Complete installation (all steps)"
    echo ""
    
    read -p "Select option (1-5): " choice
    
    case $choice in
        1)
            install_web_enterprise
            ;;
        2)
            fix_static_assets
            ;;
        3)
            restart_and_verify
            ;;
        4)
            show_enterprise_modules
            ;;
        5)
            install_web_enterprise
            echo ""
            fix_static_assets
            echo ""
            restart_and_verify
            echo ""
            show_completion_steps
            echo ""
            show_enterprise_modules
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            ;;
    esac
}

# Run main function
main "$@"
