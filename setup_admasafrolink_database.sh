#!/bin/bash

# AdmasAfroLink Database Customization Script
# Customizes Odoo database for internship management platform
# Based on Business Logic Workflow & Module Customization Strategy

set -e  # Exit on any error

# Configuration Variables
DB_NAME="${DB_NAME:-admasafrolink}"
DB_USER="${DB_USER:-odoo}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
ODOO_CONFIG="${ODOO_CONFIG:-/etc/odoo/odoo.conf}"

echo "🚀 Starting AdmasAfroLink Database Customization..."
echo "Database: $DB_NAME"
echo "Host: $DB_HOST:$DB_PORT"
echo "User: $DB_USER"

# Function to execute SQL commands
execute_sql() {
    local sql_command="$1"
    echo "Executing: $sql_command"
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "$sql_command"
}

# Function to check if database exists
check_database() {
    echo "🔍 Checking if database exists..."
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        echo "✅ Database $DB_NAME found"
        return 0
    else
        echo "❌ Database $DB_NAME not found"
        return 1
    fi
}

# Phase 1: Core Module Foundation - Database Schema Extensions
setup_internship_tables() {
    echo "📊 Setting up AdmasAfroLink custom tables..."

    # Create internship_opportunity table
    execute_sql "
    CREATE TABLE IF NOT EXISTS internship_opportunity (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        company_id INTEGER REFERENCES res_company(id),
        department_id INTEGER REFERENCES hr_department(id),
        academic_level VARCHAR(50),
        duration_months INTEGER,
        start_date DATE,
        application_deadline DATE,
        required_skills TEXT,
        learning_objectives TEXT,
        supervisor_id INTEGER REFERENCES hr_employee(id),
        state VARCHAR(50) DEFAULT 'draft',
        create_date TIMESTAMP DEFAULT NOW(),
        write_date TIMESTAMP DEFAULT NOW(),
        create_uid INTEGER REFERENCES res_users(id),
        write_uid INTEGER REFERENCES res_users(id)
    );"

    # Create student_application table
    execute_sql "
    CREATE TABLE IF NOT EXISTS student_application (
        id SERIAL PRIMARY KEY,
        student_id INTEGER REFERENCES res_partner(id),
        opportunity_id INTEGER REFERENCES internship_opportunity(id),
        application_date TIMESTAMP DEFAULT NOW(),
        motivation_letter TEXT,
        cv_document_id INTEGER REFERENCES ir_attachment(id),
        transcript_document_id INTEGER REFERENCES ir_attachment(id),
        state VARCHAR(50) DEFAULT 'submitted',
        university_coordinator_id INTEGER REFERENCES res_partner(id),
        academic_institution VARCHAR(255),
        study_program VARCHAR(255),
        academic_level VARCHAR(50),
        expected_graduation_date DATE,
        academic_supervisor_contact VARCHAR(255),
        create_date TIMESTAMP DEFAULT NOW(),
        write_date TIMESTAMP DEFAULT NOW(),
        create_uid INTEGER REFERENCES res_users(id),
        write_uid INTEGER REFERENCES res_users(id)
    );"

    # Create student_profile table
    execute_sql "
    CREATE TABLE IF NOT EXISTS student_profile (
        id SERIAL PRIMARY KEY,
        partner_id INTEGER REFERENCES res_partner(id) UNIQUE,
        academic_history TEXT,
        skills_competencies TEXT,
        certifications TEXT,
        language_proficiency TEXT,
        emergency_contacts TEXT,
        portfolio_links TEXT,
        create_date TIMESTAMP DEFAULT NOW(),
        write_date TIMESTAMP DEFAULT NOW(),
        create_uid INTEGER REFERENCES res_users(id),
        write_uid INTEGER REFERENCES res_users(id)
    );"

    # Create host_organization_profile table
    execute_sql "
    CREATE TABLE IF NOT EXISTS host_organization_profile (
        id SERIAL PRIMARY KEY,
        company_id INTEGER REFERENCES res_company(id) UNIQUE,
        industry_sector VARCHAR(255),
        available_departments TEXT,
        supervision_capacity INTEGER,
        past_intern_feedback TEXT,
        compliance_status VARCHAR(50),
        create_date TIMESTAMP DEFAULT NOW(),
        write_date TIMESTAMP DEFAULT NOW(),
        create_uid INTEGER REFERENCES res_users(id),
        write_uid INTEGER REFERENCES res_users(id)
    );"

    # Create internship_agreement table
    execute_sql "
    CREATE TABLE IF NOT EXISTS internship_agreement (
        id SERIAL PRIMARY KEY,
        student_id INTEGER REFERENCES res_partner(id),
        company_id INTEGER REFERENCES res_company(id),
        opportunity_id INTEGER REFERENCES internship_opportunity(id),
        duration_schedule TEXT,
        learning_objectives TEXT,
        performance_metrics TEXT,
        compensation_details TEXT,
        insurance_coverage TEXT,
        termination_conditions TEXT,
        agreement_status VARCHAR(50) DEFAULT 'draft',
        signed_date DATE,
        create_date TIMESTAMP DEFAULT NOW(),
        write_date TIMESTAMP DEFAULT NOW(),
        create_uid INTEGER REFERENCES res_users(id),
        write_uid INTEGER REFERENCES res_users(id)
    );"

    echo "✅ Custom tables created successfully"
}

