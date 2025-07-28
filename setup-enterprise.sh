#!/bin/bash

# Odoo Enterprise Alternative Setup Script
# This script downloads community alternatives to Odoo Enterprise modules

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================================${NC}"
}

# Function to clone OCA modules
clone_oca_modules() {
    local addon_dir="$1"
    local branch="17.0"
    
    print_header "DOWNLOADING OCA COMMUNITY MODULES"
    
    # Create addons directory if it doesn't exist
    mkdir -p "$addon_dir"
    
    # List of popular OCA repositories
    local repos=(
        "server-tools"
        "web"
        "reporting-engine"
        "server-ux"
        "server-auth"
        "server-brand"
        "knowledge"
        "social"
        "project"
        "hr"
        "account-financial-tools"
        "account-financial-reporting"
        "purchase-workflow"
        "sale-workflow"
        "stock-logistics-warehouse"
        "manufacture"
        "contract"
        "helpdesk"
        "crm"
        "website"
        "management-system"
        "connector"
        "queue"
        "rest-framework"
        "server-env"
        "mis-builder"
        "operating-unit"
        "multi-company"
        "partner-contact"
        "product-attribute"
        "product-variant"
        "commission"
        "agreement"
        "dms"
        "business-requirement"
        "department"
        "field-service"
        "timesheet"
        "vertical-association"
        "vertical-hotel"
        "vertical-medical"
        "vertical-education"
        "vertical-ngo"
        "vertical-realestate"
        "vertical-travel"
        "l10n-spain"
        "l10n-germany"
        "l10n-france"
        "l10n-italy"
        "l10n-usa"
        "l10n-canada"
        "l10n-brazil"
        "l10n-mexico"
        "l10n-argentina"
        "l10n-chile"
        "l10n-colombia"
        "l10n-peru"
        "l10n-ecuador"
        "l10n-uruguay"
        "l10n-venezuela"
        "l10n-netherlands"
        "l10n-belgium"
        "l10n-switzerland"
        "l10n-austria"
        "l10n-portugal"
        "l10n-greece"
        "l10n-turkey"
        "l10n-romania"
        "l10n-poland"
        "l10n-czech"
        "l10n-slovakia"
        "l10n-hungary"
        "l10n-slovenia"
        "l10n-croatia"
        "l10n-serbia"
        "l10n-bulgaria"
        "l10n-estonia"
        "l10n-latvia"
        "l10n-lithuania"
        "l10n-finland"
        "l10n-sweden"
        "l10n-norway"
        "l10n-denmark"
        "l10n-ireland"
        "l10n-uk"
        "l10n-russia"
        "l10n-ukraine"
        "l10n-belarus"
        "l10n-kazakhstan"
        "l10n-morocco"
        "l10n-egypt"
        "l10n-south-africa"
        "l10n-ethiopia"
        "l10n-kenya"
        "l10n-india"
        "l10n-china"
        "l10n-japan"
        "l10n-thailand"
        "l10n-vietnam"
        "l10n-philippines"
        "l10n-indonesia"
        "l10n-malaysia"
        "l10n-singapore"
        "l10n-australia"
        "l10n-new-zealand"
    )
    
    # Core essential modules (download first)
    local core_repos=(
        "server-tools"
        "web"
        "reporting-engine"
        "server-ux"
        "account-financial-tools"
        "sale-workflow"
        "purchase-workflow"
        "stock-logistics-warehouse"
        "hr"
        "project"
        "crm"
        "website"
        "partner-contact"
        "product-attribute"
        "queue"
        "server-env"
    )
    
    print_status "Downloading core OCA modules..."
    
    for repo in "${core_repos[@]}"; do
        if [ -d "$addon_dir/$repo" ]; then
            print_warning "Directory $addon_dir/$repo already exists, skipping..."
        else
            print_status "Cloning $repo..."
            if git clone -b "$branch" "https://github.com/OCA/$repo.git" "$addon_dir/$repo"; then
                print_status "Successfully cloned $repo"
            else
                print_error "Failed to clone $repo, it may not exist for branch $branch"
            fi
        fi
    done
    
    print_status "Core modules downloaded. You can download additional modules by running:"
    echo "git clone -b $branch https://github.com/OCA/[MODULE_NAME].git ./addons/[MODULE_NAME]"
}

