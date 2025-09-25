# AWS Deployment Guide - Task Manager

## Prerequisites
- AWS Account with Free Tier access
- AWS CLI installed and configured (optional but recommended)

## Step 1: Setup AWS RDS PostgreSQL Database

### Why RDS?
- **Managed Service**: AWS handles backups, updates, and maintenance
- **Free Tier**: 750 hours/month of db.t3.micro instance
- **High Availability**: Built-in failover and monitoring
- **Security**: VPC isolation and encryption at rest

### Instructions:

1. **Go to AWS RDS Console**
   - Navigate to: https://console.aws.amazon.com/rds/
   - Click "Create database"

2. **Choose Database Creation Method**
   - Select: "Standard create"

3. **Engine Options**
   - Engine type: PostgreSQL
   - Version: PostgreSQL 15.x (latest available)

4. **Templates**
   - Select: "Free tier" (this automatically configures for free tier limits)

5. **Settings**
   - DB instance identifier: `task-manager-db`
   - Master username: `postgres`
   - Master password: `TaskManager2024!` (or create your own secure password)

6. **Instance Configuration**
   - DB instance class: db.t3.micro (auto-selected with free tier)
   - Storage type: General Purpose SSD (gp2)
   - Allocated storage: 20 GB (free tier limit)

7. **Storage**
   - ✅ Disable storage autoscaling (to stay in free tier)

8. **Connectivity**
   - VPC: Default VPC
   - Subnet group: default
   - Public access: Yes (we'll secure with security groups)
   - VPC security group: Create new
   - Security group name: `task-manager-db-sg`

9. **Database Authentication**
   - Database authentication: Password authentication

10. **Additional Configuration**
    - Initial database name: `task_manager_db`
    - ✅ Enable automated backups (free tier includes 20GB backup storage)
    - Backup retention period: 7 days
    - ✅ Disable Enhanced monitoring (costs extra)
    - ✅ Disable Performance Insights (costs extra)

11. **Estimated Costs**
    - Should show $0.00/month with free tier

12. **Create Database**
    - Click "Create database"
    - Wait 5-10 minutes for creation

### Security Group Configuration

After RDS creation:

1. **Go to EC2 Console > Security Groups**
2. **Find the RDS security group** (`task-manager-db-sg`)
3. **Edit Inbound Rules**:
   - Type: PostgreSQL
   - Protocol: TCP
   - Port: 5432
   - Source: Custom (we'll add EC2 security group later)

### Important Notes:
- **Free Tier Limits**: 750 hours/month (can run 24/7 for ~31 days)
- **Storage**: 20GB limit, monitor usage
- **Backup**: Included in free tier
- **Multi-AZ**: Not available in free tier (that's okay for development)

## Next Steps:
After RDS is created, save the endpoint URL - you'll need it for:
- Environment variables
- Database connections
- Migration scripts

The endpoint will look like: `task-manager-db.xxxxxxxxx.us-east-1.rds.amazonaws.com`

---

## Step 2: Setup EC2 Instance for Backend

### Why EC2?
- **Full Control**: Complete server management and customization
- **Free Tier**: 750 hours/month of t2.micro instance
- **Cost Effective**: No additional load balancer costs (unlike Elastic Beanstalk)
- **Learning**: Great hands-on AWS experience

### Instructions:

1. **Go to EC2 Console**
   - Navigate to: https://console.aws.amazon.com/ec2/
   - Click "Launch Instance"

2. **Choose Name and Tags**
   - Name: `task-manager-backend`
   - Environment: `production`

3. **Application and OS Images (Amazon Machine Image)**
   - Select: **Amazon Linux 2023 AMI** (Free tier eligible)
   - Architecture: 64-bit (x86)

4. **Instance Type**
   - Select: **t2.micro** (Free tier eligible)
   - 1 vCPU, 1 GB Memory

5. **Key Pair (login)**
   - Create new key pair: `task-manager-key`
   - Key pair type: RSA
   - Private key file format: .pem
   - **Download and save the .pem file securely!**

6. **Network Settings**
   - VPC: Default VPC
   - Subnet: Default subnet
   - Auto-assign public IP: Enable
   - Create security group: **task-manager-web-sg**
   
   **Security Group Rules**:
   - SSH (22): My IP (for your access)
   - HTTP (80): Anywhere (0.0.0.0/0)
   - HTTPS (443): Anywhere (0.0.0.0/0)
   - Custom TCP (5000): Anywhere (0.0.0.0/0) - for API access

7. **Configure Storage**
   - Size: 8 GiB (Free tier limit)
   - Volume type: gp2
   - Encrypted: No (costs extra)

8. **Advanced Details**
   - Keep defaults (all free)

9. **Launch Instance**
   - Review settings
   - Click "Launch Instance"
   - Wait 2-3 minutes for initialization

### After EC2 Launch:

1. **Update RDS Security Group**
   - Go to EC2 Console > Security Groups
   - Find `task-manager-db-sg` (your RDS security group)
   - Edit Inbound Rules
   - Add new rule:
     - Type: PostgreSQL
     - Source: Security Group → `task-manager-web-sg` (your EC2 security group)
   - This allows EC2 to connect to RDS

2. **Connect to EC2 Instance**
   - Select your instance
   - Click "Connect"
   - Use "EC2 Instance Connect" (browser-based) or SSH

### Connection Methods:

**Option A: EC2 Instance Connect (Easiest)**
- Click "Connect" → "EC2 Instance Connect"
- Username: `ec2-user`
- Click "Connect"

**Option B: SSH (Traditional)**
```bash
chmod 400 task-manager-key.pem
ssh -i "task-manager-key.pem" ec2-user@YOUR-EC2-PUBLIC-IP
```

### Next Steps:
After connecting to EC2, you'll run the setup script to install Node.js, PM2, and configure the environment.