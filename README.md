# AdmasAfroLink

Practical guide for setting up and using the AdmasAfroLink platform (frontend + backend + database) in development.

## What this repository contains

- `frontend/` - Next.js web app
- `backend/AdmasAfroLink.API/` - ASP.NET Core API
- `docker-compose.integrated.yml` - Integrated local stack
- `deploy-integrated.sh` / `deploy-integrated.ps1` - Helper scripts to run the stack

## Prerequisites

- Docker + Docker Compose
- Node.js 18+ (for frontend local runs)
- .NET SDK 9 (for backend local runs)

## Quick start (recommended)

1. Clone and enter the repo:
   ```bash
   git clone <repository-url>
   cd AdmasAfroLink
   ```
2. Create environment file:
   ```bash
   cp .env.example .env
   ```
3. Start integrated services:
   - Linux/macOS:
     ```bash
     chmod +x deploy-integrated.sh
     ./deploy-integrated.sh start dev
     ```
   - Windows (PowerShell):
     ```powershell
     .\deploy-integrated.ps1 start dev
     ```

## Service URLs (dev profile)

- Frontend: http://localhost:3000
- API: http://localhost:7001
- pgAdmin: http://localhost:5050
- Redis Commander: http://localhost:8081
- Portainer: http://localhost:9000

## How to use day-to-day

### Script commands

- Check status:
  ```bash
  ./deploy-integrated.sh status
  ```
- View logs:
  ```bash
  ./deploy-integrated.sh logs
  ./deploy-integrated.sh logs api
  ```
- Health check:
  ```bash
  ./deploy-integrated.sh health
  ```
- Restart:
  ```bash
  ./deploy-integrated.sh restart dev
  ```
- Stop:
  ```bash
  ./deploy-integrated.sh stop
  ```
- Cleanup (removes data/volumes):
  ```bash
  ./deploy-integrated.sh cleanup
  ```

## Alternative local development (without Docker)

### Backend

```bash
cd backend/AdmasAfroLink.API
dotnet restore
dotnet run
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

## Build and test

### Backend

```bash
dotnet restore
dotnet build --no-restore --configuration Release
dotnet test --no-build --configuration Release
```

### Frontend

```bash
cd frontend
npm install
npm run type-check
npm run build
```

## Notes

- If `npm run lint` prompts ESLint setup, add an ESLint config to `frontend/` first.
- Review `.env` values before running in non-development environments.
