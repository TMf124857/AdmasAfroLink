#!/bin/bash

# Ubuntu Server 24 LTS Preparation Script for Odoo Enterprise
# This script prepares the system and files for Ubuntu deployment

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

print_header "UBUNTU SERVER 24 LTS PREPARATION FOR ODOO ENTERPRISE"

# Function to extract enterprise addons
extract_enterprise_addons() {
    print_header "EXTRACTING ENTERPRISE ADDONS"
    
    if [ ! -f "odoo_17.0+e.latest.tar.gz" ]; then
        print_error "Enterprise tarball not found: odoo_17.0+e.latest.tar.gz"
        print_warning "Please ensure the enterprise tarball is in the current directory"
        return 1
    fi
    
    # Create enterprise directory
    if [ ! -d "enterprise" ]; then
        print_status "Creating enterprise directory..."
        mkdir -p enterprise
    else
        print_warning "Enterprise directory exists. Backing up..."
        if [ -d "enterprise_backup" ]; then
            rm -rf enterprise_backup
        fi
        mv enterprise enterprise_backup
        mkdir -p enterprise
    fi
    
    # Extract enterprise addons
    print_status "Extracting enterprise addons from tarball..."
    tar -xzf odoo_17.0+e.latest.tar.gz
    
    if [ -d "odoo/addons" ]; then
        print_status "Moving enterprise addons to enterprise directory..."
        cp -r odoo/addons/* enterprise/
        rm -rf odoo
        print_status "Enterprise addons extracted successfully"
    else
        print_error "Enterprise addons directory not found in tarball"
        return 1
    fi
    
    # Set proper permissions
    chmod -R 755 enterprise/
    print_status "Permissions set for enterprise directory"
}

# Function to prepare Ubuntu deployment files
prepare_ubuntu_files() {
    print_header "PREPARING UBUNTU DEPLOYMENT FILES"
    
    # Create necessary directories
    print_status "Creating necessary directories..."
    mkdir -p logs nginx/ssl
    chmod 755 logs nginx
    chmod 700 nginx/ssl
    
    # Set proper ownership (for Docker containers)
    print_status "Setting proper ownership..."
    if command -v docker >/dev/null 2>&1; then
        # Set ownership to container user (1000:1000)
        sudo chown -R 1000:1000 enterprise/ addons/ logs/ 2>/dev/null || chown -R 1000:1000 enterprise/ addons/ logs/ 2>/dev/null || true
    fi
    
    print_status "Ubuntu deployment files prepared"
}

# Function to validate environment configuration
validate_environment() {
    print_header "VALIDATING ENVIRONMENT CONFIGURATION"
    
    # Check .env file
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            print_status "Creating .env file from example..."
            cp .env.example .env
            chmod 600 .env
            print_warning "Please review and update .env file with your settings"
        else
            print_error ".env.example file not found"
            return 1
        fi
    else
        print_status ".env file exists"
    fi
    
    # Check Docker Compose configuration
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found"
        return 1
    fi
    
    # Validate enterprise path in odoo.conf
    if [ -f "config/odoo.conf" ]; then
        if grep -q "/mnt/enterprise-addons" config/odoo.conf; then
            print_status "Enterprise addons path configured in odoo.conf"
        else
            print_warning "Enterprise addons path may not be configured in odoo.conf"
        fi
    fi
    
    print_status "Environment validation completed"
}

# Function to create Ubuntu deployment package
create_deployment_package() {
    print_header "CREATING UBUNTU DEPLOYMENT PACKAGE"
    
    # Create deployment archive excluding unnecessary files
    print_status "Creating deployment archive..."
    
    # Create exclusion list
    cat > .deployment_exclude << EOF
.git/
.gitignore
*.log
.DS_Store
Thumbs.db
*.tmp
*.bak
*~
enterprise_backup/
odoo_17.0+e.latest.tar.gz
EOF
    
    # Create tar archive for Ubuntu deployment
    tar -czf ../AdmasAfroLink-ubuntu-deployment.tar.gz \
        --exclude-from=.deployment_exclude \
        .
    
    # Clean up
    rm .deployment_exclude
    
    print_status "Deployment package created: ../AdmasAfroLink-ubuntu-deployment.tar.gz"
    print_status "This package is ready for Ubuntu Server 24 LTS deployment"
}

# Function to generate Ubuntu deployment commands
generate_ubuntu_commands() {
    print_header "UBUNTU SERVER 24 LTS DEPLOYMENT COMMANDS"
    
    cat > ubuntu-deployment-commands.sh << 'EOF'
#!/bin/bash

# Ubuntu Server 24 LTS Deployment Commands
# Run these commands on your Ubuntu server

set -e

print_status() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_header() {
    echo -e "\033[0;34m================================================================\033[0m"
    echo -e "\033[0;34m$1\033[0m"
    echo -e "\033[0;34m================================================================\033[0m"
}

print_header "UBUNTU SERVER 24 LTS DEPLOYMENT"

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
print_status "Installing Docker..."
sudo apt remove docker.io docker-doc docker-compose podman-docker containerd runc 2>/dev/null || true
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Install Docker Compose (standalone)
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Configure firewall
print_status "Configuring firewall..."
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8069/tcp
sudo ufw --force enable

# System optimization
print_status "Optimizing system for Docker..."
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "root soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "root hard nofile 65536" | sudo tee -a /etc/security/limits.conf

sudo tee /etc/sysctl.d/99-docker-performance.conf > /dev/null <<SYSCTL
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
SYSCTL

sudo sysctl -p /etc/sysctl.d/99-docker-performance.conf

print_status "Ubuntu Server preparation completed!"
print_status "Please log out and log back in to apply docker group changes"
print_status "Then extract and deploy your Odoo Enterprise application"

EOF

    chmod +x ubuntu-deployment-commands.sh
    print_status "Ubuntu deployment commands generated: ubuntu-deployment-commands.sh"
}

# Function to show deployment instructions
show_deployment_instructions() {
    print_header "UBUNTU SERVER 24 LTS DEPLOYMENT INSTRUCTIONS"
    
    cat << EOF

🚀 Deployment Steps for Ubuntu Server 24 LTS:

1️⃣  TRANSFER FILES TO UBUNTU SERVER:
   scp AdmasAfroLink-ubuntu-deployment.tar.gz user@your-server:/home/user/

2️⃣  ON UBUNTU SERVER - EXTRACT AND PREPARE:
   tar -xzf AdmasAfroLink-ubuntu-deployment.tar.gz
   cd AdmasAfroLink/
   chmod +x ubuntu-deployment-commands.sh
   ./ubuntu-deployment-commands.sh

3️⃣  LOG OUT AND LOG BACK IN (for Docker group):
   exit
   ssh user@your-server

4️⃣  DEPLOY ODOO ENTERPRISE:
   cd AdmasAfroLink/
   
   # Review and update configuration
   nano .env
   
   # Deploy services
   docker-compose up -d
   
   # Initialize database (first time only)
   chmod +x init-odoo.sh
   ./init-odoo.sh

5️⃣  ACCESS YOUR ODOO ENTERPRISE:
   http://your-server-ip:8069
   Default credentials: admin / admin123

📋 ENTERPRISE FEATURES AVAILABLE:
   ✅ Advanced Accounting (account_accountant)
   ✅ Project Management (project_enterprise)
   ✅ Advanced HR (hr_holidays_enterprise)
   ✅ Sales Enterprise (sale_enterprise)
   ✅ Stock Enterprise (stock_enterprise)
   ✅ Website Enterprise (website_enterprise)

🔧 MANAGEMENT COMMANDS:
   # View logs
   docker-compose logs -f
   
   # Restart services
   docker-compose restart
   
   # Stop services
   docker-compose down
   
   # Update Odoo
   docker-compose pull odoo && docker-compose up -d

🔒 SECURITY REMINDERS:
   - Change default passwords in .env file
   - Configure SSL certificates for production
   - Set up regular backups
   - Review firewall settings

EOF
}

# Main execution
main() {
    case "${1:-all}" in
        "extract")
            extract_enterprise_addons
            ;;
        "prepare")
            prepare_ubuntu_files
            ;;
        "validate")
            validate_environment
            ;;
        "package")
            create_deployment_package
            ;;
        "commands")
            generate_ubuntu_commands
            ;;
        "instructions")
            show_deployment_instructions
            ;;
        "all")
            extract_enterprise_addons
            prepare_ubuntu_files
            validate_environment
            create_deployment_package
            generate_ubuntu_commands
            show_deployment_instructions
            ;;
        *)
            echo "Usage: $0 {extract|prepare|validate|package|commands|instructions|all}"
            echo ""
            echo "Commands:"
            echo "  extract      - Extract enterprise addons from tarball"
            echo "  prepare      - Prepare Ubuntu deployment files"
            echo "  validate     - Validate environment configuration"
            echo "  package      - Create deployment package"
            echo "  commands     - Generate Ubuntu deployment commands"
            echo "  instructions - Show deployment instructions"
            echo "  all          - Run all steps (default)"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