# Update HR Recruitment Module for AdmasAfroLink terminology
customize_recruitment_module() {
    echo "🔧 Customizing HR Recruitment module terminology..."

    # Update job position terminology to internship opportunity
    execute_sql "
    UPDATE ir_model_fields 
    SET field_description = 'Internship Opportunity' 
    WHERE model = 'hr.job' AND name = 'name';"

    execute_sql "
    UPDATE ir_ui_menu 
    SET name = 'Internship Opportunities' 
    WHERE name = 'Job Positions';"

    # Update applicant terminology to student applicant
    execute_sql "
    UPDATE ir_model_fields 
    SET field_description = 'Student Applicant' 
    WHERE model = 'hr.applicant' AND name = 'name';"

    execute_sql "
    UPDATE ir_ui_menu 
    SET name = 'Student Applications' 
    WHERE name = 'Applications';"

    echo "✅ Recruitment module terminology updated"
}

# Setup AdmasAfroLink pipeline stages
setup_pipeline_stages() {
    echo "📋 Setting up AdmasAfroLink pipeline stages..."

    # Clear existing default stages and create new ones
    execute_sql "
    DELETE FROM hr_recruitment_stage WHERE name IN (
        'Initial Qualification', 'First Interview', 'Second Interview', 
        'Contract Proposal', 'Contract Signed'
    );"

    # Insert AdmasAfroLink specific stages
    execute_sql "
    INSERT INTO hr_recruitment_stage (name, sequence, job_ids, requirements, template_id, fold) VALUES
    ('New Application', 1, NULL, 'Student submits application with required documents', NULL, false),
    ('Document Verification', 2, NULL, 'Verify academic transcripts and CV', NULL, false),
    ('University Pre-approval', 3, NULL, 'University coordinator reviews and approves', NULL, false),
    ('Company Review', 4, NULL, 'Company HR reviews student profile', NULL, false),
    ('Interview Scheduled', 5, NULL, 'Interview appointment scheduled', NULL, false),
    ('Interview Completed', 6, NULL, 'Interview conducted and evaluated', NULL, false),
    ('Final Selection', 7, NULL, 'Final selection decision made', NULL, false),
    ('Placement Confirmed', 8, NULL, 'Student placement confirmed', NULL, false),
    ('Contract Signed', 9, NULL, 'Internship agreement signed', NULL, false),
    ('Onboarding Started', 10, NULL, 'Student onboarding process initiated', NULL, true)
    ON CONFLICT (name) DO UPDATE SET
        sequence = EXCLUDED.sequence,
        requirements = EXCLUDED.requirements,
        fold = EXCLUDED.fold;"

    echo "✅ Pipeline stages configured"
}

# Add custom fields to HR applicant model
add_custom_fields() {
    echo "📝 Adding custom fields to HR models..."

    # Add academic fields to hr_applicant
    execute_sql "
    ALTER TABLE hr_applicant 
    ADD COLUMN IF NOT EXISTS academic_institution VARCHAR(255),
    ADD COLUMN IF NOT EXISTS study_program VARCHAR(255),
    ADD COLUMN IF NOT EXISTS academic_level VARCHAR(50),
    ADD COLUMN IF NOT EXISTS expected_graduation_date DATE,
    ADD COLUMN IF NOT EXISTS academic_supervisor_contact VARCHAR(255),
    ADD COLUMN IF NOT EXISTS university_coordinator_id INTEGER REFERENCES res_partner(id);"

    # Add internship specific fields to hr_employee
    execute_sql "
    ALTER TABLE hr_employee 
    ADD COLUMN IF NOT EXISTS is_intern BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS internship_start_date DATE,
    ADD COLUMN IF NOT EXISTS internship_end_date DATE,
    ADD COLUMN IF NOT EXISTS internship_agreement_id INTEGER REFERENCES internship_agreement(id);"

    echo "✅ Custom fields added"
}

