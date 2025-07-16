#!/bin/bash

# Quick Odoo Database Initialization Script
# Use this script to initialize the Odoo database if it's not already initialized

set -e

echo "🚀 Initializing Odoo Database..."

# Check if Docker Compose is available
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ Error: docker-compose is not installed or not in PATH"
    exit 1
fi

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "⚠️  Starting required services first..."
    docker-compose up -d db redis
    sleep 15
fi

# Check if database is already initialized
echo "🔍 Checking if database is already initialized..."
if docker-compose exec -T db psql -U odoo -d odoo -c "\dt" 2>/dev/null | grep -q "ir_module_module"; then
    echo "✅ Database is already initialized!"
    echo "🌐 You can access Odoo at: http://localhost:8069"
    exit 0
fi

# Stop Odoo if it's running
echo "⏹️  Stopping Odoo service if running..."
docker-compose stop odoo 2>/dev/null || true

# Initialize the database
echo "🔧 Initializing database with base modules..."
echo "   This may take a few minutes..."

if docker-compose run --rm odoo odoo --config=/etc/odoo/odoo.conf -i base --stop-after-init; then
    echo "✅ Database initialized successfully!"
    
    # Start all services
    echo "🚀 Starting all services..."
    docker-compose up -d
    
    echo ""
    echo "🎉 Setup complete!"
    echo "🌐 Odoo is now available at: http://localhost:8069"
    echo "👤 Default admin credentials:"
    echo "   Email: admin"
    echo "   Password: admin123"
    echo ""
    echo "⚠️  Remember to change the default password in production!"
else
    echo "❌ Failed to initialize database"
    echo "💡 Try running: docker-compose logs odoo"
    exit 1
fi
