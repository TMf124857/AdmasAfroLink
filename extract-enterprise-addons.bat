@echo off
REM Enterprise Addons Extraction Script for Windows
REM Extracts Odoo Enterprise addons from the tarball following OOP principles

setlocal enabledelayedexpansion

echo 🚀 Odoo Enterprise Addons Extraction Script
echo ============================================

REM Check if tar.gz file exists
if not exist "odoo_17.0+e.latest.tar.gz" (
    echo ❌ Error: odoo_17.0+e.latest.tar.gz not found in current directory
    echo 💡 Please ensure the enterprise tarball is in the same directory as this script
    exit /b 1
)

REM Check if enterprise directory exists
if not exist "enterprise" (
    echo 📁 Creating enterprise directory...
    mkdir enterprise
) else (
    echo ⚠️  Enterprise directory already exists
    echo 🔄 Backing up existing enterprise directory...
    if exist "enterprise_backup" rmdir /s /q enterprise_backup
    move enterprise enterprise_backup
    mkdir enterprise
)

echo 📦 Extracting enterprise addons from tarball...

REM Extract using tar (available in Windows 10+)
tar -xzf odoo_17.0+e.latest.tar.gz

REM Check if extraction was successful
if not exist "odoo" (
    echo ❌ Error: Failed to extract tarball or unexpected directory structure
    exit /b 1
)

echo 🔧 Processing enterprise modules following OOP structure...

REM Move enterprise addons to enterprise directory
if exist "odoo\addons" (
    echo 📂 Moving enterprise addons...
    xcopy "odoo\addons\*" "enterprise\" /s /e /y
    echo ✅ Enterprise addons extracted successfully
) else (
    echo ❌ Error: Expected addons directory not found in extracted files
    exit /b 1
)

REM Clean up extracted odoo directory
echo 🧹 Cleaning up temporary files...
rmdir /s /q odoo

REM Verify enterprise modules
echo 🔍 Verifying extracted enterprise modules...
echo.
echo 📋 Extracted Enterprise Modules:
echo ================================

REM List key enterprise modules with their OOP patterns
for /d %%i in (enterprise\*) do (
    set "module_name=%%~nxi"
    echo - !module_name!
    
    REM Check for key OOP pattern files
    if exist "enterprise\!module_name!\models" (
        echo   └── Models: Found
    )
    if exist "enterprise\!module_name!\views" (
        echo   └── Views: Found  
    )
    if exist "enterprise\!module_name!\__manifest__.py" (
        echo   └── Manifest: Found
    )
)

echo.
echo 🎉 Enterprise addons extraction completed!
echo.
echo 📋 Next Steps:
echo ==============
echo 1. Restart Odoo services: docker-compose restart odoo
echo 2. Access Odoo at: http://localhost:8069
echo 3. Go to Apps menu and install enterprise modules
echo 4. Follow ENTERPRISE-CONVERSION-GUIDE.md for detailed instructions
echo.
echo ⚠️  Enterprise Features Available:
echo   - Advanced Accounting (account_accountant)
echo   - Project Management (project_enterprise)  
echo   - Advanced HR (hr_holidays_enterprise)
echo   - Sales Enterprise (sale_enterprise)
echo   - Stock Enterprise (stock_enterprise)
echo   - Website Enterprise (website_enterprise)
echo.
pause
