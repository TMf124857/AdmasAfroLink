# AdmasAfroLink Initial Configuration Script (PowerShell)
# Run this after completing the initial setup wizard

Write-Host "=== AdmasAfroLink Post-Setup Configuration ===" -ForegroundColor Green
Write-Host "🚀 Configuring additional settings..." -ForegroundColor Yellow

# Wait for Odoo to be fully ready
Write-Host "⏳ Waiting for Odoo to be ready..." -ForegroundColor Blue
Start-Sleep -Seconds 30

# Database connection details
$DB_NAME = "admasafrolink_uganda"
$DB_USER = "odoo"
$DB_HOST = "odoo_postgres"

Write-Host "📊 Setting up basic configuration..." -ForegroundColor Cyan

# SQL script for configuration
$sqlScript = @"
-- Update company information
UPDATE res_company SET 
    name = 'AdmasAfroLink Limited',
    email = 'info@admasafrolink.com',
    website = 'https://admasafrolink.com',
    street = 'Plot 123, Kampala Road',
    city = 'Kampala',
    zip = '00256',
    phone = '+256 XXX XXXXXX'
WHERE id = 1;

-- Set timezone
UPDATE res_users SET tz = 'Africa/Kampala' WHERE id = 1;

-- Create basic user groups
INSERT INTO res_groups (name, comment) VALUES
    ('Academic Supervisors', 'University staff managing student internships'),
    ('HR Coordinators', 'AdmasAfroLink staff coordinating internships'),
    ('Host Organization Reps', 'Company representatives managing internship opportunities'),
    ('Students', 'Students applying for internships')
ON CONFLICT (name) DO NOTHING;
"@

# Execute SQL commands
try {
    docker exec odoo_postgres psql -U $DB_USER -d $DB_NAME -c $sqlScript
    Write-Host "✅ Database configuration completed!" -ForegroundColor Green
}
catch {
    Write-Warning "⚠️ Some configuration steps may need to be done manually through the web interface"
}

Write-Host ""
Write-Host "✅ Post-setup configuration completed!" -ForegroundColor Green
Write-Host "🎯 Next steps:" -ForegroundColor Magenta
Write-Host "1. Complete the web-based setup wizard" -ForegroundColor White
Write-Host "2. Configure user groups and permissions" -ForegroundColor White
Write-Host "3. Set up recruitment pipeline" -ForegroundColor White
Write-Host ""
Write-Host "📱 Access URLs:" -ForegroundColor Cyan
Write-Host "• Main Platform: http://64.225.79.153:8069" -ForegroundColor White
Write-Host "• Database Admin: http://64.225.79.153:5050" -ForegroundColor White
Write-Host ""
Write-Host "🔑 Login credentials:" -ForegroundColor Yellow
Write-Host "• Admin: admin / admin123" -ForegroundColor White
Write-Host "• Database: admasafrolink_uganda" -ForegroundColor White

# Try to open browser
try {
    Start-Process "http://64.225.79.153:8069"
    Write-Host "🌐 Opening Odoo in browser..." -ForegroundColor Green
}
catch {
    Write-Host "📌 Please manually open: http://64.225.79.153:8069" -ForegroundColor Yellow
}