# Function to download specific enterprise-like modules
download_enterprise_alternatives() {
    local addon_dir="$1"
    
    print_header "DOWNLOADING ENTERPRISE ALTERNATIVES"
    
    # Create specific directories for organized modules
    mkdir -p "$addon_dir/accounting"
    mkdir -p "$addon_dir/business"
    mkdir -p "$addon_dir/technical"
    
    # Accounting modules
    print_status "Downloading accounting modules..."
    git clone -b 17.0 https://github.com/OCA/account-financial-tools.git "$addon_dir/accounting/account-financial-tools" || true
    git clone -b 17.0 https://github.com/OCA/account-financial-reporting.git "$addon_dir/accounting/account-financial-reporting" || true
    git clone -b 17.0 https://github.com/OCA/account-invoice-reporting.git "$addon_dir/accounting/account-invoice-reporting" || true
    
    # Business modules
    print_status "Downloading business modules..."
    git clone -b 17.0 https://github.com/OCA/crm.git "$addon_dir/business/crm" || true
    git clone -b 17.0 https://github.com/OCA/hr.git "$addon_dir/business/hr" || true
    git clone -b 17.0 https://github.com/OCA/project.git "$addon_dir/business/project" || true
    git clone -b 17.0 https://github.com/OCA/manufacture.git "$addon_dir/business/manufacture" || true
    git clone -b 17.0 https://github.com/OCA/helpdesk.git "$addon_dir/business/helpdesk" || true
    
    # Technical modules
    print_status "Downloading technical modules..."
    git clone -b 17.0 https://github.com/OCA/server-tools.git "$addon_dir/technical/server-tools" || true
    git clone -b 17.0 https://github.com/OCA/web.git "$addon_dir/technical/web" || true
    git clone -b 17.0 https://github.com/OCA/reporting-engine.git "$addon_dir/technical/reporting-engine" || true
    
    print_status "Enterprise alternative modules downloaded successfully!"
}

