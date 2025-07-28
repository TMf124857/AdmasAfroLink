#!/bin/bash

# AdmasAfroLink Docker Database Customization Script
# Customizes Odoo database for internship management platform
# Works with Docker Compose setup

set -e  # Exit on any error

# Configuration Variables from docker-compose.yml
DB_NAME="${POSTGRES_DB:-odoo}"
DB_USER="${POSTGRES_USER:-odoo}"
DB_PASSWORD="${POSTGRES_PASSWORD:-odoo123}"
DB_CONTAINER="odoo_postgres"
ODOO_CONTAINER="odoo_enterprise"

echo "🚀 Starting AdmasAfroLink Docker Database Customization..."
echo "Database: $DB_NAME"
echo "Database Container: $DB_CONTAINER"
echo "Odoo Container: $ODOO_CONTAINER"

# Function to execute SQL commands in Docker container
execute_sql() {
    local sql_command="$1"
    echo "Executing: $sql_command"
        docker exec -i odoo_postgres psql -U odoo -d admasafrolink_uganda -c "$sql_command"
}

# Function to check if Docker containers are running
check_containers() {
    echo "🔍 Checking Docker containers..."
    
    if ! docker ps | grep -q "$DB_CONTAINER"; then
        echo "❌ PostgreSQL container ($DB_CONTAINER) is not running"
        echo "Please start with: docker-compose up -d db"
        return 1
    fi
    
    if ! docker ps | grep -q "$ODOO_CONTAINER"; then
        echo "❌ Odoo container ($ODOO_CONTAINER) is not running"
        echo "Please start with: docker-compose up -d"
        return 1
    fi
    
    echo "✅ Docker containers are running"
    return 0
}

# Function to check if database exists
check_database() {
    echo "🔍 Checking if database exists..."
    if docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        echo "✅ Database $DB_NAME found"
        return 0
    else
        echo "❌ Database $DB_NAME not found"
        echo "Creating database..."
        docker exec -i "$DB_CONTAINER" createdb -U "$DB_USER" "$DB_NAME" || true
        return 0
    fi
}

# Wait for database to be ready
wait_for_database() {
    echo "⏳ Waiting for database to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker exec -i "$DB_CONTAINER" pg_isready -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1; then
            echo "✅ Database is ready"
            return 0
        fi
        
        echo "Attempt $attempt/$max_attempts - Database not ready yet..."
        sleep 2
        ((attempt++))
    done
    
    echo "❌ Database failed to become ready after $max_attempts attempts"
    return 1
}

# Phase 1: Core Module Foundation - Database Schema Extensions
setup_internship_tables() {
    echo "📊 Setting up AdmasAfroLink custom tables..."

    # Create internship_opportunity table
    execute_sql "
    CREATE TABLE IF NOT EXISTS internship_opportunity (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        company_id INTEGER,
        department_id INTEGER,
        academic_level VARCHAR(50),
        duration_months INTEGER,
        start_date DATE,
        application_deadline DATE,
        required_skills TEXT,
        learning_objectives TEXT,
        supervisor_id INTEGER,
        state VARCHAR(50) DEFAULT 'draft',
        create_date TIMESTAMP DEFAULT NOW(),
        write_date TIMESTAMP DEFAULT NOW(),
        create_uid INTEGER,
        write_uid INTEGER
    );"

    # Create student_application table
    execute_sql "
    CREATE TABLE IF NOT EXISTS student_application (
        id SERIAL PRIMARY KEY,
        student_id INTEGER,
        opportunity_id INTEGER REFERENCES internship_opportunity(id),
        application_date TIMESTAMP DEFAULT NOW(),
        motivation_letter TEXT,
        cv_document_id INTEGER,
        transcript_document_id INTEGER,
        state VARCHAR(50) DEFAULT 'submitted',
        university_coordinator_id INTEGER,
        academic_institution VARCHAR(255),
        study_program VARCHAR(255),
        academic_level VARCHAR(50),
        expected_graduation_date DATE,
        academic_supervisor_contact VARCHAR(255),
        create_date TIMESTAMP DEFAULT NOW(),
        write_date TIMESTAMP DEFAULT NOW(),
        create_uid INTEGER,
        write_uid INTEGER
    );"

    # Create student_profile table
    execute_sql "
    CREATE TABLE IF NOT EXISTS student_profile (
        id SERIAL PRIMARY KEY,
        partner_id INTEGER UNIQUE,
        academic_history TEXT,
        skills_competencies TEXT,
        certifications TEXT,
        language_proficiency TEXT,
        emergency_contacts TEXT,
        portfolio_links TEXT,
        create_date TIMESTAMP DEFAULT NOW(),
        write_date TIMESTAMP DEFAULT NOW(),
        create_uid INTEGER,
        write_uid INTEGER
    );"

    # Create host_organization_profile table
    execute_sql "
    CREATE TABLE IF NOT EXISTS host_organization_profile (
        id SERIAL PRIMARY KEY,
        company_id INTEGER UNIQUE,
        industry_sector VARCHAR(255),
        available_departments TEXT,
        supervision_capacity INTEGER,
        past_intern_feedback TEXT,
        compliance_status VARCHAR(50),
        create_date TIMESTAMP DEFAULT NOW(),
        write_date TIMESTAMP DEFAULT NOW(),
        create_uid INTEGER,
        write_uid INTEGER
    );"

    # Create internship_agreement table
    execute_sql "
    CREATE TABLE IF NOT EXISTS internship_agreement (
        id SERIAL PRIMARY KEY,
        student_id INTEGER,
        company_id INTEGER,
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
        create_uid INTEGER,
        write_uid INTEGER
    );"

    echo "✅ Custom tables created successfully"
}

