# Fix Permission Issues and Complete Update

## Run these commands on your Ubuntu server to resolve the permission issues:

```bash
# 1. Fix permission issues with enterprise directory
sudo rm -rf enterprise/sample_enterprise
sudo chown -R $USER:$USER enterprise/
sudo chmod -R 755 enterprise/

# 2. Now try the git reset again
git reset --hard origin/main

# 3. Check what files we actually have
ls -la

# 4. Make executable only the files that exist
chmod +x deploy 2>/dev/null || echo "deploy file not found"
chmod +x deployment-agent.sh 2>/dev/null || echo "deployment-agent.sh not found"
chmod +x extract-enterprise-addons.sh 2>/dev/null || echo "extract-enterprise-addons.sh not found"

# 5. Check git status
git status

# 6. Show current directory structure
echo "Current project structure:"
ls -la
```

## If files are still missing, force a complete update:

```bash
# 1. Remove problematic directories with sudo
sudo rm -rf enterprise/
sudo rm -rf logs/
sudo rm -rf __pycache__/

# 2. Reset file permissions
sudo chown -R $USER:$USER .
sudo chmod -R 755 .

# 3. Force git to recreate everything
git reset --hard origin/main
git clean -fd

# 4. Check what we have now
ls -la

# 5. Make scripts executable (only if they exist)
[ -f deploy ] && chmod +x deploy
[ -f deployment-agent.sh ] && chmod +x deployment-agent.sh  
[ -f extract-enterprise-addons.sh ] && chmod +x extract-enterprise-addons.sh
```

## Alternative: Fresh Clone (if problems persist)

```bash
# 1. Backup important files
cp .env ~/env_backup 2>/dev/null || true
cp -r logs ~/logs_backup 2>/dev/null || true

# 2. Go up one directory and remove current
cd ..
sudo rm -rf AdmasAfroLink

# 3. Fresh clone
git clone https://github.com/TMf124857/AdmasAfroLink.git
cd AdmasAfroLink

# 4. Restore environment file
cp ~/env_backup .env 2>/dev/null || cp .env.example .env

# 5. Set proper permissions
chmod +x deploy deployment-agent.sh extract-enterprise-addons.sh

# 6. Check structure
ls -la
```
