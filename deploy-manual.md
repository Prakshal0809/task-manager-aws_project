# 🚀 Manual Deployment Guide

## Quick Deployment Steps

### 1. Update Frontend
```bash
# In your project directory
cd frontend
npm run build

# Upload to S3 (replace with your AWS CLI command)
aws s3 sync build/ s3://task-manager-frontend-prakshal --delete
```

### 2. Update Backend
```bash
# Connect to EC2
ssh -i task-manager-key.pem ubuntu@3.99.190.114

# On EC2
cd /var/www/task-manager
git pull origin main
cd backend
npm install --production
pm2 restart task-manager-backend
```

## 🔧 CI/CD Troubleshooting

The CI/CD pipeline is failing due to one of these common issues:

### 1. AWS Credentials Issue
- Check if AWS Access Key ID and Secret are correct
- Verify the IAM user has S3 permissions
- Ensure the region is correct (ca-central-1)

### 2. S3 Bucket Issue
- Verify bucket name: `task-manager-frontend-prakshal`
- Check if bucket exists and is accessible
- Ensure bucket policy allows uploads

### 3. SSH Key Issue
- Verify EC2_SSH_KEY secret contains the full private key
- Check if EC2 security group allows SSH (port 22)
- Ensure EC2 instance is running

## 🎉 Your App is Live!

**Frontend**: http://task-manager-frontend-prakshal.s3-website.ca-central-1.amazonaws.com
**Backend**: http://3.99.190.114:5000/api

## 📋 Next Steps

1. **Use manual deployment** for now
2. **Fix CI/CD issues** when you have time
3. **Your app is fully functional** and deployed!

---

**Congratulations! You have a working Task Manager application deployed on AWS!** 🎉
