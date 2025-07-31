#!/bin/bash
# AdmasAfroLink User Groups Configuration Script
# Run this after completing the initial setup wizard

echo "=== AdmasAfroLink User Groups Setup ==="
echo "🎯 Creating user groups for different stakeholders..."

# Database connection details
DB_NAME="admasafrolink_uganda"
DB_USER="odoo"

# Wait a moment for any setup to complete
sleep 10

echo "👥 Setting up user groups and permissions..."

# Execute SQL commands for user group setup
docker exec odoo_postgres psql -U $DB_USER -d $DB_NAME << 'EOF'

-- Insert user groups with proper access rights
INSERT INTO res_groups (name, comment, category_id) VALUES
    ('AdmasAfroLink Academic Supervisors', 'University staff managing student internships and academic requirements', 
     (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1)),
    ('AdmasAfroLink HR Coordinators', 'AdmasAfroLink staff coordinating internship programs and student placements', 
     (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1)),
    ('AdmasAfroLink Host Organization Representatives', 'Company representatives managing internship opportunities and student supervision', 
     (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1)),
    ('AdmasAfroLink Students', 'Students applying for and participating in internship programs', 
     (SELECT id FROM ir_module_category WHERE name = 'Website' LIMIT 1)),
    ('AdmasAfroLink System Administrators', 'Technical administrators managing the platform and system configurations', 
     (SELECT id FROM ir_module_category WHERE name = 'Administration' LIMIT 1))
ON CONFLICT (name) DO NOTHING;

-- Create partner categories for different organization types
INSERT INTO res_partner_category (name, color) VALUES
    ('University Partner', 1),
    ('Host Organization', 2),
    ('Government Agency', 3),
    ('NGO Partner', 4),
    ('Private Company', 5)
ON CONFLICT (name) DO NOTHING;

-- Create job categories for internships
INSERT INTO hr_job_category (name) VALUES
    ('Business & Finance Internships'),
    ('Technology & IT Internships'),
    ('Healthcare & Medical Internships'),
    ('Education & Research Internships'),
    ('NGO & Development Internships'),
    ('Government & Public Service Internships')
ON CONFLICT (name) DO NOTHING;

-- Create recruitment stages for internship process
INSERT INTO hr_recruitment_stage (name, sequence, fold, job_ids) VALUES
    ('Application Received', 1, false, NULL),
    ('University Review', 2, false, NULL),
    ('AdmasAfroLink Screening', 3, false, NULL),
    ('Host Organization Review', 4, false, NULL),
    ('Interview Scheduled', 5, false, NULL),
    ('Interview Completed', 6, false, NULL),
    ('Reference Check', 7, false, NULL),
    ('Offer Extended', 8, false, NULL),
    ('Offer Accepted', 9, false, NULL),
    ('Visa Processing', 10, false, NULL),
    ('Internship Started', 11, true, NULL),
    ('Internship Completed', 12, true, NULL),
    ('Application Rejected', 13, true, NULL)
ON CONFLICT (name) DO NOTHING;

EOF

echo "✅ User groups and categories created!"

# Now create the actual user accounts for AdmasAfroLink team
echo "👤 Creating initial user accounts for AdmasAfroLink team..."

docker exec odoo_postgres psql -U $DB_USER -d $DB_NAME << 'EOF'

-- Create AdmasAfroLink team members
INSERT INTO res_partner (name, email, is_company, supplier_rank, customer_rank, category_id) VALUES
    ('Fadhila Saad', 'fadhila.saad@admasafrolink.com', false, 0, 0, NULL),
    ('Abid Were', 'abid.were@admasafrolink.com', false, 0, 0, NULL),
    ('Tsegay Merhazion', 'tsegay.merhazion@admasafrolink.com', false, 0, 0, NULL),
    ('Dirk Van Merode', 'dirk.vanmerode@admasafrolink.com', false, 0, 0, NULL)
ON CONFLICT (email) DO NOTHING;

-- Create user accounts (these will need to be activated through the web interface)
INSERT INTO res_users (partner_id, login, active, share) 
SELECT 
    p.id,
    p.email,
    true,
    false
FROM res_partner p 
WHERE p.email IN (
    'fadhila.saad@admasafrolink.com',
    'abid.were@admasafrolink.com', 
    'tsegay.merhazion@admasafrolink.com',
    'dirk.vanmerode@admasafrolink.com'
)
ON CONFLICT (login) DO NOTHING;

EOF

echo "✅ Team user accounts created!"
echo ""
echo "🎯 Next steps to complete in the web interface:"
echo "1. ✅ Complete initial setup wizard"
echo "2. 🔄 Assign user groups to team members"
echo "3. 🔄 Set up recruitment pipeline stages"
echo "4. 🔄 Configure permissions for each user group"
echo ""
echo "👥 Created user groups:"
echo "• Academic Supervisors (University staff)"
echo "• HR Coordinators (AdmasAfroLink staff)"
echo "• Host Organization Representatives"
echo "• Students (Internship applicants)"
echo "• System Administrators"
echo ""
echo "👤 Created user accounts for team members:"
echo "• Fadhila Saad (Operations Director) - fadhila.saad@admasafrolink.com"
echo "• Abid Were (Program Coordinator) - abid.were@admasafrolink.com"
echo "• Tsegay Merhazion (Academic Liaison) - tsegay.merhazion@admasafrolink.com"
echo "• Dirk Van Merode (Strategic Advisor) - dirk.vanmerode@admasafrolink.com"
echo ""
echo "🔑 Next: Go to Settings > Users & Companies > Users to activate and assign groups"
echo "📱 Platform URL: http://64.225.79.153:8069"