# Setup security groups for AdmasAfroLink
setup_security_groups() {
    echo "🔐 Setting up security groups..."

    # Insert security groups if they don't exist
    execute_sql "
    INSERT INTO res_groups (name, category_id, comment) VALUES
    ('Student Portal Users', 
     (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1),
     'Students can view and manage their own applications'),
    ('Company Supervisors', 
     (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1),
     'Company supervisors can manage intern applications and evaluations'),
    ('University Coordinators', 
     (SELECT id FROM ir_module_category WHERE name = 'Human Resources' LIMIT 1),
     'University coordinators can approve and monitor student applications')
    ON CONFLICT (name) DO NOTHING;"

    echo "✅ Security groups configured"
}

# Create default data for AdmasAfroLink
create_default_data() {
    echo "📋 Creating default data..."

    # Create academic levels
    execute_sql "
    INSERT INTO internship_opportunity (name, academic_level, state) VALUES
    ('Sample Bachelor Internship', 'Bachelor', 'draft'),
    ('Sample Master Internship', 'Master', 'draft'),
    ('Sample PhD Research Position', 'PhD', 'draft')
    ON CONFLICT DO NOTHING;"

    # Create company categories for host organizations
    execute_sql "
    INSERT INTO res_partner_category (name, color) VALUES
    ('Host Organization', 1),
    ('University Partner', 2),
    ('Student', 3)
    ON CONFLICT (name) DO NOTHING;"

    echo "✅ Default data created"
}

# Setup email templates for AdmasAfroLink
setup_email_templates() {
    echo "📧 Setting up email templates..."

    # Application confirmation template
    execute_sql "
    INSERT INTO mail_template (name, model, subject, body_html, lang, auto_delete) VALUES
    ('Student Application Confirmation', 'hr.applicant', 
     'AdmasAfroLink: Application Received - \${object.partner_name}',
     '<p>Dear \${object.partner_name},</p>
      <p>Thank you for your application to the internship opportunity: <strong>\${object.job_id.name}</strong></p>
      <p>Your application has been received and is under review.</p>
      <p>Best regards,<br/>AdmasAfroLink Team</p>', 'en_US', true),
    ('Company Review Notification', 'hr.applicant',
     'AdmasAfroLink: New Student Application - \${object.partner_name}',
     '<p>Dear Hiring Manager,</p>
      <p>A new student application has been submitted for review.</p>
      <p><strong>Student:</strong> \${object.partner_name}<br/>
      <strong>Position:</strong> \${object.job_id.name}<br/>
      <strong>University:</strong> \${object.academic_institution}</p>
      <p>Please review the application in your AdmasAfroLink dashboard.</p>', 'en_US', true)
    ON CONFLICT (name) DO NOTHING;"

    echo "✅ Email templates configured"
}

# Main execution function
main() {
    echo "🎯 AdmasAfroLink Database Customization Started"
    echo "================================================"

    # Check prerequisites
    if ! check_database; then
        echo "❌ Database not found. Please create the database first."
        exit 1
    fi

    # Execute customization phases
    echo "Phase 1: Setting up custom tables..."
    setup_internship_tables

    echo "Phase 2: Customizing recruitment module..."
    customize_recruitment_module

    echo "Phase 3: Configuring pipeline stages..."
    setup_pipeline_stages

    echo "Phase 4: Adding custom fields..."
    add_custom_fields

    echo "Phase 5: Setting up security groups..."
    setup_security_groups

    echo "Phase 6: Creating default data..."
    create_default_data

    echo "Phase 7: Setting up email templates..."
    setup_email_templates

    echo ""
    echo "🎉 AdmasAfroLink Database Customization Completed Successfully!"
    echo "================================================"
    echo "✅ Custom internship tables created"
    echo "✅ Recruitment module terminology updated"
    echo "✅ Pipeline stages configured for internship workflow"
    echo "✅ Academic fields added to applicant records"
    echo "✅ Security groups for students, companies, and universities"
    echo "✅ Default data and email templates created"
    echo ""
    echo "🔄 Next Steps:"
    echo "1. Restart Odoo service to load new configurations"
    echo "2. Install/update the HR Recruitment module"
    echo "3. Configure user permissions and assign groups"
    echo "4. Test the internship application workflow"
    echo ""
    echo "📝 Note: Remember to backup your database before running this script"
}

# Check if script is being run directly
if [[ "\${BASH_SOURCE[0]}" == "\${0}" ]]; then
    main "$@"
fi
