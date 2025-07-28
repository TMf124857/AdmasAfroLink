#!/bin/bash

# AdmasAfroLink Status Check and Quick Setup
echo "🔍 AdmasAfroLink Platform Status Check"
echo "======================================"

# Check if containers are running
echo "📊 Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=odoo"

echo ""
echo "🌐 Access URLs:"
echo "   Main Odoo Interface: http://localhost:8069"
echo "   Database Admin: http://localhost:5432 (PostgreSQL)"
echo "   Redis Cache: http://localhost:6379"

echo ""
echo "📋 Current Database:"
docker exec -i odoo_postgres psql -U odoo -c "\l" | grep -E "(Name|odoo|db)"

echo ""
echo "🔗 Quick Setup Links (after accessing Odoo):"
echo "   📝 Apps: http://localhost:8069/web#action=base.open_module_tree"
echo "   👥 Users: http://localhost:8069/web#action=base.action_res_users"
echo "   🏢 Groups: http://localhost:8069/web#action=base.action_res_groups"
echo "   💼 Jobs: http://localhost:8069/web#action=hr_recruitment.action_hr_job"
echo "   ⚙️  Settings: http://localhost:8069/web#action=base.action_res_config_settings"

echo ""
echo "📖 Setup Instructions:"
echo "   1. Open http://localhost:8069 in your browser"
echo "   2. Complete the initial setup wizard"
echo "   3. Follow the web_setup_guide.md for detailed steps"
echo "   4. Install required modules (HR, Recruitment, Website)"
echo "   5. Create user groups and sample users"
echo "   6. Configure recruitment pipeline stages"

echo ""
echo "🎯 Next Action: Open http://localhost:8069 and start the setup wizard!"
