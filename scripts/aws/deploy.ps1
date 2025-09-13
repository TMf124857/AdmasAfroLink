# AWS ECS Deployment PowerShell Script for AdmasAfroLink
# This script deploys the application to AWS ECS with RDS PostgreSQL

param(
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1",
    
    [Parameter(Mandatory=$false)]
    [string]$ClusterName = "admasafrolink-cluster"
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting AWS deployment for AdmasAfroLink..." -ForegroundColor Green

# Configuration
$SERVICE_NAME = "admasafrolink-service"
$TASK_FAMILY = "admasafrolink-task"
$ECR_REPO = "admasafrolink-api"
$DB_INSTANCE_ID = "admasafrolink-postgres"
$VPC_NAME = "admasafrolink-vpc"

# Check AWS CLI installation
if (-not (Get-Command "aws" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ AWS CLI is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if AWS credentials are configured
try {
    $null = aws sts get-caller-identity
} catch {
    Write-Host "❌ AWS credentials not configured. Please run 'aws configure' first." -ForegroundColor Red
    exit 1
}

$ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
$ECR_URI = "$ACCOUNT_ID.dkr.ecr.$Region.amazonaws.com/$ECR_REPO"

Write-Host "📝 Using AWS Account: $ACCOUNT_ID" -ForegroundColor Yellow
Write-Host "🌍 Region: $Region" -ForegroundColor Yellow

# Create ECR repository
Write-Host "🐳 Creating ECR repository..." -ForegroundColor Yellow
try {
    aws ecr describe-repositories --repository-names $ECR_REPO --region $Region | Out-Null
} catch {
    aws ecr create-repository --repository-name $ECR_REPO --region $Region
}

# Login to ECR
Write-Host "🔐 Logging into ECR..." -ForegroundColor Yellow
$loginToken = aws ecr get-login-password --region $Region
$loginToken | docker login --username AWS --password-stdin $ECR_URI

# Build and push Docker image
Write-Host "🔨 Building and pushing Docker image..." -ForegroundColor Yellow
docker build -t $ECR_REPO .
docker tag "${ECR_REPO}:latest" "${ECR_URI}:latest"
docker push "${ECR_URI}:latest"

# Create VPC and networking
Write-Host "🌐 Creating VPC and networking..." -ForegroundColor Yellow
$VPC_ID = aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" --query 'Vpc.VpcId' --output text --region $Region

# Create Internet Gateway
$IGW_ID = aws ec2 create-internet-gateway --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$VPC_NAME-igw}]" --query 'InternetGateway.InternetGatewayId' --output text --region $Region
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID --region $Region

# Create subnets
$SUBNET1_ID = aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone "${Region}a" --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$VPC_NAME-subnet-1}]" --query 'Subnet.SubnetId' --output text --region $Region
$SUBNET2_ID = aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 --availability-zone "${Region}b" --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$VPC_NAME-subnet-2}]" --query 'Subnet.SubnetId' --output text --region $Region

# Create route table and associate subnets
$ROUTE_TABLE_ID = aws ec2 create-route-table --vpc-id $VPC_ID --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$VPC_NAME-rt}]" --query 'RouteTable.RouteTableId' --output text --region $Region
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $Region
aws ec2 associate-route-table --subnet-id $SUBNET1_ID --route-table-id $ROUTE_TABLE_ID --region $Region
aws ec2 associate-route-table --subnet-id $SUBNET2_ID --route-table-id $ROUTE_TABLE_ID --region $Region

# Create security groups
Write-Host "🔒 Creating security groups..." -ForegroundColor Yellow
$APP_SG_ID = aws ec2 create-security-group --group-name "$VPC_NAME-app-sg" --description "Security group for AdmasAfroLink app" --vpc-id $VPC_ID --query 'GroupId' --output text --region $Region
$DB_SG_ID = aws ec2 create-security-group --group-name "$VPC_NAME-db-sg" --description "Security group for AdmasAfroLink database" --vpc-id $VPC_ID --query 'GroupId' --output text --region $Region

# Configure security group rules
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $Region
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 --region $Region
aws ec2 authorize-security-group-ingress --group-id $DB_SG_ID --protocol tcp --port 5432 --source-group $APP_SG_ID --region $Region

# Create DB subnet group
Write-Host "🗄️ Creating database subnet group..." -ForegroundColor Yellow
aws rds create-db-subnet-group `
    --db-subnet-group-name "$VPC_NAME-db-subnet-group" `
    --db-subnet-group-description "Subnet group for AdmasAfroLink database" `
    --subnet-ids $SUBNET1_ID $SUBNET2_ID `
    --region $Region

