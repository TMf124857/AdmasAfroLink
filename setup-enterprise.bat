@echo off
REM Odoo Enterprise Setup Script for Windows
REM This script helps set up Odoo Enterprise with community alternatives

setlocal enabledelayedexpansion

REM Function to print colored output
:print_status
echo [INFO] %~1
goto :eof

:print_warning
echo [WARNING] %~1
goto :eof

:print_error
echo [ERROR] %~1
goto :eof

:print_header
echo ================================================================
echo %~1
echo ================================================================
goto :eof

REM Function to create sample enterprise module
:create_sample_enterprise
call :print_header "CREATING SAMPLE ENTERPRISE MODULE"

if not exist enterprise mkdir enterprise
if not exist enterprise\sample_enterprise mkdir enterprise\sample_enterprise
if not exist enterprise\sample_enterprise\views mkdir enterprise\sample_enterprise\views
if not exist enterprise\sample_enterprise\static mkdir enterprise\sample_enterprise\static
if not exist enterprise\sample_enterprise\static\description mkdir enterprise\sample_enterprise\static\description

REM Create __manifest__.py
echo {> enterprise\sample_enterprise\__manifest__.py
echo     'name': 'Sample Enterprise Module',>> enterprise\sample_enterprise\__manifest__.py
echo     'version': '17.0.1.0.0',>> enterprise\sample_enterprise\__manifest__.py
echo     'category': 'Enterprise',>> enterprise\sample_enterprise\__manifest__.py
echo     'summary': 'Sample Enterprise Module for Testing',>> enterprise\sample_enterprise\__manifest__.py
echo     'description': '''>> enterprise\sample_enterprise\__manifest__.py
echo         This is a sample enterprise module to test your Odoo Enterprise setup.>> enterprise\sample_enterprise\__manifest__.py
echo         It demonstrates that enterprise addons are properly loaded.>> enterprise\sample_enterprise\__manifest__.py
echo     ''',>> enterprise\sample_enterprise\__manifest__.py
echo     'author': 'Your Company',>> enterprise\sample_enterprise\__manifest__.py
echo     'website': 'https://yourcompany.com',>> enterprise\sample_enterprise\__manifest__.py
echo     'license': 'LGPL-3',>> enterprise\sample_enterprise\__manifest__.py
echo     'depends': ['base'],>> enterprise\sample_enterprise\__manifest__.py
echo     'data': [>> enterprise\sample_enterprise\__manifest__.py
echo         'views/sample_views.xml',>> enterprise\sample_enterprise\__manifest__.py
echo     ],>> enterprise\sample_enterprise\__manifest__.py
echo     'installable': True,>> enterprise\sample_enterprise\__manifest__.py
echo     'auto_install': False,>> enterprise\sample_enterprise\__manifest__.py
echo     'application': False,>> enterprise\sample_enterprise\__manifest__.py
echo     'enterprise': True,>> enterprise\sample_enterprise\__manifest__.py
echo }>> enterprise\sample_enterprise\__manifest__.py

REM Create __init__.py
echo # Sample Enterprise Module> enterprise\sample_enterprise\__init__.py

REM Create views
echo ^<?xml version="1.0" encoding="utf-8"?^>> enterprise\sample_enterprise\views\sample_views.xml
echo ^<odoo^>>> enterprise\sample_enterprise\views\sample_views.xml
echo     ^<record id="view_sample_enterprise_menu" model="ir.ui.menu"^>>> enterprise\sample_enterprise\views\sample_views.xml
echo         ^<field name="name"^>Sample Enterprise^</field^>>> enterprise\sample_enterprise\views\sample_views.xml
echo         ^<field name="sequence"^>100^</field^>>> enterprise\sample_enterprise\views\sample_views.xml
echo         ^<field name="web_icon"^>sample_enterprise,static/description/icon.png^</field^>>> enterprise\sample_enterprise\views\sample_views.xml
echo     ^</record^>>> enterprise\sample_enterprise\views\sample_views.xml
echo ^</odoo^>>> enterprise\sample_enterprise\views\sample_views.xml

call :print_status "Sample enterprise module created in enterprise\sample_enterprise"
goto :eof

REM Function to download OCA modules (requires git)
:download_oca_modules
call :print_header "DOWNLOADING OCA COMMUNITY MODULES"

if not exist addons mkdir addons

call :print_status "Downloading core OCA modules..."

REM Check if git is available
git --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Git is not installed or not in PATH. Please install Git to download OCA modules."
    goto :eof
)

REM Core modules
call :print_status "Cloning server-tools..."
if not exist addons\server-tools (
    git clone -b 17.0 https://github.com/OCA/server-tools.git addons\server-tools
) else (
    call :print_warning "server-tools already exists, skipping..."
)

call :print_status "Cloning web..."
if not exist addons\web (
    git clone -b 17.0 https://github.com/OCA/web.git addons\web
) else (
    call :print_warning "web already exists, skipping..."
)

call :print_status "Cloning reporting-engine..."
if not exist addons\reporting-engine (
    git clone -b 17.0 https://github.com/OCA/reporting-engine.git addons\reporting-engine
) else (
    call :print_warning "reporting-engine already exists, skipping..."
)

call :print_status "Cloning account-financial-tools..."
if not exist addons\account-financial-tools (
    git clone -b 17.0 https://github.com/OCA/account-financial-tools.git addons\account-financial-tools
) else (
    call :print_warning "account-financial-tools already exists, skipping..."
)

call :print_status "OCA modules downloaded successfully!"
goto :eof

REM Function to show help
:show_help
call :print_header "ODOO ENTERPRISE SETUP HELPER FOR WINDOWS"
echo.
echo Usage: %0 [COMMAND]
echo.
echo Commands:
echo   sample    - Create sample enterprise module for testing
echo   oca       - Download OCA community modules (requires git)
echo   help      - Show this help message
echo.
echo Examples:
echo   %0 sample
echo   %0 oca
echo.
echo Notes:
echo   - For OCA modules, you need Git installed
echo   - Sample module helps test enterprise setup
echo   - Place official enterprise addons in .\enterprise\ directory
goto :eof

REM Main script logic
if "%1"=="sample" (
    call :create_sample_enterprise
) else if "%1"=="oca" (
    call :download_oca_modules
) else if "%1"=="help" (
    call :show_help
) else if "%1"=="" (
    call :show_help
) else (
    call :print_error "Unknown command: %1"
    call :show_help
)
