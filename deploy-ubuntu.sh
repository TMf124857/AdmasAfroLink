#!/bin/bash

# Odoo Enterprise Docker Deployment Script for Ubuntu Server 24 LTS
# This script sets up and deploys Odoo Enterprise on Ubuntu Server

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

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root. Use a regular user with sudo privileges."
        exit 1
    fi
    print_status "Running as non-root user: $(whoami)"
}

# Function to check Ubuntu version
check_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" && "$VERSION_ID" == "24.04" ]]; then
            print_status "Ubuntu 24.04 LTS detected"
        else
            print_warning "This script is optimized for Ubuntu 24.04 LTS. Current: $PRETTY_NAME"
        fi
    else
        print_warning "Cannot detect OS version"
    fi
}

# Function to update system packages
update_system() {
    print_header "UPDATING SYSTEM PACKAGES"
    sudo apt update
    sudo apt upgrade -y
    print_status "System packages updated"
}

# Function to install Docker
install_docker() {
    print_header "INSTALLING DOCKER"
    
    # Remove old versions
    sudo apt remove -y docker.io docker-doc docker-compose podman-docker containerd runc 2>/dev/null || true
    
    # Install prerequisites
    sudo apt install -y ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    # Enable and start Docker
    sudo systemctl enable docker
    sudo systemctl start docker
    
    print_status "Docker installed successfully"
    print_warning "Please log out and log back in for Docker group changes to take effect"
}

# Function to install Docker Compose (standalone)
install_docker_compose() {
    print_header "INSTALLING DOCKER COMPOSE"
    
    # Get latest version
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    
    # Download and install
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Create symlink
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    print_status "Docker Compose installed successfully"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        print_status "Try: sudo systemctl start docker"
        exit 1
    fi
    print_status "Docker is running"
}

# Function to check if docker-compose is available
check_docker_compose() {
    if ! command -v docker-compose >/dev/null 2>&1; then
        print_error "docker-compose is not installed."
        return 1
    fi
    print_status "docker-compose is available: $(docker-compose --version)"
}

# Function to setup firewall
setup_firewall() {
    print_header "CONFIGURING FIREWALL"
    
    # Install ufw if not installed
    sudo apt install -y ufw
    
    # Reset firewall rules
    sudo ufw --force reset
    
    # Default policies
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # Allow SSH
    sudo ufw allow ssh
    
    # Allow HTTP and HTTPS
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    
    # Allow Odoo (optional, can be disabled if using proxy)
    sudo ufw allow 8069/tcp
    
    # Enable firewall
    sudo ufw --force enable
    
    print_status "Firewall configured"
    sudo ufw status
}

# Function to optimize system for Docker
optimize_system() {
    print_header "OPTIMIZING SYSTEM FOR DOCKER"
    
    # Increase file limits
    echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
    echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
    echo "root soft nofile 65536" | sudo tee -a /etc/security/limits.conf
    echo "root hard nofile 65536" | sudo tee -a /etc/security/limits.conf
    
    # Configure sysctl for better performance
    sudo tee /etc/sysctl.d/99-docker-performance.conf > /dev/null <<EOF
# Network performance
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1

# Memory and swap
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# File system
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
EOF
    
    # Apply sysctl settings
    sudo sysctl -p /etc/sysctl.d/99-docker-performance.conf
    
    print_status "System optimized for Docker"
}

# Function to create .env file from example
setup_env() {
    print_header "SETTING UP ENVIRONMENT CONFIGURATION"
    
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            print_warning "Created .env file from .env.example. Please review and update the values."
        else
            print_error ".env.example file not found. Cannot create .env file."
            exit 1
        fi
    else
        print_status ".env file already exists"
    fi
    
    # Set appropriate permissions
    chmod 600 .env
    print_status "Environment file permissions set"
}

# Function to create necessary directories
setup_directories() {
    print_header "SETTING UP DIRECTORIES"
    
    # Create directories with proper permissions
    mkdir -p logs addons enterprise nginx/ssl
    
    # Set permissions
    chmod 755 logs addons enterprise nginx
    chmod 700 nginx/ssl
    
    print_status "Directories created with proper permissions"
}

# Function to deploy services
deploy_services() {
    print_header "DEPLOYING ODOO ENTERPRISE SERVICES"
    
    # Pull images
    print_status "Pulling Docker images..."
    docker-compose pull
    
    # Start services
    print_status "Starting services..."
    docker-compose up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 30
    
    # Check service health
    docker-compose ps
    
    print_status "Services deployed successfully!"
    print_status "Odoo will be available at: http://$(hostname -I | awk '{print $1}'):8069"
}

# Function to show post-deployment information
show_post_deployment_info() {
    print_header "POST-DEPLOYMENT INFORMATION"
    
    echo ""
    echo "🚀 Odoo Enterprise has been deployed successfully!"
    echo ""
    echo "📍 Access URLs:"
    echo "   - Odoo: http://$(hostname -I | awk '{print $1}'):8069"
    echo "   - pgAdmin: http://$(hostname -I | awk '{print $1}'):5050 (if using --profile tools)"
    echo ""
    echo "🔐 Default Credentials:"
    echo "   - Odoo Admin: admin / admin123"
    echo "   - pgAdmin: Check .env file for credentials"
    echo ""
    echo "📁 Important Directories:"
    echo "   - Logs: ./logs/"
    echo "   - Custom Addons: ./addons/"
    echo "   - Enterprise Addons: ./enterprise/"
    echo "   - Configuration: ./config/"
    echo ""
    echo "🔧 Management Commands:"
    echo "   - View logs: docker-compose logs -f"
    echo "   - Restart: docker-compose restart"
    echo "   - Stop: docker-compose down"
    echo "   - Update: docker-compose pull && docker-compose up -d"
    echo ""
    echo "⚠️  Security Reminders:"
    echo "   - Change default passwords in .env file"
    echo "   - Configure SSL certificates for production"
    echo "   - Review firewall settings"
    echo "   - Set up regular backups"
    echo ""
}

# Function to show help
show_help() {
    print_header "ODOO ENTERPRISE UBUNTU DEPLOYMENT SCRIPT"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  install-deps    - Install Docker and dependencies"
    echo "  setup          - Setup environment and directories"
    echo "  deploy         - Deploy Odoo Enterprise services"
    echo "  full-install   - Complete installation (deps + setup + deploy)"
    echo "  optimize       - Optimize system for Docker"
    echo "  firewall       - Configure firewall"
    echo "  status         - Show service status"
    echo "  logs           - Show service logs"
    echo "  help           - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 full-install    # Complete installation"
    echo "  $0 deploy          # Deploy services only"
    echo "  $0 status          # Check service status"
}

# Main script logic
main() {
    case "$1" in
        "install-deps")
            check_root
            check_ubuntu_version
            update_system
            install_docker
            install_docker_compose
            optimize_system
            print_status "Dependencies installed. Please log out and log back in."
            ;;
        "setup")
            setup_env
            setup_directories
            ;;
        "deploy")
            check_docker
            check_docker_compose
            deploy_services
            show_post_deployment_info
            ;;
        "full-install")
            check_root
            check_ubuntu_version
            update_system
            install_docker
            install_docker_compose
            optimize_system
            setup_firewall
            setup_env
            setup_directories
            print_warning "Please log out and log back in, then run: $0 deploy"
            ;;
        "optimize")
            check_root
            optimize_system
            ;;
        "firewall")
            setup_firewall
            ;;
        "status")
            docker-compose ps
            ;;
        "logs")
            docker-compose logs -f
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
}

# Run main function with all arguments
main "$@"
