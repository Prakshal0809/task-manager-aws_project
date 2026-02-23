# 🌐 Domain & SSL Setup Guide

## 🎯 Overview

This guide will help you set up a custom domain and SSL certificate for your Task Manager application.

## 🚀 Option 1: Free Domain + SSL (Recommended)

### Step 1: Get a Free Domain

1. **Go to**: [Freenom.com](https://www.freenom.com)
2. **Search for**: `yourname.tk`, `yourname.ml`, `yourname.ga`
3. **Register** a free domain (e.g., `prakshal-taskmanager.tk`)
4. **Note down** the domain name

### Step 2: Create CloudFront Distribution

1. **Go to**: AWS Console → **CloudFront**
2. **Click**: "Create Distribution"
3. **Configure**:
   ```
   Origin Domain: task-manager-frontend-prakshal.s3-website.ca-central-1.amazonaws.com
   Origin Path: (leave empty)
   Default Cache Behavior: Accept all defaults
   Price Class: Use all edge locations
   ```
4. **Click**: "Create Distribution"
5. **Wait**: 15-20 minutes for deployment
6. **Note**: The CloudFront domain (e.g., `d1234567890.cloudfront.net`)

### Step 3: Get SSL Certificate

1. **Go to**: AWS Console → **Certificate Manager**
2. **Click**: "Request a certificate"
3. **Select**: "Request a public certificate"
4. **Add domains**:
   ```
   Domain name: yourdomain.tk
   Additional names: www.yourdomain.tk
   ```
5. **Validation**: Choose "DNS validation"
6. **Click**: "Request"

### Step 4: Validate Certificate

1. **Click**: "View certificate"
2. **Copy**: CNAME record details
3. **Go to**: Your domain registrar (Freenom)
4. **Add**: CNAME record with the provided details
5. **Wait**: 5-10 minutes for validation

### Step 5: Update CloudFront with SSL

1. **Go to**: CloudFront → Your distribution
2. **Click**: "Edit"
3. **SSL Certificate**: "Custom SSL certificate"
4. **Select**: Your validated certificate
5. **Security Policy**: "TLSv1.2_2021"
6. **Click**: "Save Changes"

### Step 6: Configure Domain

1. **Go to**: Your domain registrar
2. **Add**: CNAME record
   ```
   Name: www
   Value: d1234567890.cloudfront.net
   ```
3. **Add**: A record (if supported)
   ```
   Name: @
   Value: d1234567890.cloudfront.net
   ```

## 🚀 Option 2: Professional Setup

### Step 1: Purchase Domain

1. **Go to**: [Route 53](https://console.aws.amazon.com/route53/) or any registrar
2. **Search**: Your desired domain name
3. **Purchase**: Domain (~$12-15/year)

### Step 2: Set Up Route 53 (if using AWS)

1. **Go to**: Route 53 → Hosted zones
2. **Create**: Hosted zone for your domain
3. **Update**: Name servers at your registrar

### Step 3: Follow Steps 2-6 from Option 1

## 🔧 Update CI/CD Pipeline

After setting up domain and SSL, update your CI/CD pipeline:

### Update Frontend Deployment

```yaml
- name: Deploy Frontend to S3
  run: |
    aws s3 sync frontend/build/ s3://task-manager-frontend-prakshal --delete
    echo "Frontend deployed to S3"
    echo "CloudFront will automatically update in 15-20 minutes"
```

## 🎯 Expected Results

After setup:
- **HTTPS**: `https://yourdomain.tk`
- **Professional**: Custom domain instead of S3 URL
- **Secure**: SSL certificate with green lock
- **Fast**: CloudFront CDN for global performance

## 📋 Checklist

- [ ] Domain registered
- [ ] CloudFront distribution created
- [ ] SSL certificate requested and validated
- [ ] CloudFront updated with SSL certificate
- [ ] Domain DNS records configured
- [ ] HTTPS working on custom domain

## 🚨 Troubleshooting

### Common Issues:

1. **Certificate not validating**
   - Check DNS records are correct
   - Wait 10-15 minutes for propagation

2. **CloudFront not updating**
   - Wait 15-20 minutes for deployment
   - Check origin domain is correct

3. **Domain not resolving**
   - Check DNS records
   - Wait for DNS propagation (up to 48 hours)

## 🎉 Success!

Once complete, your Task Manager will be accessible at:
- **HTTPS**: `https://yourdomain.tk`
- **Professional**: Custom domain with SSL
- **Fast**: Global CDN delivery

---

**Your Task Manager will look completely professional with HTTPS and a custom domain!** 🚀
