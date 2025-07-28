# Deployment Agent Quick Start Guide

## Overview
The AdmasAfroLink Deployment Agent automates the process of deploying code changes from your local development environment to your Ubuntu server and testing the deployment.

## Files Overview
- `deployment-agent.sh` - Main deployment script with all functionality
- `deployment-agent.conf` - Configuration file for server details
- `deploy` - Simple launcher script for easy usage

## Quick Setup

### 1. Configure Your Server Details
Edit `deployment-agent.conf` and update:
```bash
SERVER_HOST="your-server-ip-or-hostname"
SERVER_USER="ubuntu"
SERVER_PATH="/home/ubuntu/AdmasAfroLink"
```

### 2. Set Up SSH Access
Make sure you can SSH to your server without password:
```bash
# Run the SSH setup script
./setup-ssh-github.sh

# Test SSH connection
ssh ubuntu@your-server-ip
```

### 3. First-Time Setup
```bash
# Make scripts executable
chmod +x deploy deployment-agent.sh

# Run initial setup
./deploy setup
```

## Usage Commands

### Deploy Current Changes
```bash
./deploy deploy
```
This will:
- Add and commit any changes
- Push to GitHub
- Deploy to server
- Run health checks

### Auto-Deployment Mode
```bash
./deploy auto
```
This will:
- Monitor for file changes
- Automatically deploy when changes detected
- Run continuous health monitoring

### Test Deployment
```bash
./deploy test
```
This will:
- Test server connectivity
- Check Odoo health
- Validate enterprise modules

### Monitor Status
```bash
./deploy status
```

### View Logs
```bash
./deploy logs
```

### Rollback if Needed
```bash
./deploy rollback
```

## Configuration Options

### Basic Server Configuration
```bash
# In deployment-agent.conf
SERVER_HOST="your-server"
SERVER_USER="ubuntu"
SERVER_PATH="/home/ubuntu/AdmasAfroLink"
REPO_BRANCH="main"
```

### Health Check Configuration
```bash
HEALTH_CHECK_URL="http://localhost:8069"
HEALTH_CHECK_TIMEOUT=300
STARTUP_WAIT_TIME=30
```

### Enterprise Configuration
```bash
ENTERPRISE_TARBALL="odoo_17.0+e.latest.tar.gz"
FALLBACK_TO_COMMUNITY=true
CREATE_SAMPLE_ENTERPRISE=true
```

## Workflow Examples

### Development Workflow
1. Make changes to your Odoo code
2. Run `./deploy auto` to start auto-deployment
3. Agent automatically detects changes and deploys
4. Health checks ensure everything works
5. Notifications sent on success/failure

### Manual Deployment
1. Make your changes
2. Run `./deploy deploy`
3. Agent handles Git operations and server deployment
4. Check `./deploy status` for results

### Testing Workflow
1. Run `./deploy test` to validate current deployment
2. Check server logs if issues found
3. Use `./deploy rollback` if needed

## Troubleshooting

### SSH Connection Issues
```bash
# Check SSH key setup
ssh -T git@github.com

# Test server connection
ssh ubuntu@your-server-ip

# Re-run SSH setup if needed
./setup-ssh-github.sh
```

### Deployment Failures
```bash
# Check deployment logs
./deploy logs

# Check server status
./deploy status

# Rollback if needed
./deploy rollback
```

### Health Check Failures
```bash
# Test manually
curl http://your-server:8069

# Check Docker containers
ssh ubuntu@your-server "docker ps"

# Check Odoo logs
ssh ubuntu@your-server "docker logs admasafrolink_odoo_1"
```

## Advanced Features

### Custom Git Workflow
The agent supports custom commit messages:
```bash
./deploy deploy --message "Feature: Add new inventory module"
```

### Selective Deployment
Deploy only specific components:
```bash
./deploy deploy --only-addons
./deploy deploy --only-config
```

### Backup Management
Automatic backups are created before deployment:
```bash
# List backups
./deploy status --backups

# Restore from backup
./deploy rollback --backup-id "20240101_120000"
```

## Integration Options

### CI/CD Integration
Add to your `.github/workflows/deploy.yml`:
```yaml
- name: Deploy to Server
  run: ./deploy deploy --auto-confirm
```

### Monitoring Integration
Configure webhooks in `deployment-agent.conf`:
```bash
SLACK_WEBHOOK="https://hooks.slack.com/your-webhook"
EMAIL_NOTIFICATIONS=true
```

## Best Practices

1. **Always test locally first** before deploying
2. **Use auto mode during development** for continuous feedback
3. **Monitor health checks** and set up alerts
4. **Keep backups enabled** for easy rollback
5. **Use descriptive commit messages** for better tracking
6. **Test SSH connectivity** before deployment
7. **Monitor server resources** during deployment

## Support

If you encounter issues:
1. Check the logs: `./deploy logs`
2. Verify configuration: `cat deployment-agent.conf`
3. Test SSH: `ssh ubuntu@your-server`
4. Check server status: `./deploy status`

The deployment agent handles most common scenarios automatically, but manual intervention may be needed for complex issues.