# Setup AdmasAfroLink pipeline stages
setup_pipeline_stages() {
    echo "📋 Setting up AdmasAfroLink pipeline stages..."

    # Check if hr_recruitment_stage table exists
    local table_exists=$(execute_sql "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'hr_recruitment_stage');" | grep -o 't\|f')
    
    if [ "$table_exists" = "t" ]; then
        # Clear existing default stages and create new ones
        execute_sql "
        DELETE FROM hr_recruitment_stage WHERE name IN (
            'Initial Qualification', 'First Interview', 'Second Interview', 
            'Contract Proposal', 'Contract Signed'
        );"

        # Insert AdmasAfroLink specific stages
        execute_sql "
        INSERT INTO hr_recruitment_stage (name, sequence, requirements, fold) VALUES
        ('New Application', 1, 'Student submits application with required documents', false),
        ('Document Verification', 2, 'Verify academic transcripts and CV', false),
        ('University Pre-approval', 3, 'University coordinator reviews and approves', false),
        ('Company Review', 4, 'Company HR reviews student profile', false),
        ('Interview Scheduled', 5, 'Interview appointment scheduled', false),
        ('Interview Completed', 6, 'Interview conducted and evaluated', false),
        ('Final Selection', 7, 'Final selection decision made', false),
        ('Placement Confirmed', 8, 'Student placement confirmed', false),
        ('Contract Signed', 9, 'Internship agreement signed', false),
        ('Onboarding Started', 10, 'Student onboarding process initiated', true)
        ON CONFLICT (name) DO UPDATE SET
            sequence = EXCLUDED.sequence,
            requirements = EXCLUDED.requirements,
            fold = EXCLUDED.fold;"
    else
        echo "⚠️  hr_recruitment_stage table not found. Will be created when HR Recruitment module is installed."
    fi

    echo "✅ Pipeline stages configured"
}

# Add custom fields to HR applicant model (prepare for when Odoo is initialized)
prepare_custom_fields() {
    echo "📝 Preparing custom fields for HR models..."

    # Create a SQL script that will be executed after Odoo initialization
    cat > /tmp/custom_fields.sql << 'EOF'
-- Add academic fields to hr_applicant (will be executed after Odoo setup)
ALTER TABLE hr_applicant 
ADD COLUMN IF NOT EXISTS academic_institution VARCHAR(255),
ADD COLUMN IF NOT EXISTS study_program VARCHAR(255),
ADD COLUMN IF NOT EXISTS academic_level VARCHAR(50),
ADD COLUMN IF NOT EXISTS expected_graduation_date DATE,
ADD COLUMN IF NOT EXISTS academic_supervisor_contact VARCHAR(255),
ADD COLUMN IF NOT EXISTS university_coordinator_id INTEGER;

-- Add internship specific fields to hr_employee
ALTER TABLE hr_employee 
ADD COLUMN IF NOT EXISTS is_intern BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS internship_start_date DATE,
ADD COLUMN IF NOT EXISTS internship_end_date DATE,
ADD COLUMN IF NOT EXISTS internship_agreement_id INTEGER;
EOF

    echo "✅ Custom fields preparation completed"
}

# Create default data for AdmasAfroLink
create_default_data() {
    echo "📋 Creating default data..."

    # Create sample internship opportunities
    execute_sql "
    INSERT INTO internship_opportunity (name, academic_level, state) VALUES
    ('Software Development Internship - Bachelor Level', 'Bachelor', 'draft'),
    ('Data Analysis Internship - Master Level', 'Master', 'draft'),
    ('Research Assistant Position - PhD Level', 'PhD', 'draft'),
    ('Marketing Internship - Bachelor Level', 'Bachelor', 'draft'),
    ('Finance Internship - Master Level', 'Master', 'draft')
    ON CONFLICT DO NOTHING;"

    echo "✅ Default data created"
}

