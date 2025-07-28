#!/bin/bash

# AdmasAfroLink Enterprise Upgrade Implementation Script
# Run this script to upgrade Community databases to Enterprise

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="/home/admas/backups/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$BACKUP_DIR/upgrade.log"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO:${NC} $1" | tee -a "$LOG_FILE"
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

log "🚀 AdmasAfroLink Enterprise Upgrade Starting..."
log "Backup directory: $BACKUP_DIR"
log "Log file: $LOG_FILE"

# Function to check prerequisites
check_prerequisites() {
    log "🔍 Checking prerequisites..."
    
    # Check if we're in the right directory
    if [[ ! -f "docker-compose.yml" ]]; then
        log_error "docker-compose.yml not found. Please run from AdmasAfroLink directory."
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker-compose ps >/dev/null 2>&1; then
        log_error "Docker Compose not accessible. Please check Docker installation."
        exit 1
    fi
    
    # Check if enterprise directory exists
    if [[ ! -d "enterprise" ]]; then
        log_warn "Enterprise directory not found. Creating..."
        mkdir -p enterprise
    fi
    
    log "✅ Prerequisites check passed"
}

# Function to backup existing data
backup_data() {
    log "💾 Creating backup..."
    
    # List available databases
    log_info "Available databases:"
    docker-compose exec -T odoo_postgres psql -U odoo -l | grep -v "template\|postgres" | head -10
    
    echo ""
    read -p "Enter database name to upgrade (or 'skip' for new database): " DB_NAME
    
    if [[ "$DB_NAME" != "skip" && "$DB_NAME" != "" ]]; then
        log "Backing up database: $DB_NAME"
        
        # Backup database
        docker-compose exec -T odoo_postgres pg_dump -U odoo -d "$DB_NAME" > "$BACKUP_DIR/database_backup.sql"
        
        # Backup filestore
        if [[ -d "volumes/odoo" ]]; then
            tar -czf "$BACKUP_DIR/filestore_backup.tar.gz" -C volumes/odoo .
            log "✅ Filestore backup completed"
        fi
        
        log "✅ Database backup completed: $BACKUP_DIR/database_backup.sql"
        export UPGRADE_DB="$DB_NAME"
    else
        log_info "Skipping backup - will create new enterprise database"
        export UPGRADE_DB=""
    fi
}

# Function to ensure enterprise addons are available
setup_enterprise_addons() {
    log "🏢 Setting up enterprise addons..."
    
    # Check if enterprise addons are extracted
    if [[ ! -d "enterprise" ]] || [[ -z "$(ls -A enterprise 2>/dev/null)" ]]; then
        log "Extracting enterprise addons..."
        if [[ -f "extract-enterprise-addons.sh" ]]; then
            ./extract-enterprise-addons.sh
        else
            log_warn "Enterprise extraction script not found. Creating sample structure..."
            mkdir -p enterprise/sample_enterprise
            cat > enterprise/sample_enterprise/__manifest__.py << 'EOF'
{
    'name': 'AdmasAfroLink Enterprise Sample',
    'version': '17.0.1.0.0',
    'category': 'Hidden',
    'summary': 'Sample Enterprise Module for AdmasAfroLink',
    'depends': ['base'],
    'installable': True,
    'auto_install': False,
    'license': 'LGPL-3',
}
EOF
            echo "# AdmasAfroLink Enterprise Sample" > enterprise/sample_enterprise/__init__.py
        fi
    fi
    
    log "✅ Enterprise addons ready"
}

