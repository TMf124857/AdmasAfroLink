#!/bin/bash

# Odoo Enterprise Docker Setup Script
# This script helps set up and manage the Odoo Enterprise Docker environment

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
    echo -e "${BLUE}$1${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_status "Docker is running"
}

# Function to check if docker-compose is available
check_docker_compose() {
    if ! command -v docker-compose >/dev/null 2>&1; then
        print_error "docker-compose is not installed. Please install docker-compose and try again."
        exit 1
    fi
    print_status "docker-compose is available"
}

# Function to create .env file from example
setup_env() {
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
}

# Function to start services
start_services() {
    local profile=""
    
    case "$1" in
        "all")
            profile="--profile tools --profile proxy"
            ;;
        "tools")
            profile="--profile tools"
            ;;
        "proxy")
            profile="--profile proxy"
            ;;
        *)
            profile=""
            ;;
    esac
    
    print_status "Starting services with profile: ${1:-core}"
    docker-compose $profile up -d
    
    print_status "Services started successfully!"
    print_status "Odoo will be available at: http://localhost:8069"
    
    if [[ "$1" == "tools" || "$1" == "all" ]]; then
        print_status "pgAdmin will be available at: http://localhost:5050"
    fi
}

# Function to stop services
stop_services() {
    print_status "Stopping all services..."
    docker-compose down
    print_status "Services stopped successfully!"
}

# Function to show status
show_status() {
    print_header "=== Service Status ==="
    docker-compose ps
}

# Function to show logs
show_logs() {
    local service="$1"
    if [ -z "$service" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$service"
    fi
}

# Function to backup database
backup_database() {
    local backup_file="backup_$(date +%Y%m%d_%H%M%S).sql"
    print_status "Creating database backup: $backup_file"
    docker-compose exec -T db pg_dump -U odoo odoo > "$backup_file"
    print_status "Backup created successfully: $backup_file"
}

# Function to restore database
restore_database() {
    local backup_file="$1"
    if [ -z "$backup_file" ]; then
        print_error "Please specify backup file to restore"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    print_warning "This will overwrite the current database. Are you sure? (y/N)"
    read -r confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        print_status "Restoring database from: $backup_file"
        docker-compose exec -T db psql -U odoo odoo < "$backup_file"
        print_status "Database restored successfully"
    else
        print_status "Database restore cancelled"
    fi
}

# Function to update Odoo image
update_odoo() {
    print_status "Pulling latest Odoo image..."
    docker-compose pull odoo
    
    print_status "Recreating Odoo container..."
    docker-compose up -d --force-recreate odoo
    
    print_status "Odoo updated successfully!"
}

# Function to show help
show_help() {
    print_header "=== Odoo Enterprise Docker Management Script ==="
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  setup           - Initial setup (create .env file)"
    echo "  start [PROFILE] - Start services (core/tools/proxy/all)"
    echo "  stop            - Stop all services"
    echo "  restart         - Restart all services"
    echo "  status          - Show service status"
    echo "  logs [SERVICE]  - Show logs (all services or specific service)"
    echo "  backup          - Create database backup"
    echo "  restore FILE    - Restore database from backup file"
    echo "  update          - Update Odoo to latest version"
    echo "  clean           - Remove all containers and volumes (CAUTION)"
    echo "  help            - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup"
    echo "  $0 start"
    echo "  $0 start tools"
    echo "  $0 start all"
    echo "  $0 logs odoo"
    echo "  $0 backup"
    echo "  $0 restore backup_20231216_143022.sql"
}

# Main script logic
main() {
    case "$1" in
        "setup")
            check_docker
            check_docker_compose
            setup_env
            ;;
        "start")
            check_docker
            check_docker_compose
            setup_env
            start_services "$2"
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            stop_services
            sleep 2
            start_services "$2"
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs "$2"
            ;;
        "backup")
            backup_database
            ;;
        "restore")
            restore_database "$2"
            ;;
        "update")
            update_odoo
            ;;
        "clean")
            print_warning "This will remove all containers and volumes. All data will be lost!"
            print_warning "Are you sure? Type 'DELETE' to confirm:"
            read -r confirm
            if [ "$confirm" = "DELETE" ]; then
                docker-compose down -v
                docker system prune -f
                print_status "Cleanup completed"
            else
                print_status "Cleanup cancelled"
            fi
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
