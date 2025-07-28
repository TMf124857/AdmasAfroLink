#!/bin/bash

# AdmasAfroLink User Groups and Permissions Configuration Script
# This script configures user groups and permissions for the internship platform

echo "🔐 AdmasAfroLink User Groups Configuration"
echo "=========================================="

# Function to execute SQL commands in Docker container
execute_sql() {
    local sql_command="$1"
    docker exec -i odoo_postgres psql -U odoo -d admasafrolink_db -c "$sql_command"
}

echo "Phase 1: Creating User Groups..."

# Create Internship Administrator Group
echo "👑 Creating Internship Administrator group..."
execute_sql "
INSERT INTO res_groups (name, category_id, comment, share, create_date, write_date)
VALUES (
    'Internship Administrator',
    (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1),
    'Full access to internship management features',
    false,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Create Academic Supervisor Group
echo "🎓 Creating Academic Supervisor group..."
execute_sql "
INSERT INTO res_groups (name, category_id, comment, share, create_date, write_date)
VALUES (
    'Academic Supervisor',
    (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1),
    'Academic staff who supervise student internships',
    false,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Create HR Coordinator Group
echo "👥 Creating HR Coordinator group..."
execute_sql "
INSERT INTO res_groups (name, category_id, comment, share, create_date, write_date)
VALUES (
    'HR Coordinator',
    (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1),
    'HR staff managing internship coordination',
    false,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Create Student Group
echo "🎒 Creating Student group..."
execute_sql "
INSERT INTO res_groups (name, category_id, comment, share, create_date, write_date)
VALUES (
    'Student',
    (SELECT id FROM ir_module_category WHERE name = 'Extra Rights' LIMIT 1),
    'Students applying for internships',
    true,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Create Host Organization Representative Group
echo "🏢 Creating Host Organization Representative group..."
execute_sql "
INSERT INTO res_groups (name, category_id, comment, share, create_date, write_date)
VALUES (
    'Host Organization Representative',
    (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1),
    'External organization representatives managing internship opportunities',
    true,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

echo "✅ User groups created"

echo "Phase 2: Configuring Access Rights..."

# Configure model access rules for HR Recruitment
echo "📋 Setting up recruitment access rules..."

# Internship Administrator - Full Access
execute_sql "
INSERT INTO ir_model_access (name, model_id, group_id, perm_read, perm_write, perm_create, perm_unlink)
SELECT 
    'internship_admin_hr_applicant',
    (SELECT id FROM ir_model WHERE model = 'hr.applicant'),
    (SELECT id FROM res_groups WHERE name = 'Internship Administrator'),
    true, true, true, true
WHERE NOT EXISTS (
    SELECT 1 FROM ir_model_access 
    WHERE name = 'internship_admin_hr_applicant'
);
"

# Academic Supervisor - Read/Write Access to Applications
execute_sql "
INSERT INTO ir_model_access (name, model_id, group_id, perm_read, perm_write, perm_create, perm_unlink)
SELECT 
    'academic_supervisor_hr_applicant',
    (SELECT id FROM ir_model WHERE model = 'hr.applicant'),
    (SELECT id FROM res_groups WHERE name = 'Academic Supervisor'),
    true, true, false, false
WHERE NOT EXISTS (
    SELECT 1 FROM ir_model_access 
    WHERE name = 'academic_supervisor_hr_applicant'
);
"

# HR Coordinator - Read/Write Access
execute_sql "
INSERT INTO ir_model_access (name, model_id, group_id, perm_read, perm_write, perm_create, perm_unlink)
SELECT 
    'hr_coordinator_hr_applicant',
    (SELECT id FROM ir_model WHERE model = 'hr.applicant'),
    (SELECT id FROM res_groups WHERE name = 'HR Coordinator'),
    true, true, true, false
WHERE NOT EXISTS (
    SELECT 1 FROM ir_model_access 
    WHERE name = 'hr_coordinator_hr_applicant'
);
"

# Student - Read Own Applications Only
execute_sql "
INSERT INTO ir_model_access (name, model_id, group_id, perm_read, perm_write, perm_create, perm_unlink)
SELECT 
    'student_hr_applicant',
    (SELECT id FROM ir_model WHERE model = 'hr.applicant'),
    (SELECT id FROM res_groups WHERE name = 'Student'),
    true, true, true, false
WHERE NOT EXISTS (
    SELECT 1 FROM ir_model_access 
    WHERE name = 'student_hr_applicant'
);
"

# Host Organization - Read/Write Applications for their opportunities
execute_sql "
INSERT INTO ir_model_access (name, model_id, group_id, perm_read, perm_write, perm_create, perm_unlink)
SELECT 
    'host_org_hr_applicant',
    (SELECT id FROM ir_model WHERE model = 'hr.applicant'),
    (SELECT id FROM res_groups WHERE name = 'Host Organization Representative'),
    true, true, false, false
WHERE NOT EXISTS (
    SELECT 1 FROM ir_model_access 
    WHERE name = 'host_org_hr_applicant'
);
"

echo "✅ Access rights configured"

echo "Phase 3: Creating Record Rules for Data Security..."

# Record rule for students - can only see their own applications
execute_sql "
INSERT INTO ir_rule (name, model_id, groups, domain_force, perm_read, perm_write, perm_create, perm_unlink)
SELECT 
    'Student: Own Applications Only',
    (SELECT id FROM ir_model WHERE model = 'hr.applicant'),
    ARRAY[(SELECT id FROM res_groups WHERE name = 'Student')],
    '[(\\'create_uid\\',\\'=\\',user.id)]',
    true, true, true, true
WHERE NOT EXISTS (
    SELECT 1 FROM ir_rule 
    WHERE name = 'Student: Own Applications Only'
);
"

# Record rule for academic supervisors - can see applications from their department
execute_sql "
INSERT INTO ir_rule (name, model_id, groups, domain_force, perm_read, perm_write, perm_create, perm_unlink)
SELECT 
    'Academic Supervisor: Department Applications',
    (SELECT id FROM ir_model WHERE model = 'hr.applicant'),
    ARRAY[(SELECT id FROM res_groups WHERE name = 'Academic Supervisor')],
    '[(\\'department_id\\',\\'in\\',user.employee_id.department_id.child_all_ids.ids)]',
    true, true, false, false
WHERE NOT EXISTS (
    SELECT 1 FROM ir_rule 
    WHERE name = 'Academic Supervisor: Department Applications'
);
"

echo "✅ Record rules created"

echo "Phase 4: Setting up Default Users..."

# Create sample users for each role
echo "👤 Creating sample users..."

# Academic Supervisor User
execute_sql "
INSERT INTO res_users (login, name, email, active, create_date, write_date, password, notification_type)
VALUES (
    'academic.supervisor',
    'Dr. Academic Supervisor',
    'supervisor@admasafrolink.edu.et',
    true,
    NOW(),
    NOW(),
    'supervisor123',
    'email'
) ON CONFLICT (login) DO NOTHING;
"

# HR Coordinator User
execute_sql "
INSERT INTO res_users (login, name, email, active, create_date, write_date, password, notification_type)
VALUES (
    'hr.coordinator',
    'HR Coordinator',
    'hr@admasafrolink.edu.et',
    true,
    NOW(),
    NOW(),
    'coordinator123',
    'email'
) ON CONFLICT (login) DO NOTHING;
"

# Student User
execute_sql "
INSERT INTO res_users (login, name, email, active, create_date, write_date, password, notification_type)
VALUES (
    'student.demo',
    'Demo Student',
    'student@admasafrolink.edu.et',
    true,
    NOW(),
    NOW(),
    'student123',
    'email'
) ON CONFLICT (login) DO NOTHING;
"

echo "✅ Sample users created"

echo "Phase 5: Assigning Users to Groups..."

# Function to assign user to group
assign_user_to_group() {
    local user_login="$1"
    local group_name="$2"
    
    execute_sql "
    INSERT INTO res_groups_users_rel (gid, uid)
    SELECT 
        g.id,
        u.id
    FROM res_groups g, res_users u
    WHERE g.name = '$group_name' 
    AND u.login = '$user_login'
    AND NOT EXISTS (
        SELECT 1 FROM res_groups_users_rel 
        WHERE gid = g.id AND uid = u.id
    );
    "
}

# Assign users to their respective groups
assign_user_to_group "academic.supervisor" "Academic Supervisor"
assign_user_to_group "hr.coordinator" "HR Coordinator"
assign_user_to_group "student.demo" "Student"

echo "✅ Users assigned to groups"

echo "🎉 User Groups and Permissions Configuration Completed!"
echo "=========================================================="
echo "✅ User groups created (5 groups)"
echo "✅ Access rights configured"
echo "✅ Record rules set up for data security"
echo "✅ Sample users created"
echo "✅ Users assigned to appropriate groups"
echo ""
echo "📋 Created User Groups:"
echo "   - Internship Administrator (Full access)"
echo "   - Academic Supervisor (Department applications)"
echo "   - HR Coordinator (Coordination tasks)"
echo "   - Student (Own applications only)"
echo "   - Host Organization Representative (External access)"
echo ""
echo "👤 Sample User Credentials:"
echo "   - Academic Supervisor: academic.supervisor / supervisor123"
echo "   - HR Coordinator: hr.coordinator / coordinator123"
echo "   - Student: student.demo / student123"
echo ""
echo "🔗 Next: Configure recruitment pipeline stages"
