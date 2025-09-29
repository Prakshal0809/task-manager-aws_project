# 🚀 AWS Deployment Guide for Task Manager

This guide will walk you through deploying your Task Manager application to AWS using the free tier.

## 📋 Prerequisites

1. **AWS Account** with free tier access
2. **AWS CLI** installed and configured
3. **Domain name** (optional - can use AWS-generated URLs)
4. **SSH key pair** for EC2 access

## 🏗️ Infrastructure Setup

### Step 1: Launch EC2 Instance

1. **Go to EC2 Console** → Launch Instance
2. **Choose AMI**: Ubuntu Server 22.04 LTS
3. **Instance Type**: t2.micro (free tier)
4. **Key Pair**: Create or select existing
5. **Security Group**: Create with these rules:
   - SSH (22): Your IP
   - HTTP (80): 0.0.0.0/0
   - HTTPS (443): 0.0.0.0/0
   - Custom TCP (5000): 0.0.0.0/0
6. **Storage**: 8GB gp3 (free tier)
7. **Launch** the instance

### Step 2: Create RDS PostgreSQL Database

1. **Go to RDS Console** → Create Database
2. **Engine**: PostgreSQL 15
3. **Instance Class**: db.t3.micro (free tier)
4. **Storage**: 20GB gp2 (free tier)
5. **Database Name**: `task_manager_prod`
6. **Master Username**: `admin`
7. **Master Password**: Generate strong password
8. **VPC**: Same as EC2 instance
9. **Security Group**: Allow port 5432 from EC2 security group
10. **Backup**: 7 days retention
11. **Create** the database

### Step 3: Create S3 Bucket for Frontend

1. **Go to S3 Console** → Create Bucket
2. **Bucket Name**: `task-manager-frontend-[random-suffix]`
3. **Region**: Same as EC2/RDS
4. **Public Access**: Block all public access (initially)
5. **Versioning**: Disabled
6. **Encryption**: SSE-S3
7. **Create** the bucket

### Step 4: Set up CloudFront Distribution

1. **Go to CloudFront Console** → Create Distribution
2. **Origin**: S3 bucket (select your bucket)
3. **Default Root Object**: `index.html`
4. **Price Class**: Use only US, Canada and Europe
5. **SSL Certificate**: Request or import certificate
6. **Custom Error Pages**: 404 → `/index.html` (for SPA routing)
7. **Create** the distribution

## 🔧 Backend Deployment

### Step 1: Set up EC2 Instance

