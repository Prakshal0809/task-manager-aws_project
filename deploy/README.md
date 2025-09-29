# 🚀 Task Manager AWS Deployment

This directory contains all the necessary files and scripts to deploy your Task Manager application to AWS using the free tier.

## 📁 Files Overview

### Deployment Scripts
- `quick-deploy.sh` - Automated deployment script
- `deploy-backend.sh` - Backend deployment script
- `deploy-frontend.sh` - Frontend deployment script
- `ec2-setup.sh` - EC2 instance setup script

### Configuration Files
- `aws-setup.md` - Infrastructure setup guide
- `DEPLOYMENT_GUIDE.md` - Comprehensive deployment guide
- `ecosystem.config.js` - PM2 configuration
- `Dockerfile` (backend/frontend) - Docker configurations
- `docker-compose.yml` - Local development setup

### Environment Templates
- `env.production` - Production environment variables
- `nginx.conf` - Nginx configuration for frontend

## 🚀 Quick Start

### Option 1: Automated Deployment (Recommended)

1. **Set up AWS infrastructure**:
   - Launch EC2 instance (t2.micro)
   - Create RDS PostgreSQL database
   - Create S3 bucket for frontend
   - Set up CloudFront distribution

2. **Run the quick deployment script**:
   ```bash
   chmod +x deploy/quick-deploy.sh
   ./deploy/quick-deploy.sh
   ```

3. **Follow the prompts** to provide:
   - EC2 public IP
   - S3 bucket name
   - RDS endpoint
   - Database password
   - Domain (optional)

### Option 2: Manual Deployment

1. **Follow the step-by-step guide**:
   ```bash
   # Read the comprehensive guide
   cat deploy/DEPLOYMENT_GUIDE.md
   ```

2. **Set up EC2 instance**:
   ```bash
   # Copy setup script to EC2
   scp deploy/ec2-setup.sh ubuntu@your-ec2-ip:/home/ubuntu/
   
   # SSH and run setup
   ssh ubuntu@your-ec2-ip
   chmod +x ec2-setup.sh
   ./ec2-setup.sh
   ```

3. **Deploy backend**:
   ```bash
   export EC2_HOST=your-ec2-ip
   ./deploy/deploy-backend.sh
   ```

4. **Deploy frontend**:
   ```bash
   export S3_BUCKET=your-bucket-name
   ./deploy/deploy-frontend.sh
   ```

## 🐳 Docker Deployment (Alternative)

If you prefer Docker deployment:

1. **Build and run locally**:
   ```bash
   docker-compose up -d
   ```

2. **Deploy to AWS ECS** (not covered in free tier):
   - Create ECS cluster
   - Push images to ECR
   - Create task definitions
   - Deploy services

## 🔧 Configuration

### Backend Configuration

The backend requires these environment variables:

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

### Frontend Configuration

The frontend requires these environment variables:

```bash
REACT_APP_API_URL=https://[YOUR_DOMAIN]/api
REACT_APP_ENV=production
REACT_APP_VERSION=1.0.0
```

## 📊 Monitoring

### PM2 Monitoring (Backend)
```bash
# Check status
pm2 status

# View logs
pm2 logs task-manager-backend

# Restart
pm2 restart task-manager-backend
```

### AWS CloudWatch
- Monitor EC2 metrics
- Monitor RDS metrics
- Set up billing alerts
- Monitor application logs

## 🔒 Security

### SSL/TLS Configuration
1. **Request SSL certificate** from AWS Certificate Manager
2. **Configure CloudFront** to use the certificate
3. **Set up HTTPS redirect** in Nginx
4. **Update CORS settings** for HTTPS

### Security Best Practices
- Use strong passwords
- Enable MFA on AWS account
- Set up VPC security groups properly
- Regular security updates
- Monitor access logs

## 💰 Cost Optimization

### Free Tier Limits
- **EC2**: 750 hours/month (t2.micro)
- **RDS**: 750 hours/month (db.t3.micro)
- **S3**: 5GB storage
- **CloudFront**: 50GB data transfer

### Cost Monitoring
- Set up billing alerts
- Monitor usage in AWS Console
- Use AWS Cost Explorer
- Review monthly bills

## 🚨 Troubleshooting

### Common Issues

1. **Database Connection Failed**:
   ```bash
   # Check RDS security group
   # Verify database credentials
   # Check RDS status
   ```

2. **Frontend Not Loading**:
   ```bash
   # Check S3 bucket policy
   # Verify CloudFront distribution
   # Check CORS settings
   ```

3. **SSL Certificate Issues**:
   ```bash
   # Verify domain ownership
   # Check DNS configuration
   # Renew certificate if expired
   ```

### Log Locations
- **Application Logs**: `/var/log/pm2/`
- **Nginx Logs**: `/var/log/nginx/`
- **System Logs**: `/var/log/syslog`

## 🔄 Updates and Maintenance

### Backend Updates
```bash
# Make changes locally
# Run deployment script
./deploy/deploy-backend.sh
```

### Frontend Updates
```bash
# Make changes locally
# Run deployment script
./deploy/deploy-frontend.sh
```

### Database Migrations
```bash
# SSH into EC2
ssh ubuntu@your-ec2-ip

# Run migrations
cd /var/www/task-manager
npm run db:migrate
```

## 📈 Scaling

### When to Scale
- CPU usage > 80%
- Memory usage > 90%
- Database connections > 80%
- Response time > 2 seconds

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

**🎉 Happy Deploying!**
