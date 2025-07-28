# Fix Static Assets 500 Errors

## 🔍 Issue Analysis:
Your Odoo pages load fine (200 OK), but static assets return 500 errors:
- Images: `/web/static/img/odoo_logo_tiny.png` → 500
- CSS: `/web/assets/*/web.assets_frontend.min.css` → 500  
- JS: `/web/assets/*/web.assets_frontend_minimal.min.js` → 500
- Fonts: `fontawesome-webfont.woff2` → 500

This is the addon manifest syntax error affecting static file processing.

## 🚀 Quick Fix Commands:

```bash
# 1. Stop containers
docker-compose down

# 2. Find and remove problematic addon manifests
find addons/ enterprise/ -name "__manifest__.py" -exec python3 -c "
import ast
import sys
try:
    with open(sys.argv[1], 'r') as f:
        content = f.read().strip()
        if not content:
            print('EMPTY:', sys.argv[1])
        else:
            ast.literal_eval(content)
except Exception as e:
    print('CORRUPTED:', sys.argv[1], '-', str(e))
" {} \;

# 3. Remove any empty or corrupted manifests
find addons/ enterprise/ -name "__manifest__.py" -size 0 -delete

# 4. Clean up enterprise directory completely
rm -rf enterprise/*

# 5. Re-extract enterprise addons properly
./extract-enterprise-addons.sh

# 6. Clear Odoo cache and restart
docker-compose up -d

# 7. Wait for full startup
sleep 60

# 8. Test static assets
curl -I http://localhost:8069/web/static/img/odoo_logo_tiny.png
```

## Alternative: Clean Slate Approach

```bash
# 1. Stop everything
docker-compose down

# 2. Remove problematic volumes (will regenerate)
docker-compose down -v

# 3. Clean enterprise and addons
rm -rf enterprise/* addons/*

# 4. Create minimal working enterprise structure
mkdir -p enterprise/sample_enterprise
cat > enterprise/sample_enterprise/__manifest__.py << 'EOF'
{
    'name': 'Sample Enterprise',
    'version': '17.0.1.0.0',
    'category': 'Hidden',
    'summary': 'Sample Enterprise Module',
    'depends': ['base'],
    'installable': True,
    'auto_install': False,
    'license': 'LGPL-3',
}
EOF

echo "# Sample Enterprise Module" > enterprise/sample_enterprise/__init__.py

# 5. Start fresh
docker-compose up -d

# 6. Monitor startup
docker-compose logs -f odoo_enterprise
```

## Real-time Debugging:

```bash
# Check Odoo logs for specific errors
docker-compose logs odoo_enterprise | grep -i "manifest\|syntax\|error" | tail -20

# Test different static assets
curl -I http://localhost:8069/web/static/src/css/bootstrap.css
curl -I http://localhost:8069/web/static/img/favicon.ico

# Check if specific paths work
curl -I http://64.225.79.153/web/login
curl -I http://64.225.79.153/web/static/img/odoo_logo_tiny.png
```

## Expected Results After Fix:

```bash
# This should return 200 OK instead of 500
curl -I http://localhost:8069/web/static/img/odoo_logo_tiny.png

# Should see:
# HTTP/1.0 200 OK
# Content-Type: image/png
```

## If Problem Persists:

```bash
# Check Odoo error logs specifically
docker-compose logs odoo_enterprise 2>&1 | grep -A 5 -B 5 "static\|manifest"

# Restart with clean asset generation
docker-compose restart odoo_enterprise

# Clear browser cache and test in incognito mode
```

The issue is that Odoo can serve pages but fails when processing static assets due to the corrupt addon manifest we discussed earlier.
