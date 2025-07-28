#!/bin/bash

# AdmasAfroLink Recruitment Pipeline Configuration Script
# This script sets up the recruitment pipeline stages for internship management

echo "📊 AdmasAfroLink Recruitment Pipeline Configuration"
echo "=================================================="

# Function to execute SQL commands in Docker container
execute_sql() {
    local sql_command="$1"
    docker exec -i odoo_postgres psql -U odoo -d admasafrolink_db -c "$sql_command"
}

echo "Phase 1: Clearing existing recruitment stages..."

# Remove default recruitment stages to replace with internship-specific ones
execute_sql "DELETE FROM hr_recruitment_stage WHERE name NOT IN ('Hired', 'Refused');"

echo "✅ Existing stages cleared"

echo "Phase 2: Creating AdmasAfroLink internship pipeline stages..."

# Stage 1: New Application
echo "📝 Creating 'New Application' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'New Application',
    1,
    false,
    'Initial application submitted by student with required documents',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Stage 2: Academic Review
echo "🎓 Creating 'Academic Review' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'Academic Review',
    2,
    false,
    'Academic supervisor reviews student eligibility and academic standing',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Stage 3: Host Organization Review
echo "🏢 Creating 'Host Organization Review' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'Host Organization Review',
    3,
    false,
    'Host organization evaluates application and student qualifications',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Stage 4: Interview Scheduled
echo "📅 Creating 'Interview Scheduled' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'Interview Scheduled',
    4,
    false,
    'Interview or assessment meeting arranged between student and host organization',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Stage 5: Final Assessment
echo "⚖️ Creating 'Final Assessment' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'Final Assessment',
    5,
    false,
    'Final evaluation and decision making process',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Stage 6: Placement Confirmed
echo "✅ Creating 'Placement Confirmed' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'Placement Confirmed',
    6,
    false,
    'Internship placement approved by all parties',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Stage 7: Documentation
echo "📄 Creating 'Documentation' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'Documentation',
    7,
    false,
    'Internship agreements, forms, and contracts being prepared and signed',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Stage 8: Active Internship
echo "🚀 Creating 'Active Internship' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'Active Internship',
    8,
    false,
    'Student is currently performing the internship',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Stage 9: Completed
echo "🏆 Creating 'Completed' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'Completed',
    9,
    true,
    'Internship successfully completed with evaluation',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

