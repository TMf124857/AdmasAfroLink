#!/bin/bash

# Odoo Community to Enterprise Upgrade Script for Docker
# This script helps upgrade your Odoo Community installation to Enterprise

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

# Function to backup database
backup_database() {
    print_header "BACKING UP COMMUNITY DATABASE"
    
    local backup_file="community_backup_$(date +%Y%m%d_%H%M%S).sql"
    
    if docker-compose ps | grep -q "odoo.*Up"; then
        print_status "Creating database backup: $backup_file"
        docker-compose exec -T db pg_dump -U odoo odoo > "$backup_file"
        
        if [ $? -eq 0 ]; then
            print_status "Backup created successfully: $backup_file"
            echo "$backup_file" > .last_backup
        else
            print_error "Failed to create backup"
            exit 1
        fi
    else
        print_error "Odoo services are not running. Please start them first."
        exit 1
    fi
}

# Function to download enterprise addons
download_enterprise_addons() {
    print_header "SETTING UP ENTERPRISE ADDONS"
    
    if [ ! -d "enterprise" ]; then
        mkdir -p enterprise
    fi
    
    print_status "Enterprise addons directory prepared: ./enterprise/"
    print_warning "You need to manually place Odoo Enterprise addons in the ./enterprise/ directory"
    print_warning "Options:"
    echo "  1. If you have Odoo Enterprise subscription:"
    echo "     git clone https://github.com/odoo/enterprise.git enterprise-source"
    echo "     cp -r enterprise-source/* enterprise/"
    echo ""
    echo "  2. Download from Odoo.com (requires subscription)"
    echo "     - Download enterprise addons from your Odoo account"
    echo "     - Extract to ./enterprise/ directory"
    echo ""
    echo "  3. Contact Odoo for enterprise addons access"
    echo ""
    
    read -p "Have you placed the enterprise addons in ./enterprise/? (y/N): " confirm
    if [[ ! $confirm == [yY] && ! $confirm == [yY][eE][sS] ]]; then
        print_warning "Please add enterprise addons to ./enterprise/ directory first"
        return 1
    fi
    
    # Check if enterprise addons exist
    if [ -z "$(ls -A enterprise/)" ]; then
        print_error "Enterprise directory is empty. Please add enterprise addons first."
        return 1
    fi
    
    print_status "Enterprise addons found in ./enterprise/"
    return 0
}

# Function to install web_enterprise module
install_web_enterprise() {
    print_header "INSTALLING WEB_ENTERPRISE MODULE"
    
    print_status "Stopping Odoo service..."
    docker-compose stop odoo
    
    print_status "Installing web_enterprise module..."
    print_status "This may take several minutes depending on database size..."
    
    if docker-compose run --rm odoo odoo --config=/etc/odoo/odoo.conf -d odoo -i web_enterprise --stop-after-init; then
        print_status "web_enterprise module installed successfully!"
    else
        print_error "Failed to install web_enterprise module"
        return 1
    fi
}

# Function to start enterprise services
start_enterprise_services() {
    print_header "STARTING ODOO ENTERPRISE"
    
    print_status "Starting all services..."
    docker-compose up -d
    
    print_status "Waiting for services to be ready..."
    sleep 30
    
    # Check if services are running
    docker-compose ps
    
    print_status "Odoo Enterprise services started successfully!"
}

# Function to show post-upgrade information
show_post_upgrade_info() {
    print_header "ENTERPRISE UPGRADE COMPLETE"
    
    echo ""
    echo "🎉 Congratulations! Your Odoo has been upgraded to Enterprise!"
    echo ""
    echo "📍 Access your Odoo Enterprise:"
    echo "   - URL: http://localhost:8069"
    echo "   - Login: admin"
    echo "   - Password: admin123"
    echo ""
    echo "🔑 Next Steps:"
    echo "   1. Login to your Odoo Enterprise instance"
    echo "   2. Go to Settings > General Settings"
    echo "   3. Look for 'Odoo Enterprise' section"
    echo "   4. Enter your Enterprise subscription code"
    echo "   5. Activate your Enterprise features"
    echo ""
    echo "📦 Available Enterprise Apps:"
    echo "   - Go to Apps menu to see enterprise modules"
    echo "   - Install additional enterprise applications as needed"
    echo ""
    echo "💾 Backup Information:"
    if [ -f .last_backup ]; then
        echo "   - Community backup: $(cat .last_backup)"
    fi
    echo "   - Regular backups recommended"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "   - Check logs: docker-compose logs -f odoo"
    echo "   - Restart services: docker-compose restart"
    echo ""
}

# Function to validate prerequisites
validate_prerequisites() {
    print_header "VALIDATING PREREQUISITES"
    
    # Check if docker-compose is available
    if ! command -v docker-compose >/dev/null 2>&1; then
        print_error "docker-compose is not installed"
        exit 1
    fi
    print_status "Docker Compose: Available"
    
    # Check if services are running
    if ! docker-compose ps | grep -q "Up"; then
        print_error "Docker services are not running. Please start them first."
        exit 1
    fi
    print_status "Docker Services: Running"
    
    # Check if database is accessible
    if ! docker-compose exec -T db psql -U odoo -d odoo -c "SELECT 1;" >/dev/null 2>&1; then
        print_error "Cannot connect to database"
        exit 1
    fi
    print_status "Database: Accessible"
    
    print_status "All prerequisites met!"
}

# Function to show help
show_help() {
    print_header "ODOO COMMUNITY TO ENTERPRISE UPGRADE"
    echo ""
    echo "This script helps you upgrade from Odoo Community to Enterprise in Docker."
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  full-upgrade    - Complete upgrade process (recommended)"
    echo "  backup          - Backup current database only"
    echo "  install-module  - Install web_enterprise module only"
    echo "  setup-addons    - Setup enterprise addons directory"
    echo "  help            - Show this help message"
    echo ""
    echo "Prerequisites:"
    echo "  1. Odoo Community running in Docker"
    echo "  2. Enterprise addons available"
    echo "  3. Valid Odoo Enterprise subscription"
    echo ""
    echo "Example:"
    echo "  $0 full-upgrade"
    echo ""
}

# Main upgrade process
full_upgrade() {
    print_header "ODOO COMMUNITY TO ENTERPRISE UPGRADE"
    
    validate_prerequisites
    
    print_warning "This will upgrade your Odoo Community to Enterprise."
    print_warning "Make sure you have:"
    echo "  1. A valid Odoo Enterprise subscription"
    echo "  2. Enterprise addons ready"
    echo "  3. Tested this process in a development environment"
    echo ""
    
    read -p "Do you want to continue? (y/N): " confirm
    if [[ ! $confirm == [yY] && ! $confirm == [yY][eE][sS] ]]; then
        print_status "Upgrade cancelled"
        exit 0
    fi
    
    # Step 1: Backup
    backup_database
    
    # Step 2: Setup enterprise addons
    if ! download_enterprise_addons; then
        print_error "Cannot proceed without enterprise addons"
        exit 1
    fi
    
    # Step 3: Install web_enterprise
    install_web_enterprise
    
    # Step 4: Start services
    start_enterprise_services
    
    # Step 5: Show completion info
    show_post_upgrade_info
}

# Main script logic
case "$1" in
    "full-upgrade")
        full_upgrade
        ;;
    "backup")
        validate_prerequisites
        backup_database
        ;;
    "install-module")
        validate_prerequisites
        install_web_enterprise
        start_enterprise_services
        ;;
    "setup-addons")
        download_enterprise_addons
        ;;
    "help"|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
