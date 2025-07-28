# Direct Server Deployment Commands

Since you're running directly on the server, let's bypass the deployment agent and start services manually:

## Step 1: Configure Environment for Local Deployment

```bash
# Edit the deployment configuration
nano deployment-agent.conf
```

**Change these lines in deployment-agent.conf:**
```bash
SERVER_HOST="localhost"  # Change from remote IP to localhost
SERVER_USER="admas"      # Change to your current user
SERVER_PATH="/home/admas/AdmasAfroLink"  # Update path
```

## Step 2: Start Services Manually

```bash
# Check if .env file needs configuration
cat .env

# Start Docker services
docker-compose up -d

# Check if services started
docker-compose ps

# If services didn't start, check logs
docker-compose logs
```

## Step 3: Extract Enterprise Addons

```bash
# Extract enterprise addons
./extract-enterprise-addons.sh

# Check what was extracted
ls -la enterprise/
```

## Step 4: Restart Services with Enterprise Addons

```bash
# Restart to pick up enterprise addons
docker-compose down
docker-compose up -d

# Wait for startup
sleep 30

# Check status
docker-compose ps
```

## Step 5: Test Access

```bash
# Test local access
curl -I http://localhost:8069

# If not working, check specific service logs
docker-compose logs odoo
docker-compose logs db
```

## Troubleshooting Commands

```bash
# Check if Docker is running
sudo systemctl status docker

# Check if ports are bound
sudo netstat -tulpn | grep :8069

# Check disk space
df -h

# Check memory
free -h

# View all logs
docker-compose logs --tail=50
```
