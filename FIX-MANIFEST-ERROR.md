# Fix Odoo Startup Error - Manifest Syntax Issue

## Current Status: ✅ Services Running, ❌ Manifest Error

The services are up, but there's a syntax error in an addon manifest file. Let's fix it:

## Step 1: Check Enterprise Addons

```bash
# Check what's in the enterprise directory
ls -la enterprise/

# Look for any manifest files with issues
find enterprise/ -name "__manifest__.py" -exec echo "=== {} ===" \; -exec head -5 {} \;
```

## Step 2: Fix or Remove Problematic Manifests

```bash
# Check if there's a broken sample_enterprise manifest
if [ -f "enterprise/sample_enterprise/__manifest__.py" ]; then
    echo "Found sample enterprise manifest, checking syntax..."
    python3 -m py_compile enterprise/sample_enterprise/__manifest__.py
fi

# If it has syntax errors, remove or fix it
rm -rf enterprise/sample_enterprise/ 2>/dev/null || true
```

## Step 3: Extract Clean Enterprise Addons

```bash
# Run the enterprise extraction script
./extract-enterprise-addons.sh

# Check what was created
ls -la enterprise/
```

## Step 4: Restart Odoo Service

```bash
# Restart just the Odoo container to pick up changes
docker-compose restart odoo_enterprise

# Wait for startup
sleep 30

# Check if the error is gone
docker-compose logs odoo_enterprise --tail=20
```

## Step 5: Test Access

```bash
# Test if Odoo is accessible now
curl -I http://localhost:8069

# If working, you should see HTTP/1.1 200 OK or 303 redirect
```

## Alternative: Quick Fix

```bash
# Quick one-liner to fix and restart
rm -rf enterprise/sample_enterprise/ && ./extract-enterprise-addons.sh && docker-compose restart odoo_enterprise
```