# Function to upgrade existing database
upgrade_existing_database() {
    local db_name="$1"
    log "🔄 Upgrading existing database: $db_name"
    
    # Stop Odoo
    log "Stopping Odoo..."
    docker-compose stop odoo_enterprise
    
    # Update base module to recognize enterprise addons
    log "Updating base module..."
    docker-compose run --rm odoo_enterprise odoo -d "$db_name" -u base --stop-after-init
    
    # Install core enterprise modules step by step
    local enterprise_modules=(
        "account_accountant"
        "hr_holidays" 
        "project_enterprise"
        "sale_enterprise"
    )
    
    for module in "${enterprise_modules[@]}"; do
        log "Installing enterprise module: $module"
        if docker-compose run --rm odoo_enterprise odoo -d "$db_name" -i "$module" --stop-after-init; then
            log "✅ Successfully installed: $module"
        else
            log_warn "⚠️  Failed to install: $module (may not be available)"
        fi
    done
    
    # Start Odoo
    log "Starting Odoo..."
    docker-compose up -d odoo_enterprise
    
    log "✅ Database upgrade completed"
}

# Function to create new enterprise database
create_enterprise_database() {
    log "🆕 Creating new enterprise database..."
    
    echo ""
    read -p "Enter new database name: " NEW_DB_NAME
    read -p "Enter admin email: " ADMIN_EMAIL
    read -s -p "Enter admin password: " ADMIN_PASS
    echo ""
    
    # Stop Odoo
    docker-compose stop odoo_enterprise
    
    # Create database with enterprise modules
    log "Creating database: $NEW_DB_NAME"
    docker-compose run --rm odoo_enterprise odoo -d "$NEW_DB_NAME" \
        --db_user=odoo --db_password="$POSTGRES_PASSWORD" --db_host=db \
        -i base,account_accountant,hr_holidays,project_enterprise \
        --admin-passwd="$ADMIN_PASS" --stop-after-init
    
    # Start Odoo
    docker-compose up -d odoo_enterprise
    
    log "✅ New enterprise database created: $NEW_DB_NAME"
    log_info "Admin credentials - Email: $ADMIN_EMAIL, Password: [set]"
}

# Function to verify enterprise installation
verify_enterprise() {
    log "🔍 Verifying enterprise installation..."
    
    # Wait for Odoo to start
    sleep 30
    
    # Test database access
    if curl -s -f "http://localhost:8069/web/database/selector" > /dev/null; then
        log "✅ Odoo web interface accessible"
    else
        log_warn "⚠️  Odoo web interface not immediately accessible"
    fi
    
    # Test external access
    if curl -s -f "http://64.225.79.153" > /dev/null; then
        log "✅ External access working"
    else
        log_warn "⚠️  External access may need time to propagate"
    fi
    
    log "🌐 Access your enterprise system at: http://64.225.79.153"
}

# Function to show post-upgrade steps
show_post_upgrade_steps() {
    log "📋 Post-upgrade steps:"
    echo ""
    echo "1. 🌐 Access your system: http://64.225.79.153"
    echo "2. 🔑 Login with admin credentials"
    echo "3. 📱 Go to Apps menu to see enterprise modules"
    echo "4. ⚙️  Configure enterprise features:"
    echo "   - Accounting: Settings > Invoicing"
    echo "   - HR: Settings > Human Resources" 
    echo "   - Sales: Settings > Sales"
    echo "   - Project: Settings > Project"
    echo "5. 👥 Update user permissions for enterprise features"
    echo "6. 🔄 Install additional enterprise modules as needed"
    echo ""
    echo "📊 Monitor logs: docker-compose logs -f odoo_enterprise"
    echo "💾 Backup location: $BACKUP_DIR"
    echo ""
}

# Main execution
main() {
    log "🎯 Starting AdmasAfroLink Enterprise Upgrade Process"
    
    check_prerequisites
    setup_enterprise_addons
    backup_data
    
    if [[ -n "$UPGRADE_DB" ]]; then
        upgrade_existing_database "$UPGRADE_DB"
    else
        create_enterprise_database
    fi
    
    verify_enterprise
    show_post_upgrade_steps
    
    log "🎉 AdmasAfroLink Enterprise upgrade completed successfully!"
    log "📁 All logs and backups saved to: $BACKUP_DIR"
}

# Run main function
main "$@"