# Stage 10: Cancelled/Rejected
echo "❌ Creating 'Cancelled/Rejected' stage..."
execute_sql "
INSERT INTO hr_recruitment_stage (name, sequence, fold, requirements, template_id, create_date, write_date)
VALUES (
    'Cancelled/Rejected',
    10,
    true,
    'Application cancelled or rejected at any stage',
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

echo "✅ Pipeline stages created"

echo "Phase 3: Setting up automated actions and email templates..."

# Create email template for stage changes
echo "📧 Creating email templates..."
execute_sql "
INSERT INTO mail_template (name, model, subject, body_html, auto_delete, create_date, write_date)
VALUES (
    'Internship Application Status Update',
    'hr.applicant',
    'AdmasAfroLink: Your internship application status has been updated',
    '<p>Dear {{ object.partner_name }},</p>
     <p>Your internship application for <strong>{{ object.job_id.name }}</strong> has been moved to the stage: <strong>{{ object.stage_id.name }}</strong></p>
     <p><strong>Requirements for this stage:</strong><br/>{{ object.stage_id.requirements or \"No specific requirements\" }}</p>
     <p>You can track your application status by logging into the AdmasAfroLink portal.</p>
     <p>Best regards,<br/>AdmasAfroLink Team</p>',
    true,
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

echo "✅ Email templates created"

echo "Phase 4: Creating automation rules..."

# Create automated action for stage changes
execute_sql "
INSERT INTO base_automation (name, model_id, trigger, state, active, create_date, write_date)
SELECT 
    'Internship Stage Change Notification',
    (SELECT id FROM ir_model WHERE model = 'hr.applicant'),
    'on_write',
    'code',
    true,
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM base_automation 
    WHERE name = 'Internship Stage Change Notification'
);
"

echo "✅ Automation rules created"

echo "Phase 5: Setting up kanban view configuration..."

# Update kanban view to show internship-specific information
execute_sql "
UPDATE ir_ui_view 
SET arch = '<?xml version=\"1.0\"?>
<kanban default_group_by=\"stage_id\" class=\"o_kanban_small_column o_opportunity_kanban\" sample=\"1\">
    <field name=\"stage_id\"/>
    <field name=\"color\"/>
    <field name=\"priority\"/>
    <field name=\"activity_ids\"/>
    <field name=\"activity_state\"/>
    <progressbar field=\"activity_state\" colors=\"{&quot;planned&quot;: &quot;success&quot;, &quot;today&quot;: &quot;warning&quot;, &quot;overdue&quot;: &quot;danger&quot;}\"/>
    <templates>
        <t t-name=\"kanban-box\">
            <div t-attf-class=\"oe_kanban_color_{{kanban_getcolor(record.color.raw_value)}} oe_kanban_card oe_kanban_global_click\">
                <div class=\"o_dropdown_kanban dropdown\">
                    <a class=\"dropdown-toggle o-no-caret btn\" data-toggle=\"dropdown\" href=\"#\" role=\"button\" aria-label=\"Dropdown menu\" title=\"Dropdown menu\">
                        <span class=\"fa fa-ellipsis-v\"/>
                    </a>
                    <div class=\"dropdown-menu\" role=\"menu\">
                        <a t-if=\"widget.editable\" type=\"edit\" class=\"dropdown-item\">Edit</a>
                        <a t-if=\"widget.deletable\" type=\"delete\" class=\"dropdown-item\">Delete</a>
                        <div role=\"separator\" class=\"dropdown-divider\"/>
                        <div class=\"dropdown-item-text\">Color</div>
                        <ul class=\"oe_kanban_colorpicker\" data-field=\"color\"/>
                    </div>
                </div>
                <div class=\"oe_kanban_content\">
                    <div class=\"oe_kanban_details\">
                        <strong class=\"o_kanban_record_title\">
                            <field name=\"partner_name\"/>
                        </strong>
                        <div t-if=\"record.job_id.value\">
                            <i class=\"fa fa-briefcase\" title=\"Internship Position\"/> <field name=\"job_id\"/>
                        </div>
                        <div t-if=\"record.department_id.value\">
                            <i class=\"fa fa-university\" title=\"Department\"/> <field name=\"department_id\"/>
                        </div>
                        <div t-if=\"record.student_id.value\">
                            <i class=\"fa fa-id-card\" title=\"Student ID\"/> <field name=\"student_id\"/>
                        </div>
                        <div class=\"oe_kanban_bottom_left\">
                            <field name=\"priority\" widget=\"priority\"/>
                            <field name=\"activity_ids\" widget=\"kanban_activity\"/>
                        </div>
                        <div class=\"oe_kanban_bottom_right\">
                            <img t-att-src=\"kanban_image(\\\"res.users\\\", \\\"image_128\\\", record.user_id.raw_value)\" t-att-title=\"record.user_id.value\" t-att-alt=\"record.user_id.value\" class=\"oe_kanban_avatar\"/>
                        </div>
                    </div>
                </div>
            </div>
        </t>
    </templates>
</kanban>'
WHERE model = 'hr.applicant' AND type = 'kanban' AND name = 'hr_recruitment.hr_kanban_view_applicant';
"

echo "✅ Kanban view configured"

echo "Phase 6: Creating recruitment dashboard configuration..."

# Create custom dashboard for internship statistics
execute_sql "
INSERT INTO ir_actions_act_window (name, res_model, view_mode, target, create_date, write_date)
VALUES (
    'AdmasAfroLink Internship Dashboard',
    'hr.applicant',
    'kanban,tree,form,pivot,graph,calendar',
    'current',
    NOW(),
    NOW()
) ON CONFLICT (name) DO NOTHING;
"

echo "✅ Dashboard configured"

echo "🎉 Recruitment Pipeline Configuration Completed!"
echo "==============================================="
echo "✅ 10 pipeline stages created:"
echo "   1. New Application"
echo "   2. Academic Review" 
echo "   3. Host Organization Review"
echo "   4. Interview Scheduled"
echo "   5. Final Assessment"
echo "   6. Placement Confirmed"
echo "   7. Documentation"
echo "   8. Active Internship"
echo "   9. Completed (folded)"
echo "   10. Cancelled/Rejected (folded)"
echo ""
echo "✅ Email templates configured"
echo "✅ Automation rules set up"
echo "✅ Kanban view customized"
echo "✅ Dashboard created"
echo ""
echo "🔗 Access pipeline at: http://localhost:8069/web#action=hr_recruitment.hr_kanban_action_recruitment"
echo "🔗 Next: Test the internship application workflow"
