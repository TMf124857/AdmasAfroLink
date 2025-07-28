# AdmasAfroLink Web Setup Guide

## Step 1: Initial Odoo Setup

### 1.1 Access Odoo
- Open browser and go to: http://localhost:8069
- You should see the Odoo setup screen

### 1.2 Database Configuration
If you see a database setup form:
- **Master Password**: Leave empty (first time)
- **Database Name**: admasafrolink
- **Email**: admin@admasafrolink.edu.et
- **Password**: Choose a strong admin password
- **Phone**: +251-XXX-XXXXXX
- **Language**: English
- **Country**: Ethiopia
- **Demo Data**: ❌ Uncheck this box

### 1.3 Company Information
- **Company Name**: AdmasAfroLink Internship Platform
- **Website**: https://admasafrolink.edu.et
- **Industry**: Education
- **Currency**: Ethiopian Birr (ETB)

## Step 2: Install Required Modules

### 2.1 Access Apps Menu
1. Go to **Apps** from the main menu
2. Remove the "Apps" filter to see all modules
3. Search and install these modules:

**Essential Modules:**
- ✅ **HR** (Human Resources)
- ✅ **Recruitment** (HR Recruitment)
- ✅ **Website** (Website Builder)
- ✅ **Portal** (Customer Portal)
- ✅ **Documents** (Document Management)
- ✅ **Sign** (Electronic Signature)
- ✅ **Discuss** (Internal Communication)

**Additional Modules:**
- **Project** (for internship tracking)
- **Calendar** (for scheduling)
- **Contacts** (for organizations)

## Step 3: Configure User Groups (Manual Setup)

### 3.1 Access Settings
1. Go to **Settings** → **Users & Companies** → **Groups**
2. Click **Create** to add new groups

### 3.2 Create User Groups

**Group 1: Internship Administrator**
- Name: `Internship Administrator`
- Category: `Human Resources`
- Access Rights: HR Manager, Recruitment Manager

**Group 2: Academic Supervisor**  
- Name: `Academic Supervisor`
- Category: `Human Resources`
- Access Rights: HR Officer, Recruitment User

**Group 3: HR Coordinator**
- Name: `HR Coordinator` 
- Category: `Human Resources`
- Access Rights: HR Officer, Recruitment User

**Group 4: Student**
- Name: `Student`
- Category: `Portal`
- Access Rights: Portal User

**Group 5: Host Organization Representative**
- Name: `Host Organization Representative`
- Category: `Portal` 
- Access Rights: Portal User

## Step 4: Create Sample Users

### 4.1 Access Users Menu
1. Go to **Settings** → **Users & Companies** → **Users**
2. Click **Create** for each user

### 4.2 User Creation

**Academic Supervisor User:**
- Name: `Dr. Academic Supervisor`
- Email: `supervisor@admasafrolink.edu.et`
- Login: `academic.supervisor`
- Groups: `Academic Supervisor`, `Employee`

**HR Coordinator User:**
- Name: `HR Coordinator`
- Email: `hr@admasafrolink.edu.et`  
- Login: `hr.coordinator`
- Groups: `HR Coordinator`, `Employee`

**Student User:**
- Name: `Demo Student`
- Email: `student@admasafrolink.edu.et`
- Login: `student.demo`
- Groups: `Student`, `Portal`

## Step 5: Configure Recruitment Pipeline

### 5.1 Access Recruitment Settings
1. Go to **Recruitment** → **Configuration** → **Stages**
2. Remove existing stages or modify them

### 5.2 Create Internship Stages
Create these stages in order:

1. **New Application** (Sequence: 1)
   - Requirements: Initial application submitted

2. **Academic Review** (Sequence: 2)  
   - Requirements: Academic supervisor evaluation

3. **Host Organization Review** (Sequence: 3)
   - Requirements: Company evaluation

4. **Interview Scheduled** (Sequence: 4)
   - Requirements: Meeting arranged

5. **Final Assessment** (Sequence: 5)
   - Requirements: Decision making

6. **Placement Confirmed** (Sequence: 6)
   - Requirements: Internship approved

7. **Documentation** (Sequence: 7)
   - Requirements: Agreements and forms

8. **Active Internship** (Sequence: 8)
   - Requirements: Currently ongoing

9. **Completed** (Sequence: 9, Folded: ✅)
   - Requirements: Internship finished

10. **Cancelled/Rejected** (Sequence: 10, Folded: ✅)
    - Requirements: Not proceeding

## Step 6: Create Internship Job Positions

### 6.1 Access Jobs
1. Go to **Recruitment** → **Job Positions**
2. Click **Create**

### 6.2 Sample Job Position
- **Job Title**: Software Development Internship
- **Department**: IT Department  
- **Employment Type**: Internship
- **Location**: Addis Ababa
- **Description**: 3-month software development internship
- **Requirements**: Computer Science student, 3rd year+
- **Published on Website**: ✅ Yes

## Step 7: Test the Workflow

### 7.1 Student Application Test
1. Switch to Student user
2. Go to Website → Jobs
3. Apply for an internship
4. Upload required documents

### 7.2 Review Process Test  
1. Switch to Academic Supervisor
2. Review application in Recruitment
3. Move through pipeline stages
4. Add notes and feedback

## Step 8: Configure Email Templates

### 8.1 Access Email Templates
1. Go to **Settings** → **Technical** → **Email Templates**
2. Create templates for each stage

### 8.2 Sample Email Template
- **Name**: Application Status Update
- **Model**: Applicant
- **Subject**: Your internship application status
- **Body**: Include stage information and next steps

## Quick Access URLs

- **Main Dashboard**: http://localhost:8069/web
- **Recruitment**: http://localhost:8069/web#action=hr_recruitment.action_hr_applicant
- **HR Management**: http://localhost:8069/web#action=hr.open_view_employee_list_my  
- **Settings**: http://localhost:8069/web#action=base.action_res_config_settings
- **Users**: http://localhost:8069/web#action=base.action_res_users
- **Groups**: http://localhost:8069/web#action=base.action_res_groups
- **Job Positions**: http://localhost:8069/web#action=hr_recruitment.action_hr_job

## Login Credentials

**Administrator:**
- Email: admin@admasafrolink.edu.et
- Password: [Your chosen password]

**Test Users:** (Create during setup)
- Academic Supervisor: academic.supervisor
- HR Coordinator: hr.coordinator  
- Student: student.demo

## Troubleshooting

### Database Issues
If you need to reset the database:
```bash
docker exec -i odoo_postgres psql -U odoo -c "DROP DATABASE IF EXISTS odoo;"
docker exec -i odoo_postgres psql -U odoo -c "CREATE DATABASE odoo;"
docker restart odoo_enterprise
```

### Module Installation Issues
- Clear browser cache
- Restart Odoo container
- Check module dependencies

### Permission Issues
- Verify user groups assignment
- Check access rights in Security settings
- Review record rules

---

## Next Steps After Setup

1. **Customize Forms**: Add academic-specific fields
2. **Configure Workflows**: Set up automated actions  
3. **Design Reports**: Create evaluation forms
4. **Integration**: Connect with academic systems
5. **Training**: Prepare user documentation

Your AdmasAfroLink internship platform will be ready for production use!
