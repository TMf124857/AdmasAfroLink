#!/bin/bash

# Enterprise Addons Extraction Script for Linux/Mac
# Extracts Odoo Enterprise addons from the tarball following OOP principles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

print_header "ODOO ENTERPRISE ADDONS EXTRACTION SCRIPT"

# Check if tar.gz file exists
if [ ! -f "odoo_17.0+e.latest.tar.gz" ]; then
    print_error "odoo_17.0+e.latest.tar.gz not found in current directory"
    echo "💡 Please ensure the enterprise tarball is in the same directory as this script"
    exit 1
fi

# Check if enterprise directory exists
if [ ! -d "enterprise" ]; then
    print_status "Creating enterprise directory..."
    mkdir -p enterprise
else
    print_warning "Enterprise directory already exists"
    print_status "Backing up existing enterprise directory..."
    if [ -d "enterprise_backup" ]; then
        rm -rf enterprise_backup
    fi
    mv enterprise enterprise_backup
    mkdir -p enterprise
fi

print_status "Extracting enterprise addons from tarball..."

# Extract the tarball
tar -xzf odoo_17.0+e.latest.tar.gz

# Check if extraction was successful
if [ ! -d "odoo" ]; then
    print_error "Failed to extract tarball or unexpected directory structure"
    exit 1
fi

print_status "Processing enterprise modules following OOP structure..."

# Move enterprise addons to enterprise directory
if [ -d "odoo/addons" ]; then
    print_status "Moving enterprise addons..."
    cp -r odoo/addons/* enterprise/
    print_status "Enterprise addons extracted successfully"
else
    print_error "Expected addons directory not found in extracted files"
    exit 1
fi

# Clean up extracted odoo directory
print_status "Cleaning up temporary files..."
rm -rf odoo

# Set proper permissions
chmod -R 755 enterprise/

print_status "Verifying extracted enterprise modules..."
echo ""
echo "📋 Extracted Enterprise Modules:"
echo "================================"

# List key enterprise modules with their OOP patterns
for module_dir in enterprise/*/; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir")
        echo "- $module_name"
        
        # Check for key OOP pattern files
        if [ -d "$module_dir/models" ]; then
            echo "  └── Models: Found"
        fi
        if [ -d "$module_dir/views" ]; then
            echo "  └── Views: Found"
        fi
        if [ -f "$module_dir/__manifest__.py" ]; then
            echo "  └── Manifest: Found"
        fi
    fi
done

echo ""
print_header "ENTERPRISE ADDONS EXTRACTION COMPLETED"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Restart Odoo services: docker-compose restart odoo"
echo "2. Access Odoo at: http://localhost:8069"
echo "3. Go to Apps menu and install enterprise modules"
echo "4. Follow ENTERPRISE-CONVERSION-GUIDE.md for detailed instructions"
echo ""
echo "⚠️  Enterprise Features Available:"
echo "   - Advanced Accounting (account_accountant)"
echo "   - Project Management (project_enterprise)"
echo "   - Advanced HR (hr_holidays_enterprise)"
echo "   - Sales Enterprise (sale_enterprise)"
echo "   - Stock Enterprise (stock_enterprise)"
echo "   - Website Enterprise (website_enterprise)"
echo ""

# Check Docker Compose status
if command -v docker-compose >/dev/null 2>&1; then
    print_status "Checking Docker Compose status..."
    if docker-compose ps | grep -q "Up"; then
        print_status "Docker services are running. You can restart Odoo now:"
        echo "  docker-compose restart odoo"
    else
        print_warning "Docker services are not running. Start them with:"
        echo "  docker-compose up -d"
    fi
else
    print_warning "Docker Compose not found. Please ensure it's installed."
fi

print_status "Enterprise extraction process completed successfully!"
