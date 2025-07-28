# Odoo Enterprise Model Development Examples
# Following Object-Oriented Programming principles from Odoo documentation

"""
This file demonstrates how to create and extend Odoo models following 
enterprise patterns and OOP best practices.
"""

from odoo import models, fields, api
from odoo.exceptions import UserError, ValidationError


# =============================================================================
# 1. ABSTRACT MODEL PATTERN - Base classes for Enterprise features
# =============================================================================

class AnalyticMixin(models.AbstractModel):
    """
    Abstract mixin providing analytic accounting functionality.
    Used across Enterprise modules for consistent analytic integration.
    """
    _name = 'analytic.mixin'
    _description = 'Analytic Mixin'
    
    analytic_account_id = fields.Many2one(
        'account.analytic.account',
        string='Analytic Account',
        index=True,
        help="The analytic account related to this record"
    )
    analytic_tag_ids = fields.Many2many(
        'account.analytic.tag',
        string='Analytic Tags',
        help="Optional analytic tags for further categorization"
    )
    
    def _prepare_analytic_line_values(self):
        """Prepare values for analytic line creation"""
        return {
            'account_id': self.analytic_account_id.id,
            'tag_ids': [(6, 0, self.analytic_tag_ids.ids)],
            'name': self.name or '/',
        }


# =============================================================================
# 2. MODEL INHERITANCE PATTERN - Extending Community models
# =============================================================================

class SaleOrderEnterprise(models.Model):
    """
    Enterprise extension of sale.order following inheritance patterns
    from Odoo documentation.
    """
    _inherit = 'sale.order'
    
    # Enterprise-specific fields
    project_id = fields.Many2one(
        'project.project',
        string='Project',
        copy=False,
        help="Project created automatically from this sales order"
    )
    timesheet_ids = fields.One2many(
        'account.analytic.line',
        'so_line',
        string='Timesheets',
        domain=lambda self: [('project_id', '!=', False)]
    )
    
    # Computed fields following Enterprise patterns
    timesheet_count = fields.Integer(
        string='Timesheet Count',
        compute='_compute_timesheet_count'
    )
    
    @api.depends('timesheet_ids')
    def _compute_timesheet_count(self):
        """Compute timesheet count for smart button"""
        for order in self:
            order.timesheet_count = len(order.timesheet_ids)
    
    @api.model
    def create(self, vals):
        """Override create to implement Enterprise logic"""
        order = super().create(vals)
        
        # Enterprise: Auto-create project if service products present
        if any(line.product_id.service_type in ['manual', 'timesheet'] 
               for line in order.order_line):
            order._create_project()
        
        return order
    
    def _create_project(self):
        """Create project following Enterprise patterns"""
        if not self.project_id:
            project_vals = {
                'name': f"Project - {self.name}",
                'partner_id': self.partner_id.id,
                'sale_order_id': self.id,
                'analytic_account_id': self._create_analytic_account().id,
            }
            self.project_id = self.env['project.project'].create(project_vals)
    
    def _create_analytic_account(self):
        """Create analytic account for project tracking"""
        return self.env['account.analytic.account'].create({
            'name': f"Analytic - {self.name}",
            'partner_id': self.partner_id.id,
            'plan_id': self.env.ref('analytic.analytic_plan_projects').id,
        })
    
    def action_view_timesheet(self):
        """Smart button action to view timesheets"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Timesheets',
            'res_model': 'account.analytic.line',
            'view_mode': 'tree,form',
            'domain': [('so_line', 'in', self.order_line.ids)],
            'context': {'default_project_id': self.project_id.id}
        }


# =============================================================================
# 3. MIXIN IMPLEMENTATION - Reusable Enterprise functionality
# =============================================================================

class ProjectTaskEnterprise(models.Model):
    """
    Enterprise extension using mixin pattern for timesheet integration
    """
    _inherit = ['project.task', 'analytic.mixin']
    _name = 'project.task'
    
    # Enterprise timesheet fields
    timesheet_ids = fields.One2many(
        'account.analytic.line',
        'task_id',
        string='Timesheets'
    )
    effective_hours = fields.Float(
        string='Hours Spent',
        compute='_compute_effective_hours',
        store=True
    )
    remaining_hours = fields.Float(
        string='Remaining Hours',
        compute='_compute_remaining_hours',
        store=True
    )
    sale_line_id = fields.Many2one(
        'sale.order.line',
        string='Sales Order Item',
        help="Sales order line that generated this task"
    )
    
    @api.depends('timesheet_ids.unit_amount')
    def _compute_effective_hours(self):
        """Compute effective hours from timesheets"""
        for task in self:
            task.effective_hours = sum(task.timesheet_ids.mapped('unit_amount'))
    
    @api.depends('planned_hours', 'effective_hours')
    def _compute_remaining_hours(self):
        """Compute remaining hours"""
        for task in self:
            task.remaining_hours = task.planned_hours - task.effective_hours
    
    def action_view_timesheet(self):
        """Action to view task timesheets"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Timesheets',
            'res_model': 'account.analytic.line',
            'view_mode': 'tree,form',
            'domain': [('task_id', '=', self.id)],
            'context': {
                'default_task_id': self.id,
                'default_project_id': self.project_id.id,
                'default_account_id': self.analytic_account_id.id,
            }
        }


# =============================================================================
# 4. WIZARD PATTERN - Enterprise-specific operations
# =============================================================================

