# Git Divergent Branches Resolution

## Run these commands on your Ubuntu server to fix the git issue:

```bash
# 1. First, backup any important local changes
git stash push -m "Server backup before reconcile $(date)"

# 2. Configure git pull behavior (choose one approach)
# Option A: Use merge strategy (recommended for servers)
git config pull.rebase false

# 3. Force pull with merge strategy
git pull origin main --no-rebase

# If the above still fails, use the force approach:
# 4. Force update to match remote exactly
git fetch origin main
git reset --hard origin/main

# 5. Clean up any untracked files
git clean -fd

# 6. Verify we're up to date
git status
git log --oneline -5

# 7. Make scripts executable
chmod +x deploy deployment-agent.sh extract-enterprise-addons.sh

# 8. Check the updated structure
ls -la
```

## Alternative: Complete Fresh Start (if above doesn't work)

```bash
# Backup important files first
cp .env .env.backup 2>/dev/null || true
cp -r logs logs_backup 2>/dev/null || true

# Remove and re-clone
cd ..
rm -rf AdmasAfroLink
git clone https://github.com/TMf124857/AdmasAfroLink.git
cd AdmasAfroLink

# Restore your environment file
cp ../AdmasAfroLink_old/.env . 2>/dev/null || cp .env.example .env

# Set permissions
chmod +x deploy deployment-agent.sh extract-enterprise-addons.sh

echo "Fresh clone completed. Please configure .env if needed."
```

## Quick One-Liner Fix:
```bash
git stash && git config pull.rebase false && git fetch origin main && git reset --hard origin/main && chmod +x deploy deployment-agent.sh extract-enterprise-addons.sh
```