1. **SSH into your EC2 instance**:
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip
   ```

2. **Run the setup script**:
   ```bash
   # Copy the setup script to EC2
   scp -i your-key.pem deploy/ec2-setup.sh ubuntu@your-ec2-ip:/home/ubuntu/
   
   # SSH into EC2 and run setup
   ssh -i your-key.pem ubuntu@your-ec2-ip
   chmod +x ec2-setup.sh
   ./ec2-setup.sh
   ```

### Step 2: Configure Environment Variables

1. **Copy environment template**:
   ```bash
   cp /var/www/task-manager/.env.template /var/www/task-manager/.env
   ```

2. **Edit the .env file** with your actual values:
   ```bash
   nano /var/www/task-manager/.env
   ```

3. **Update these values**:
   - `DB_HOST`: Your RDS endpoint
   - `DB_PASS`: Your RDS password
   - `JWT_SECRET`: Generate a secure secret
   - `FRONTEND_URL`: Your CloudFront domain

### Step 3: Deploy Backend Code

1. **From your local machine**, run the deployment script:
   ```bash
   # Set your EC2 IP
   export EC2_HOST=your-ec2-ip
   
   # Make script executable
   chmod +x deploy/deploy-backend.sh
   
   # Run deployment
   ./deploy/deploy-backend.sh
   ```

### Step 4: Configure SSL Certificate

1. **SSH into EC2** and run:
   ```bash
   sudo certbot --nginx -d your-domain.com
   ```

2. **Update Nginx configuration** if needed:
   ```bash
   sudo nano /etc/nginx/sites-available/task-manager
   ```

## 🎨 Frontend Deployment

### Step 1: Configure Environment Variables

1. **Copy environment template**:
   ```bash
   cp frontend/env.production frontend/.env.production
   ```

2. **Edit the file** with your actual domain:
   ```bash
   nano frontend/.env.production
   ```

3. **Update**:
   - `REACT_APP_API_URL`: Your backend domain

### Step 2: Deploy to S3

1. **Set your S3 bucket name**:
   ```bash
   export S3_BUCKET=your-bucket-name
   export CLOUDFRONT_DISTRIBUTION_ID=your-distribution-id
   ```

2. **Run the deployment script**:
   ```bash
   chmod +x deploy/deploy-frontend.sh
   ./deploy/deploy-frontend.sh
   ```

## 🔍 Testing Your Deployment

### Backend Testing

1. **Health Check**:
   ```bash
   curl http://your-ec2-ip/health
   ```

2. **API Test**:
   ```bash
   curl http://your-ec2-ip/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"username":"test","email":"test@example.com","password":"password123"}'
   ```

### Frontend Testing

1. **Visit your CloudFront URL**
2. **Test user registration and login**
3. **Test task creation and management**

## 📊 Monitoring and Maintenance

### PM2 Monitoring

```bash
# Check application status
pm2 status

# View logs
pm2 logs task-manager-backend

# Restart application
pm2 restart task-manager-backend
```

### Database Monitoring

1. **RDS Console** → Monitoring
2. **Check CPU, memory, and connection metrics**
3. **Set up CloudWatch alarms** for critical metrics

### Cost Monitoring

1. **AWS Billing Console** → Cost Explorer
2. **Set up billing alerts** for $5, $10, $20
3. **Monitor free tier usage**

## 🚨 Troubleshooting

### Common Issues

1. **Database Connection Failed**:
   - Check RDS security group
   - Verify database credentials
   - Check RDS status

2. **Frontend Not Loading**:
   - Check S3 bucket policy
   - Verify CloudFront distribution
   - Check CORS settings

3. **SSL Certificate Issues**:
   - Verify domain ownership
   - Check DNS configuration
   - Renew certificate if expired

### Logs Location

- **Application Logs**: `/var/log/pm2/`
- **Nginx Logs**: `/var/log/nginx/`
- **System Logs**: `/var/log/syslog`

## 🔄 Updates and Maintenance

### Backend Updates

1. **Make changes locally**
2. **Run deployment script**:
   ```bash
   ./deploy/deploy-backend.sh
   ```

### Frontend Updates

1. **Make changes locally**
2. **Run deployment script**:
   ```bash
   ./deploy/deploy-frontend.sh
   ```

### Database Migrations

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Run migrations
cd /var/www/task-manager
npm run db:migrate
```

## 📈 Scaling Considerations

### When to Scale

- **CPU usage > 80%**
- **Memory usage > 90%**
- **Database connections > 80%**
- **Response time > 2 seconds**

### Scaling Options

1. **Upgrade EC2 instance** (t2.small, t2.medium)
2. **Add RDS read replicas**
3. **Implement Redis caching**
4. **Use Application Load Balancer**

## 🎯 Success Metrics

Your deployment is successful when:

- ✅ Backend API responds to health checks
- ✅ Frontend loads without errors
- ✅ User registration and login work
- ✅ Task CRUD operations work
- ✅ SSL certificate is valid
- ✅ All services are running
- ✅ Costs are within free tier limits

## 📞 Support

If you encounter issues:

1. **Check AWS documentation**
2. **Review application logs**
3. **Verify security group settings**
4. **Check CloudWatch metrics**
5. **Contact AWS support** (if needed)

---

**🎉 Congratulations! Your Task Manager is now deployed on AWS!**