# Function to extract enterprise addons from tar.gz
extract_enterprise_from_archive() {
    local archive_file="odoo_17.0+e.latest.tar.gz"
    local enterprise_dir="./enterprise"
    
    print_header "EXTRACTING ENTERPRISE ADDONS FROM ARCHIVE"
    
    if [ ! -f "$archive_file" ]; then
        print_error "Archive file $archive_file not found!"
        print_status "Please ensure you have the Odoo Enterprise archive in the current directory"
        return 1
    fi
    
    # Create enterprise directory
    mkdir -p "$enterprise_dir"
    
    # Create temporary directory for extraction
    local temp_dir=$(mktemp -d)
    
    print_status "Extracting $archive_file to temporary directory..."
    tar -xzf "$archive_file" -C "$temp_dir"
    
    # Find the enterprise addons directory in the extracted files
    local extracted_enterprise_dir=""
    
    # Look for common enterprise addon directory patterns
    for pattern in "odoo/addons" "*/addons" "addons" "enterprise" "*/enterprise"; do
        if [ -d "$temp_dir/$pattern" ]; then
            extracted_enterprise_dir="$temp_dir/$pattern"
            break
        fi
    done
    
    # If not found, look for directories with enterprise modules
    if [ -z "$extracted_enterprise_dir" ]; then
        for dir in "$temp_dir"/*; do
            if [ -d "$dir" ] && [ -f "$dir/account_accountant/__manifest__.py" ]; then
                extracted_enterprise_dir="$dir"
                break
            fi
        done
    fi
    
    if [ -z "$extracted_enterprise_dir" ]; then
        print_error "Could not find enterprise addons directory in the archive"
        rm -rf "$temp_dir"
        return 1
    fi
    
    print_status "Found enterprise addons in: $extracted_enterprise_dir"
    
    # Copy enterprise modules to the enterprise directory
    local module_count=0
    for module_dir in "$extracted_enterprise_dir"/*; do
        if [ -d "$module_dir" ] && [ -f "$module_dir/__manifest__.py" ]; then
            local module_name=$(basename "$module_dir")
            print_status "Copying module: $module_name"
            cp -r "$module_dir" "$enterprise_dir/"
            ((module_count++))
        fi
    done
    
    # Cleanup temporary directory
    rm -rf "$temp_dir"
    
    print_status "Successfully extracted $module_count enterprise modules to $enterprise_dir"
    print_status "Enterprise modules are now ready for use!"
    
    # Set proper permissions
    chmod -R 755 "$enterprise_dir"
    
    return 0
}

# Function to create a sample enterprise module
create_sample_enterprise_module() {
    local enterprise_dir="$1"
    
    print_header "CREATING SAMPLE ENTERPRISE MODULE"
    
    mkdir -p "$enterprise_dir/sample_enterprise"
    
    # Create __manifest__.py
    cat > "$enterprise_dir/sample_enterprise/__manifest__.py" << EOF
{
    'name': 'Sample Enterprise Module',
    'version': '17.0.1.0.0',
    'category': 'Enterprise',
    'summary': 'Sample Enterprise Module for Testing',
    'description': '''
        This is a sample enterprise module to test your Odoo Enterprise setup.
        It demonstrates that enterprise addons are properly loaded.
    ''',
    'author': 'Your Company',
    'website': 'https://yourcompany.com',
    'license': 'LGPL-3',
    'depends': ['base'],
    'data': [
        'views/sample_views.xml',
    ],
    'installable': True,
    'auto_install': False,
    'application': False,
    'enterprise': True,
}
EOF

    # Create __init__.py
    cat > "$enterprise_dir/sample_enterprise/__init__.py" << EOF
# Sample Enterprise Module
EOF

    # Create views
    mkdir -p "$enterprise_dir/sample_enterprise/views"
    cat > "$enterprise_dir/sample_enterprise/views/sample_views.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <record id="view_sample_enterprise_menu" model="ir.ui.menu">
        <field name="name">Sample Enterprise</field>
        <field name="sequence">100</field>
        <field name="web_icon">sample_enterprise,static/description/icon.png</field>
    </record>
</odoo>
EOF

    # Create static directory with icon
    mkdir -p "$enterprise_dir/sample_enterprise/static/description"
    
    print_status "Sample enterprise module created in $enterprise_dir/sample_enterprise"
}

# Main function
main() {
    case "$1" in
        "oca")
            clone_oca_modules "./addons"
            ;;
        "enterprise-alt")
            download_enterprise_alternatives "./addons"
            ;;
        "extract")
            extract_enterprise_from_archive
            ;;
        "sample")
            create_sample_enterprise_module "./enterprise"
            ;;
        "all")
            clone_oca_modules "./addons"
            create_sample_enterprise_module "./enterprise"
            ;;
        "full")
            extract_enterprise_from_archive
            clone_oca_modules "./addons"
            ;;
        *)
            print_header "ODOO ENTERPRISE SETUP HELPER"
            echo ""
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  extract          - Extract enterprise addons from odoo_17.0+e.latest.tar.gz"
            echo "  oca              - Download OCA community modules"
            echo "  enterprise-alt   - Download organized enterprise alternatives"
            echo "  sample           - Create sample enterprise module for testing"
            echo "  all              - Download OCA modules and create sample"
            echo "  full             - Extract enterprise + download OCA modules"
            echo ""
            echo "Examples:"
            echo "  $0 extract           # Extract from odoo_17.0+e.latest.tar.gz"
            echo "  $0 oca               # Download community modules"
            echo "  $0 enterprise-alt    # Download enterprise alternatives" 
            echo "  $0 sample            # Create test module"
            echo "  $0 all               # OCA modules + sample"
            echo "  $0 full              # Extract enterprise + OCA modules"
            echo ""
            echo "Prerequisites:"
            echo "  - For 'extract': odoo_17.0+e.latest.tar.gz file in current directory"
            echo "  - For 'oca': Git installed and internet connection"
            echo "  - For 'enterprise-alt': Git installed and internet connection"
            ;;
    esac
}

# Run main function
main "$@"
