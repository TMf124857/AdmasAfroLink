# Use the official .NET 9 runtime as base image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Use the official .NET 9 SDK for building
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["AdmasAfroLink.API.csproj", "."]
RUN dotnet restore "AdmasAfroLink.API.csproj"

# Copy all source code
COPY . .
WORKDIR "/src"

# Build the application
RUN dotnet build "AdmasAfroLink.API.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "AdmasAfroLink.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage - runtime image
FROM base AS final
WORKDIR /app

# Create directory for uploads
RUN mkdir -p /app/wwwroot/uploads/profile-pictures

# Copy published application
COPY --from=publish /app/publish .

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:8080

# Install curl for health checks (optional)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN addgroup --system --gid 1001 appgroup
RUN adduser --system --uid 1001 --gid 1001 appuser
RUN chown -R appuser:appgroup /app
USER appuser

ENTRYPOINT ["dotnet", "AdmasAfroLink.API.dll"]
