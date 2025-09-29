#!/bin/bash

# Frontend Deployment Script
# Deploys React app to S3 and configures CloudFront

set -e

# Configuration
S3_BUCKET=""
CLOUDFRONT_DISTRIBUTION_ID=""
AWS_REGION="us-east-1"
LOCAL_FRONTEND_DIR="./frontend"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting frontend deployment...${NC}"

# Check if S3_BUCKET is provided
if [ -z "$S3_BUCKET" ]; then
    echo -e "${RED}❌ Please set S3_BUCKET environment variable${NC}"
    echo "Usage: S3_BUCKET=your-bucket-name ./deploy-frontend.sh"
    exit 1
fi

# Check if frontend directory exists
if [ ! -d "$LOCAL_FRONTEND_DIR" ]; then
    echo -e "${RED}❌ Frontend directory not found: $LOCAL_FRONTEND_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Building React application...${NC}"

# Navigate to frontend directory
cd "$LOCAL_FRONTEND_DIR"

# Install dependencies
npm install

# Create production environment file
cat > .env.production << 'EOF'
REACT_APP_API_URL=https://[YOUR_DOMAIN]/api
REACT_APP_ENV=production
EOF

# Build the application
npm run build

# Check if build was successful
if [ ! -d "build" ]; then
    echo -e "${RED}❌ Build failed - build directory not found${NC}"
    exit 1
fi

echo -e "${YELLOW}📤 Uploading to S3...${NC}"

# Upload to S3
aws s3 sync build/ s3://$S3_BUCKET --delete

# Set proper content types
aws s3 cp s3://$S3_BUCKET/index.html s3://$S3_BUCKET/index.html --content-type "text/html" --cache-control "no-cache"
aws s3 cp s3://$S3_BUCKET/static/css/ s3://$S3_BUCKET/static/css/ --recursive --content-type "text/css" --cache-control "public, max-age=31536000"
aws s3 cp s3://$S3_BUCKET/static/js/ s3://$S3_BUCKET/static/js/ --recursive --content-type "application/javascript" --cache-control "public, max-age=31536000"

# Set bucket policy for public read access
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$S3_BUCKET/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy --bucket $S3_BUCKET --policy file://bucket-policy.json

# Configure S3 for static website hosting
aws s3 website s3://$S3_BUCKET --index-document index.html --error-document index.html

echo -e "${YELLOW}🔄 Invalidating CloudFront cache...${NC}"

# Invalidate CloudFront cache if distribution ID is provided
if [ ! -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"
    echo -e "${GREEN}✅ CloudFront cache invalidated${NC}"
fi

# Cleanup
rm -f bucket-policy.json

echo -e "${GREEN}✅ Frontend deployment completed successfully!${NC}"
echo -e "${YELLOW}📋 Deployment details:${NC}"
echo "S3 Bucket: $S3_BUCKET"
echo "Website URL: http://$S3_BUCKET.s3-website-$AWS_REGION.amazonaws.com"
if [ ! -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo "CloudFront URL: https://$CLOUDFRONT_DISTRIBUTION_ID.cloudfront.net"
fi
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Update your domain DNS to point to CloudFront distribution"
echo "2. Configure SSL certificate for HTTPS"
echo "3. Test the application"
