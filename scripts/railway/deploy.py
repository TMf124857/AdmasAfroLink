# Railway Deployment Configuration for AdmasAfroLink
railway_config = """
[build]
buildCommand = "dotnet publish -c Release -o out"
startCommand = "dotnet out/AdmasAfroLink.dll"

[settings]
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 3
"""

# railway.json - Railway service configuration
railway_json = """{
  "services": {
    "api": {
      "name": "admasafrolink-api",
      "source": {
        "repo": "TMf124857/AdmasAfroLink"
      },
      "variables": {
        "ASPNETCORE_ENVIRONMENT": "Production",
        "ASPNETCORE_URLS": "http://0.0.0.0:$PORT",
        "JwtSettings__Issuer": "https://admasafrolink-api.up.railway.app",
        "JwtSettings__Audience": "https://admasafrolink-api.up.railway.app",
        "JwtSettings__ExpiryInMinutes": "60"
      },
      "regions": ["us-west1"],
      "deploy": {
        "healthcheckPath": "/health",
        "healthcheckTimeout": 100,
        "restartPolicyType": "ON_FAILURE"
      }
    },
    "postgres": {
      "name": "admasafrolink-postgres",
      "source": {
        "image": "postgres:14"
      },
      "variables": {
        "POSTGRES_DB": "admasafrolink",
        "POSTGRES_USER": "admasadmin",
        "POSTGRES_PASSWORD": "AdmasAfro2024!"
      },
      "volumes": [
        {
          "mountPath": "/var/lib/postgresql/data",
          "size": "5Gi"
        }
      ]
    }
  },
  "environments": {
    "production": {
      "variables": {
        "ASPNETCORE_ENVIRONMENT": "Production"
      }
    }
  }
}"""

print("🚂 Railway Deployment Configuration for AdmasAfroLink")
print("=" * 60)
print()
print("1. Save the railway.json configuration:")
with open("railway.json", "w") as f:
    f.write(railway_json)
print("✅ railway.json created")

print()
print("2. Railway CLI deployment steps:")
print("   npm install -g @railway/cli")
print("   railway login")
print("   railway link (select your project)")
print("   railway up")
print()
print("3. Environment variables to set in Railway dashboard:")
env_vars = [
    "ConnectionStrings__DefaultConnection=postgresql://admasadmin:AdmasAfro2024!@postgres:5432/admasafrolink",
    "JwtSettings__Key=<generate-random-32-byte-key>",
    "JwtSettings__Issuer=https://admasafrolink-api.up.railway.app",
    "JwtSettings__Audience=https://admasafrolink-api.up.railway.app",
    "JwtSettings__ExpiryInMinutes=60",
    "ASPNETCORE_ENVIRONMENT=Production",
    "ASPNETCORE_URLS=http://0.0.0.0:$PORT"
]

for var in env_vars:
    print(f"   {var}")

print()
print("4. Connect PostgreSQL service:")
print("   - Add PostgreSQL service in Railway dashboard")
print("   - Use connection string: postgresql://admasadmin:AdmasAfro2024!@postgres:5432/admasafrolink")
print()
print("✅ Configuration complete! Deploy with: railway up")