# Create RDS PostgreSQL instance
Write-Host "📊 Creating RDS PostgreSQL instance..." -ForegroundColor Yellow
aws rds create-db-instance `
    --db-instance-identifier $DB_INSTANCE_ID `
    --db-instance-class db.t3.micro `
    --engine postgres `
    --engine-version 14.9 `
    --master-username admasadmin `
    --master-user-password "AdmasAfro2024!" `
    --allocated-storage 20 `
    --vpc-security-group-ids $DB_SG_ID `
    --db-subnet-group-name "$VPC_NAME-db-subnet-group" `
    --db-name admasafrolink `
    --region $Region

Write-Host "⏳ Waiting for RDS instance to be available..." -ForegroundColor Yellow
aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE_ID --region $Region

$DB_ENDPOINT = aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_ID --query 'DBInstances[0].Endpoint.Address' --output text --region $Region

# Create ECS cluster
Write-Host "⚙️ Creating ECS cluster..." -ForegroundColor Yellow
aws ecs create-cluster --cluster-name $ClusterName --region $Region

# Create execution role
Write-Host "🔑 Creating execution role..." -ForegroundColor Yellow
try {
    $EXECUTION_ROLE_ARN = aws iam get-role --role-name ecsTaskExecutionRole --query 'Role.Arn' --output text
} catch {
    $EXECUTION_ROLE_ARN = aws iam create-role `
        --role-name ecsTaskExecutionRole `
        --assume-role-policy-document '{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {"Service": "ecs-tasks.amazonaws.com"},
                    "Action": "sts:AssumeRole"
                }
            ]
        }' `
        --query 'Role.Arn' --output text
}

aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Generate JWT key
$JwtKey = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((New-Guid).ToString() + (New-Guid).ToString()))

# Create task definition
Write-Host "📋 Creating task definition..." -ForegroundColor Yellow
$taskDefinition = @{
    family = $TASK_FAMILY
    networkMode = "awsvpc"
    requiresCompatibilities = @("FARGATE")
    cpu = "256"
    memory = "512"
    executionRoleArn = $EXECUTION_ROLE_ARN
    containerDefinitions = @(
        @{
            name = "admasafrolink-api"
            image = "${ECR_URI}:latest"
            portMappings = @(
                @{
                    containerPort = 8080
                    protocol = "tcp"
                }
            )
            environment = @(
                @{name = "ASPNETCORE_ENVIRONMENT"; value = "Production"},
                @{name = "ConnectionStrings__DefaultConnection"; value = "Host=$DB_ENDPOINT;Database=admasafrolink;Username=admasadmin;Password=AdmasAfro2024!;SSL Mode=Require;"},
                @{name = "JwtSettings__Key"; value = $JwtKey},
                @{name = "JwtSettings__Issuer"; value = "https://api.admasafrolink.com"},
                @{name = "JwtSettings__Audience"; value = "https://api.admasafrolink.com"},
                @{name = "JwtSettings__ExpiryInMinutes"; value = "60"}
            )
            logConfiguration = @{
                logDriver = "awslogs"
                options = @{
                    "awslogs-group" = "/ecs/$TASK_FAMILY"
                    "awslogs-region" = $Region
                    "awslogs-stream-prefix" = "ecs"
                }
            }
        }
    )
} | ConvertTo-Json -Depth 10

$taskDefinition | Out-File -FilePath "task-definition.json" -Encoding UTF8

aws ecs register-task-definition --cli-input-json file://task-definition.json --region $Region

# Create CloudWatch log group
try {
    aws logs create-log-group --log-group-name "/ecs/$TASK_FAMILY" --region $Region
} catch {
    # Log group might already exist
}

# Create ECS service
Write-Host "🚀 Creating ECS service..." -ForegroundColor Yellow
aws ecs create-service `
    --cluster $ClusterName `
    --service-name $SERVICE_NAME `
    --task-definition $TASK_FAMILY `
    --desired-count 1 `
    --launch-type FARGATE `
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET1_ID,$SUBNET2_ID],securityGroups=[$APP_SG_ID],assignPublicIp=ENABLED}" `
    --region $Region

Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host "🌍 Your ECS cluster: $ClusterName" -ForegroundColor Cyan
Write-Host "📊 Database endpoint: $DB_ENDPOINT" -ForegroundColor Cyan
Write-Host "🔗 To view logs: aws logs tail /ecs/$TASK_FAMILY --follow --region $Region" -ForegroundColor Cyan
Write-Host "📋 Cleaning up task definition file..." -ForegroundColor Yellow
Remove-Item "task-definition.json" -Force