class ProjectCreateTimesheetWizard(models.TransientModel):
    """
    Wizard for creating timesheets following Enterprise patterns
    """
    _name = 'project.create.timesheet.wizard'
    _description = 'Create Timesheet Wizard'
    
    task_id = fields.Many2one('project.task', required=True)
    employee_id = fields.Many2one('hr.employee', required=True)
    date = fields.Date(default=fields.Date.today)
    hours = fields.Float('Hours', required=True)
    description = fields.Text('Description')
    
    @api.model
    def default_get(self, fields_list):
        """Set default values from context"""
        result = super().default_get(fields_list)
        if self.env.context.get('active_id'):
            result['task_id'] = self.env.context['active_id']
        return result
    
    def create_timesheet(self):
        """Create timesheet entry with Enterprise validation"""
        self.ensure_one()
        
        # Enterprise validation
        if not self.task_id.project_id.analytic_account_id:
            raise UserError("Project must have an analytic account.")
        
        # Create timesheet
        timesheet_vals = {
            'task_id': self.task_id.id,
            'project_id': self.task_id.project_id.id,
            'account_id': self.task_id.project_id.analytic_account_id.id,
            'employee_id': self.employee_id.id,
            'date': self.date,
            'unit_amount': self.hours,
            'name': self.description or f"Timesheet for {self.task_id.name}",
        }
        
        timesheet = self.env['account.analytic.line'].create(timesheet_vals)
        
        return {
            'type': 'ir.actions.act_window',
            'res_model': 'account.analytic.line',
            'res_id': timesheet.id,
            'view_mode': 'form',
            'target': 'current',
        }


# =============================================================================
# 5. ENTERPRISE REPORTING MODEL
# =============================================================================

class ProjectTimesheetReport(models.Model):
    """
    Enterprise reporting model following OOP patterns
    """
    _name = 'project.timesheet.report'
    _description = 'Project Timesheet Analysis'
    _auto = False
    _rec_name = 'project_id'
    
    project_id = fields.Many2one('project.project', readonly=True)
    task_id = fields.Many2one('project.task', readonly=True)
    employee_id = fields.Many2one('hr.employee', readonly=True)
    date = fields.Date(readonly=True)
    hours = fields.Float(readonly=True)
    amount = fields.Monetary(readonly=True)
    currency_id = fields.Many2one('res.currency', readonly=True)
    
    def init(self):
        """Create database view for reporting"""
        tools.drop_view_if_exists(self.env.cr, self._table)
        self.env.cr.execute("""
            CREATE OR REPLACE VIEW %s AS (
                SELECT
                    aal.id,
                    aal.project_id,
                    aal.task_id,
                    aal.employee_id,
                    aal.date,
                    aal.unit_amount AS hours,
                    aal.amount,
                    aal.currency_id
                FROM account_analytic_line aal
                WHERE aal.project_id IS NOT NULL
                  AND aal.task_id IS NOT NULL
            )
        """ % self._table)


# =============================================================================
# 6. ENTERPRISE CONSTRAINT AND VALIDATION PATTERNS
# =============================================================================

class HREmployeeEnterprise(models.Model):
    """
    Enterprise HR extension with advanced validation
    """
    _inherit = 'hr.employee'
    
    timesheet_cost = fields.Float(
        string='Timesheet Cost',
        help="Cost per hour for timesheet entries"
    )
    analytic_account_ids = fields.Many2many(
        'account.analytic.account',
        string='Analytic Accounts',
        help="Analytic accounts this employee can log time to"
    )
    
    @api.constrains('timesheet_cost')
    def _check_timesheet_cost(self):
        """Enterprise validation for timesheet cost"""
        for employee in self:
            if employee.timesheet_cost < 0:
                raise ValidationError("Timesheet cost cannot be negative.")
    
    @api.model
    def create(self, vals):
        """Override create with Enterprise logic"""
        employee = super().create(vals)
        
        # Enterprise: Create default analytic account
        if not employee.analytic_account_ids:
            analytic_account = self.env['account.analytic.account'].create({
                'name': f"Employee - {employee.name}",
                'partner_id': employee.user_id.partner_id.id,
                'plan_id': self.env.ref('analytic.analytic_plan_internal').id,
            })
            employee.analytic_account_ids = [(4, analytic_account.id)]
        
        return employee


# =============================================================================
# USAGE EXAMPLES AND PATTERNS
# =============================================================================

"""
Enterprise Development Patterns Summary:

1. ABSTRACT MODELS (_name + _description)
   - Use for reusable functionality across modules
   - Example: AnalyticMixin for analytic integration

2. MODEL INHERITANCE (_inherit)
   - Extend Community models with Enterprise features
   - Use super() for method chaining
   - Example: SaleOrderEnterprise extending sale.order

3. MIXIN PATTERNS
   - Combine multiple inheritance for complex functionality
   - Example: ProjectTaskEnterprise inheriting from both project.task and analytic.mixin

4. WIZARD PATTERNS
   - Use TransientModel for temporary operations
   - Implement Enterprise-specific business logic
   - Example: ProjectCreateTimesheetWizard

5. REPORTING MODELS
   - Use _auto = False for database views
   - Implement init() for custom SQL views
   - Example: ProjectTimesheetReport

6. VALIDATION PATTERNS
   - Use @api.constrains for data validation
   - Override create/write for business rules
   - Example: HREmployeeEnterprise validation

Key Enterprise Features:
- Analytic Accounting integration
- Project and Task management  
- Timesheet tracking
- Advanced reporting
- Multi-company support
- Workflow automation

Follow these patterns when developing Enterprise extensions
to maintain consistency with Odoo's OOP architecture.
"""
