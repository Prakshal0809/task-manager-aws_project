# AWS Infrastructure Setup Guide

## Prerequisites
- AWS Account with free tier access
- AWS CLI installed and configured
- Domain name (optional, can use AWS-generated URL)

## Step 1: Launch EC2 Instance

### Instance Configuration
- **Instance Type**: t2.micro (free tier eligible)
- **AMI**: Ubuntu Server 22.04 LTS
- **Storage**: 8GB gp3 (free tier)
- **Security Group**: Custom (ports 22, 80, 443, 5000)

### Security Group Rules
```
Type: SSH
Protocol: TCP
Port: 22
Source: Your IP

Type: HTTP
Protocol: TCP
Port: 80
Source: 0.0.0.0/0

Type: HTTPS
Protocol: TCP
Port: 443
Source: 0.0.0.0/0

Type: Custom TCP
Protocol: TCP
Port: 5000
Source: 0.0.0.0/0
```

## Step 2: Create RDS PostgreSQL Database

### Database Configuration
- **Engine**: PostgreSQL 15
- **Instance Class**: db.t3.micro (free tier)
- **Storage**: 20GB gp2 (free tier)
- **Backup**: 7 days retention
- **Multi-AZ**: No (to stay within free tier)

### Database Settings
- **DB Name**: task_manager_prod
- **Master Username**: admin
- **Master Password**: [Generate strong password]
- **VPC**: Same as EC2 instance
- **Security Group**: Allow port 5432 from EC2 security group

## Step 3: Create S3 Bucket for Frontend

### Bucket Configuration
- **Bucket Name**: task-manager-frontend-[random-suffix]
- **Region**: Same as EC2/RDS
- **Public Access**: Block all public access (initially)
- **Versioning**: Disabled
- **Encryption**: SSE-S3

## Step 4: Set up CloudFront Distribution

### Distribution Settings
- **Origin**: S3 bucket
- **Default Root Object**: index.html
- **Price Class**: Use only US, Canada and Europe
- **SSL Certificate**: Request or import certificate
- **Custom Error Pages**: 404 -> /index.html (for SPA routing)

## Step 5: Configure Route 53 (Optional)

### DNS Configuration
- **Hosted Zone**: Create for your domain
- **A Record**: Point to CloudFront distribution
- **CNAME Record**: www -> your domain

## Environment Variables Setup

### EC2 Instance Environment
```bash
NODE_ENV=production
PORT=5000
DB_HOST=[RDS_ENDPOINT]
DB_NAME=task_manager_prod
DB_USER=admin
DB_PASS=[RDS_PASSWORD]
DB_PORT=5432
JWT_SECRET=[GENERATE_SECURE_SECRET]
FRONTEND_URL=https://[YOUR_DOMAIN]
```

### Frontend Environment
```bash
REACT_APP_API_URL=https://[YOUR_DOMAIN]/api
REACT_APP_ENV=production
```

## Next Steps
1. Run the deployment scripts
2. Configure SSL certificates
3. Test the application
4. Set up monitoring and alerts