# Function to execute Odoo commands in Docker container
execute_odoo_command() {
    local command="$1"
    echo "Executing Odoo command: $command"
    docker exec -i "$ODOO_CONTAINER" $command
}

# Install required Odoo modules
install_odoo_modules() {
    echo "🔧 Installing required Odoo modules..."
    
    # Wait for Odoo to be fully started
    echo "⏳ Waiting for Odoo to be ready..."
    sleep 30
    
    # Install required modules
    execute_odoo_command "odoo -d $DB_NAME -i hr,hr_recruitment,website,portal,mail,contacts --stop-after-init --no-http"
    
    echo "✅ Odoo modules installed"
}

# Apply custom fields after Odoo is ready
apply_custom_fields() {
    echo "📝 Applying custom fields to HR models..."
    
    # Check if HR tables exist before adding fields
    local hr_applicant_exists=$(execute_sql "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'hr_applicant');" | grep -o 't\|f')
    local hr_employee_exists=$(execute_sql "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'hr_employee');" | grep -o 't\|f')
    
    if [ "$hr_applicant_exists" = "t" ]; then
        execute_sql "
        ALTER TABLE hr_applicant 
        ADD COLUMN IF NOT EXISTS academic_institution VARCHAR(255),
        ADD COLUMN IF NOT EXISTS study_program VARCHAR(255),
        ADD COLUMN IF NOT EXISTS academic_level VARCHAR(50),
        ADD COLUMN IF NOT EXISTS expected_graduation_date DATE,
        ADD COLUMN IF NOT EXISTS academic_supervisor_contact VARCHAR(255),
        ADD COLUMN IF NOT EXISTS university_coordinator_id INTEGER;"
    fi
    
    if [ "$hr_employee_exists" = "t" ]; then
        execute_sql "
        ALTER TABLE hr_employee 
        ADD COLUMN IF NOT EXISTS is_intern BOOLEAN DEFAULT false,
        ADD COLUMN IF NOT EXISTS internship_start_date DATE,
        ADD COLUMN IF NOT EXISTS internship_end_date DATE,
        ADD COLUMN IF NOT EXISTS internship_agreement_id INTEGER;"
    fi
    
    echo "✅ Custom fields applied"
}

# Restart Odoo container to apply changes
restart_odoo() {
    echo "🔄 Restarting Odoo container to apply changes..."
    docker-compose restart odoo
    
    echo "⏳ Waiting for Odoo to restart..."
    sleep 30
    
    echo "✅ Odoo restarted"
}

# Main execution function
main() {
    echo "🎯 AdmasAfroLink Docker Database Customization Started"
    echo "====================================================="

    # Check prerequisites
    if ! check_containers; then
        echo "❌ Docker containers not running. Please start them first with:"
        echo "   docker-compose up -d"
        exit 1
    fi

    # Wait for database to be ready
    if ! wait_for_database; then
        exit 1
    fi

    # Check/create database
    check_database

    # Execute customization phases
    echo ""
    echo "Phase 1: Setting up custom internship tables..."
    setup_internship_tables

    echo ""
    echo "Phase 2: Creating default data..."
    create_default_data

    echo ""
    echo "Phase 3: Preparing custom fields..."
    prepare_custom_fields

    echo ""
    echo "Phase 4: Installing Odoo modules..."
    install_odoo_modules

    echo ""
    echo "Phase 5: Applying custom fields..."
    apply_custom_fields

    echo ""
    echo "Phase 6: Configuring pipeline stages..."
    setup_pipeline_stages

    echo ""
    echo "Phase 7: Restarting Odoo..."
    restart_odoo

    echo ""
    echo "🎉 AdmasAfroLink Docker Database Customization Completed!"
    echo "========================================================="
    echo "✅ Custom internship tables created"
    echo "✅ Default internship opportunities added"
    echo "✅ Odoo modules installed (HR, Recruitment, Portal, Website)"
    echo "✅ Custom academic fields added to HR models"
    echo "✅ Pipeline stages configured for internship workflow"
    echo "✅ Odoo container restarted with new configuration"
    echo ""
    echo "🔗 Access your AdmasAfroLink platform:"
    echo "   - Odoo Interface: http://localhost:8069"
    echo "   - Database Admin: http://localhost:5050 (if pgAdmin is enabled)"
    echo ""
    echo "📝 Next Steps:"
    echo "1. Access Odoo at http://localhost:8069"
    echo "2. Complete the initial setup wizard"
    echo "3. Configure user permissions and assign groups"
    echo "4. Customize the recruitment pipeline stages"
    echo "5. Test the internship application workflow"
    echo ""
    echo "🎓 Your AdmasAfroLink internship platform is ready!"
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
