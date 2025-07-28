# Quick Server Update Commands

## Copy and paste these commands on your Ubuntu server:

```bash
# 1. Remove conflicting files
rm -rf enterprise/sample_enterprise

# 2. Stash any local changes
git stash push -m "Server cleanup $(date)"

# 3. Pull latest changes
git pull origin main

# 4. Make scripts executable
chmod +x deploy deployment-agent.sh extract-enterprise-addons.sh

# 5. Check updated structure
ls -la

# 6. Configure environment (if .env doesn't exist)
if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠️  Please edit .env with your production settings:"
    echo "   nano .env"
fi

# 7. Extract enterprise addons
./extract-enterprise-addons.sh

# 8. Deploy the application
./deploy setup
./deploy deploy
```

## Alternative: One-line update (if you trust automation)
```bash
# Download and run update script
curl -s https://raw.githubusercontent.com/TMf124857/AdmasAfroLink/main/update-server.sh | bash
```

## Manual step-by-step if needed:
```bash
# Remove conflicting files
rm -rf enterprise/sample_enterprise

# Force update to match remote
git fetch origin main
git reset --hard origin/main

# Set permissions
chmod +x deploy deployment-agent.sh extract-enterprise-addons.sh

# Check what we have
ls -la
```
