#!/bin/bash

# Server Update Script - Resolve Git Conflicts and Update to Latest Version
# Run this on your Ubuntu server to update to the latest cleaned-up version

set -e

echo "🔄 Updating AdmasAfroLink server to latest version..."

# Function to print colored output
log_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# Check if we're in the right directory
if [[ ! -f "docker-compose.yml" ]]; then
    log_error "Please run this script from the AdmasAfroLink directory"
    exit 1
fi

log_info "Current directory: $(pwd)"

# Backup existing enterprise files if they exist
if [[ -d "enterprise" ]]; then
    log_warn "Backing up existing enterprise directory..."
    if [[ -d "enterprise_backup" ]]; then
        rm -rf enterprise_backup_old
        mv enterprise_backup enterprise_backup_old
    fi
    cp -r enterprise enterprise_backup
    log_info "Enterprise directory backed up to enterprise_backup"
fi

# Remove untracked files that are causing conflicts
log_info "Removing conflicting untracked files..."
if [[ -d "enterprise/sample_enterprise" ]]; then
    rm -rf enterprise/sample_enterprise
    log_info "Removed enterprise/sample_enterprise"
fi

# Stash any local changes
log_info "Stashing local changes..."
git stash push -m "Server update stash $(date)"

# Pull latest changes
log_info "Pulling latest changes from GitHub..."
git pull origin main

# Check if pull was successful
if [[ $? -eq 0 ]]; then
    log_info "✅ Successfully updated to latest version"
else
    log_error "❌ Git pull failed. Attempting to resolve..."
    
    # Force update if needed
    log_warn "Performing hard reset to match remote..."
    git fetch origin main
    git reset --hard origin/main
    
    if [[ $? -eq 0 ]]; then
        log_info "✅ Force update successful"
    else
        log_error "❌ Update failed. Manual intervention required."
        exit 1
    fi
fi

# Make scripts executable
log_info "Setting script permissions..."
chmod +x deploy deployment-agent.sh extract-enterprise-addons.sh 2>/dev/null || true

# Check what we have now
log_info "Updated project structure:"
ls -la

# Check if deployment agent is available
if [[ -f "deploy" ]]; then
    log_info "✅ Deployment agent available"
    echo "You can now use: ./deploy setup"
else
    log_warn "⚠️  Deployment agent not found. Using manual deployment."
fi

# Check if docker-compose.yml exists
if [[ -f "docker-compose.yml" ]]; then
    log_info "✅ Docker Compose configuration found"
else
    log_error "❌ Docker Compose configuration missing"
fi

# Show next steps
echo ""
echo "🎯 Next Steps:"
echo "=============="
echo "1. Configure environment:"
echo "   cp .env.example .env"
echo "   nano .env"
echo ""
echo "2. Set up enterprise addons:"
echo "   ./extract-enterprise-addons.sh"
echo ""
echo "3. Deploy using deployment agent:"
echo "   ./deploy setup"
echo "   ./deploy deploy"
echo ""
echo "4. Or deploy manually:"
echo "   docker-compose up -d"
echo ""
echo "5. Check status:"
echo "   docker-compose ps"
echo "   curl http://localhost:8069"
echo ""

log_info "Server update completed successfully! 🚀"
