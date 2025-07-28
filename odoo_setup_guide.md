# AdmasAfroLink Odoo Setup Guide

## Step 1: Initial Setup Wizard

### Access the Platform
1. Open your browser and go to http://localhost:8069
2. You should see the Odoo setup wizard

### Database Setup
- **Database Name**: admasafrolink_db (should be auto-detected)
- **Email**: admin@admasafrolink.edu.et
- **Password**: Choose a strong password for the administrator
- **Phone**: +251-XXX-XXXXXX
- **Language**: English
- **Country**: Ethiopia
- **Demo Data**: Uncheck this box (we have our custom data)

### Company Information
- **Company Name**: AdmasAfroLink Internship Platform
- **Website**: https://admasafrolink.edu.et
- **Industry**: Education
- **Currency**: Ethiopian Birr (ETB)
- **Timezone**: Africa/Addis_Ababa

## Step 2: Module Configuration

### Required Modules (Should already be installed)
✅ HR Management
✅ Recruitment
✅ Website
✅ Portal
✅ Documents
✅ Sign
✅ Discuss

### Additional Modules to Install
- [ ] Project Management (for internship project tracking)
- [ ] Calendar (for scheduling interviews and meetings)
- [ ] Contacts (for managing host organizations)

## Step 3: User Groups and Permissions

### Core User Groups
1. **Internship Administrators**
   - Full access to all internship features
   - Can manage all applications and opportunities

2. **Academic Supervisors**
   - View and approve student applications
   - Monitor student progress
   - Generate academic reports

3. **HR Coordinators**
   - Manage host organizations
   - Coordinate placement activities
   - Handle documentation

4. **Students**
   - Apply for internships
   - View application status
   - Upload required documents

5. **Host Organization Representatives**
   - Post internship opportunities
   - Review applications
   - Provide feedback

## Step 4: Recruitment Pipeline Configuration

### Pipeline Stages for Internships
1. **New Application** (Initial submission)
2. **Academic Review** (Supervisor evaluation)
3. **Host Organization Review** (Company evaluation)
4. **Interview Scheduled** (Meeting arranged)
5. **Final Assessment** (Decision pending)
6. **Placement Confirmed** (Internship approved)
7. **Documentation** (Agreements and forms)
8. **Active Internship** (Currently ongoing)
9. **Completed** (Internship finished)
10. **Cancelled/Rejected** (Not proceeding)

### Automation Rules
- Send email notifications for stage changes
- Assign tasks to supervisors for reviews
- Generate documents automatically
- Set reminder schedules

## Step 5: Testing Workflow

### Test Scenarios
1. **Create Internship Opportunity**
2. **Student Application Process**
3. **Academic Supervisor Approval**
4. **Host Organization Review**
5. **Document Generation**
6. **Placement Confirmation**

---

## Quick Access URLs
- Main Dashboard: http://localhost:8069/web
- Recruitment: http://localhost:8069/web#action=hr_recruitment.hr_kanban_action_recruitment
- HR Management: http://localhost:8069/web#action=hr.open_view_employee_list_my
- Settings: http://localhost:8069/web#action=base.action_res_config_settings

## Support Contacts
- Technical Support: tech@admasafrolink.edu.et
- Academic Queries: academic@admasafrolink.edu.et
- General Info: info@admasafrolink.edu.et
