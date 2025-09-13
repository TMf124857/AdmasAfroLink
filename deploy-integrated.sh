#!/bin/bash

# AdmasAfroLink Integrated Deployment Script
# This script sets up and runs the complete AdmasAfroLink platform

set -e

echo "🚀 AdmasAfroLink Integrated Platform Deployment"
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Check if Docker Compose is available
check_docker_compose() {
    print_status "Checking Docker Compose..."
    
    if ! command -v docker-compose &> /dev/null; then
        if ! docker compose version &> /dev/null; then
            print_error "Docker Compose is not available. Please install Docker Compose."
            exit 1
        else
            DOCKER_COMPOSE_CMD="docker compose"
        fi
    else
        DOCKER_COMPOSE_CMD="docker-compose"
    fi
    
    print_success "Docker Compose is available"
}

# Create environment file if it doesn't exist
setup_environment() {
    print_status "Setting up environment configuration..."
    
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating from .env.example..."
        cp .env.example .env
        print_success "Created .env file. Please review and update the values."
    else
        print_success "Environment file already exists"
    fi
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    directories=(
        "nginx/ssl"
        "logs"
        "uploads"
        "backups"
    )
    
    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_success "Created directory: $dir"
        fi
    done
}

# Build and start services
start_services() {
    local profile=$1
    
    print_status "Starting AdmasAfroLink services with profile: $profile"
    
    case $profile in
        "dev")
            $DOCKER_COMPOSE_CMD -f docker-compose.integrated.yml --profile dev up -d --build
            ;;
        "prod")
            $DOCKER_COMPOSE_CMD -f docker-compose.integrated.yml --profile prod up -d --build
            ;;
        "full")
            $DOCKER_COMPOSE_CMD -f docker-compose.integrated.yml --profile dev --profile tools --profile monitoring up -d --build
            ;;
        *)
            print_error "Invalid profile. Use: dev, prod, or full"
            exit 1
            ;;
    esac
    
    print_success "Services started successfully"
}

# Show service status
show_status() {
    print_status "Checking service status..."
    $DOCKER_COMPOSE_CMD -f docker-compose.integrated.yml ps
}

# Show service logs
show_logs() {
    local service=$1
    
    if [ -z "$service" ]; then
        print_status "Showing logs for all services..."
        $DOCKER_COMPOSE_CMD -f docker-compose.integrated.yml logs -f
    else
        print_status "Showing logs for service: $service"
        $DOCKER_COMPOSE_CMD -f docker-compose.integrated.yml logs -f "$service"
    fi
}

# Stop services
stop_services() {
    print_status "Stopping AdmasAfroLink services..."
    $DOCKER_COMPOSE_CMD -f docker-compose.integrated.yml down
    print_success "Services stopped"
}

# Clean up (remove containers, volumes, etc.)
cleanup() {
    print_warning "This will remove all containers, volumes, and data. Are you sure? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_status "Cleaning up AdmasAfroLink platform..."
        $DOCKER_COMPOSE_CMD -f docker-compose.integrated.yml down -v --remove-orphans
        docker system prune -f
        print_success "Cleanup completed"
    else
        print_status "Cleanup cancelled"
    fi
}

# Health check
health_check() {
    print_status "Performing health check..."
    
    services=("postgres" "redis" "api" "frontend-dev")
    
    for service in "${services[@]}"; do
        print_status "Checking $service..."
        
        if $DOCKER_COMPOSE_CMD -f docker-compose.integrated.yml ps "$service" | grep -q "Up"; then
            print_success "$service is running"
        else
            print_error "$service is not running"
        fi
    done
    
    # Test API endpoint
    print_status "Testing API endpoint..."
    if curl -f http://localhost:7001/api/health > /dev/null 2>&1; then
        print_success "API is responding"
    else
        print_warning "API health check failed"
    fi
    
    # Test Frontend
    print_status "Testing Frontend..."
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        print_success "Frontend is responding"
    else
        print_warning "Frontend health check failed"
    fi
}

# Show help
show_help() {
    echo "AdmasAfroLink Integrated Platform Management"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start [profile]    Start the platform (profiles: dev, prod, full)"
    echo "  stop              Stop all services"
    echo "  restart [profile] Restart the platform"
    echo "  status            Show service status"
    echo "  logs [service]    Show logs (optionally for specific service)"
    echo "  health            Perform health check"
    echo "  cleanup           Remove all containers and volumes"
    echo "  help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start dev      Start development environment"
    echo "  $0 start prod     Start production environment"
    echo "  $0 start full     Start with all tools and monitoring"
    echo "  $0 logs api       Show API service logs"
    echo "  $0 health         Check if all services are healthy"
    echo ""
    echo "Service URLs (development):"
    echo "  Frontend:         http://localhost:3000"
    echo "  API:              http://localhost:7001"
    echo "  pgAdmin:          http://localhost:5050"
    echo "  Redis Commander:  http://localhost:8081"
    echo "  Portainer:        http://localhost:9000"
}

# Main execution
main() {
    case $1 in
        "start")
            check_docker
            check_docker_compose
            setup_environment
            create_directories
            start_services "${2:-dev}"
            show_status
            health_check
            echo ""
            print_success "AdmasAfroLink platform is running!"
            echo "Frontend: http://localhost:3000"
            echo "API: http://localhost:7001"
            echo "pgAdmin: http://localhost:5050"
            ;;
        "stop")
            check_docker_compose
            stop_services
            ;;
        "restart")
            check_docker_compose
            stop_services
            sleep 2
            start_services "${2:-dev}"
            show_status
            ;;
        "status")
            check_docker_compose
            show_status
            ;;
        "logs")
            check_docker_compose
            show_logs "$2"
            ;;
        "health")
            check_docker_compose
            health_check
            ;;
        "cleanup")
            check_docker_compose
            cleanup
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
