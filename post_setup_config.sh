#!/bin/bash
# AdmasAfroLink Initial Configuration Script
# Run this after completing the initial setup wizard

echo "=== AdmasAfroLink Post-Setup Configuration ==="
echo "🚀 Configuring additional settings..."

# Wait for Odoo to be fully ready
echo "⏳ Waiting for Odoo to be ready..."
sleep 30

# Database connection details
DB_NAME="admasafrolink_uganda"
DB_USER="odoo"
DB_HOST="odoo_postgres"

echo "📊 Setting up basic configuration..."

# Execute SQL commands for additional setup
docker exec odoo_postgres psql -U $DB_USER -d $DB_NAME << 'EOF'

-- Update company information
UPDATE res_company SET 
    name = 'AdmasAfroLink Limited',
    email = 'info@admasafrolink.com',
    website = 'https://admasafrolink.com',
    street = 'Plot 123, Kampala Road',
    city = 'Kampala',
    state_id = (SELECT id FROM res_country_state WHERE name = 'Central Region' AND country_id = (SELECT id FROM res_country WHERE code = 'UG') LIMIT 1),
    zip = '00256',
    country_id = (SELECT id FROM res_country WHERE code = 'UG'),
    phone = '+256 XXX XXXXXX'
WHERE id = 1;

-- Set default currency to UGX
UPDATE res_company SET currency_id = (
    SELECT id FROM res_currency WHERE name = 'UGX' LIMIT 1
) WHERE id = 1;

-- Update timezone
UPDATE res_users SET tz = 'Africa/Kampala' WHERE id = 1;

-- Insert additional currencies if needed
INSERT INTO res_currency (name, symbol, rate, active, position, decimal_places) 
VALUES 
    ('UGX', 'USh', 1.0, true, 'before', 0),
    ('USD', '$', 0.00027, true, 'before', 2),
    ('EUR', '€', 0.00024, true, 'before', 2)
ON CONFLICT (name) DO NOTHING;

-- Create basic user groups data
INSERT INTO res_groups (name, category_id, comment) VALUES
    ('Academic Supervisors', (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1), 'University staff managing student internships'),
    ('HR Coordinators', (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1), 'AdmasAfroLink staff coordinating internships'),
    ('Host Organization Reps', (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1), 'Company representatives managing internship opportunities'),
    ('Students', (SELECT id FROM ir_module_category WHERE name = 'Website' LIMIT 1), 'Students applying for internships')
ON CONFLICT (name) DO NOTHING;

EOF

echo "✅ Basic configuration completed!"
echo "🎯 Next steps:"
echo "1. Complete the web-based setup wizard"
echo "2. Configure user groups and permissions"
echo "3. Set up recruitment pipeline"
echo ""
echo "📱 Access URLs:"
echo "• Main Platform: http://64.225.79.153:8069"
echo "• Database Admin: http://64.225.79.153:5050"
echo ""
echo "🔑 Login credentials:"
echo "• Admin: admin / admin123"
echo "• Database: admasafrolink_uganda"
