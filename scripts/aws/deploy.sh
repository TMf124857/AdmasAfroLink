#!/bin/bash

# AWS ECS Deployment Script for AdmasAfroLink
# This script deploys the application to AWS ECS with RDS PostgreSQL

set -e

# Configuration
REGION="us-east-1"
CLUSTER_NAME="admasafrolink-cluster"
SERVICE_NAME="admasafrolink-service"
TASK_FAMILY="admasafrolink-task"
ECR_REPO="admasafrolink-api"
DB_INSTANCE_ID="admasafrolink-postgres"
VPC_NAME="admasafrolink-vpc"

echo "🚀 Starting AWS deployment for AdmasAfroLink..."

# Check AWS CLI installation
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO"

echo "📝 Using AWS Account: $ACCOUNT_ID"
echo "🌍 Region: $REGION"

# Create ECR repository
echo "🐳 Creating ECR repository..."
aws ecr describe-repositories --repository-names $ECR_REPO --region $REGION &> /dev/null || \
aws ecr create-repository --repository-name $ECR_REPO --region $REGION

# Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

# Build and push Docker image
echo "🔨 Building and pushing Docker image..."
docker build -t $ECR_REPO .
docker tag $ECR_REPO:latest $ECR_URI:latest
docker push $ECR_URI:latest

# Create VPC and networking
echo "🌐 Creating VPC and networking..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" --query 'Vpc.VpcId' --output text --region $REGION)

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$VPC_NAME-igw}]" --query 'InternetGateway.InternetGatewayId' --output text --region $REGION)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID --region $REGION

# Create subnets
SUBNET1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone ${REGION}a --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$VPC_NAME-subnet-1}]" --query 'Subnet.SubnetId' --output text --region $REGION)
SUBNET2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 --availability-zone ${REGION}b --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$VPC_NAME-subnet-2}]" --query 'Subnet.SubnetId' --output text --region $REGION)

# Create route table and associate subnets
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$VPC_NAME-rt}]" --query 'RouteTable.RouteTableId' --output text --region $REGION)
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $REGION
aws ec2 associate-route-table --subnet-id $SUBNET1_ID --route-table-id $ROUTE_TABLE_ID --region $REGION
aws ec2 associate-route-table --subnet-id $SUBNET2_ID --route-table-id $ROUTE_TABLE_ID --region $REGION

# Create security groups
echo "🔒 Creating security groups..."
APP_SG_ID=$(aws ec2 create-security-group --group-name "$VPC_NAME-app-sg" --description "Security group for AdmasAfroLink app" --vpc-id $VPC_ID --query 'GroupId' --output text --region $REGION)
DB_SG_ID=$(aws ec2 create-security-group --group-name "$VPC_NAME-db-sg" --description "Security group for AdmasAfroLink database" --vpc-id $VPC_ID --query 'GroupId' --output text --region $REGION)

# Configure security group rules
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $APP_SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $DB_SG_ID --protocol tcp --port 5432 --source-group $APP_SG_ID --region $REGION

# Create DB subnet group
echo "🗄️ Creating database subnet group..."
aws rds create-db-subnet-group \
    --db-subnet-group-name "$VPC_NAME-db-subnet-group" \
    --db-subnet-group-description "Subnet group for AdmasAfroLink database" \
    --subnet-ids $SUBNET1_ID $SUBNET2_ID \
    --region $REGION

# Create RDS PostgreSQL instance
echo "📊 Creating RDS PostgreSQL instance..."
aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE_ID \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 14.9 \
    --master-username admasadmin \
    --master-user-password "AdmasAfro2024!" \
    --allocated-storage 20 \
    --vpc-security-group-ids $DB_SG_ID \
    --db-subnet-group-name "$VPC_NAME-db-subnet-group" \
    --db-name admasafrolink \
    --region $REGION

echo "⏳ Waiting for RDS instance to be available..."
aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE_ID --region $REGION

DB_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_ID --query 'DBInstances[0].Endpoint.Address' --output text --region $REGION)

# Create ECS cluster
echo "⚙️ Creating ECS cluster..."
aws ecs create-cluster --cluster-name $CLUSTER_NAME --region $REGION

# Create execution role
echo "🔑 Creating execution role..."
EXECUTION_ROLE_ARN=$(aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {"Service": "ecs-tasks.amazonaws.com"},
                "Action": "sts:AssumeRole"
            }
        ]
    }' \
    --query 'Role.Arn' --output text 2>/dev/null || \
    aws iam get-role --role-name ecsTaskExecutionRole --query 'Role.Arn' --output text)

aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Create task definition
echo "📋 Creating task definition..."
cat > task-definition.json << EOF
{
    "family": "$TASK_FAMILY",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "$EXECUTION_ROLE_ARN",
    "containerDefinitions": [
        {
            "name": "admasafrolink-api",
            "image": "$ECR_URI:latest",
            "portMappings": [
                {
                    "containerPort": 8080,
                    "protocol": "tcp"
                }
            ],
            "environment": [
                {"name": "ASPNETCORE_ENVIRONMENT", "value": "Production"},
                {"name": "ConnectionStrings__DefaultConnection", "value": "Host=$DB_ENDPOINT;Database=admasafrolink;Username=admasadmin;Password=AdmasAfro2024!;SSL Mode=Require;"},
                {"name": "JwtSettings__Key", "value": "$(openssl rand -base64 32)"},
                {"name": "JwtSettings__Issuer", "value": "https://api.admasafrolink.com"},
                {"name": "JwtSettings__Audience", "value": "https://api.admasafrolink.com"},
                {"name": "JwtSettings__ExpiryInMinutes", "value": "60"}
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/$TASK_FAMILY",
                    "awslogs-region": "$REGION",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ]
}
EOF

aws ecs register-task-definition --cli-input-json file://task-definition.json --region $REGION

# Create CloudWatch log group
aws logs create-log-group --log-group-name "/ecs/$TASK_FAMILY" --region $REGION 2>/dev/null || true

# Create ECS service
echo "🚀 Creating ECS service..."
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition $TASK_FAMILY \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET1_ID,$SUBNET2_ID],securityGroups=[$APP_SG_ID],assignPublicIp=ENABLED}" \
    --region $REGION

echo "✅ Deployment completed successfully!"
echo "🌍 Your ECS cluster: $CLUSTER_NAME"
echo "📊 Database endpoint: $DB_ENDPOINT"
echo "🔗 To view logs: aws logs tail /ecs/$TASK_FAMILY --follow --region $REGION"
echo "📋 Clean up task definition file..."
rm -f task-definition.json
