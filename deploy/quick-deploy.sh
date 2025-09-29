#!/bin/bash

# Quick Deployment Script for Task Manager on AWS
# This script automates the entire deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
EC2_HOST=""
S3_BUCKET=""
CLOUDFRONT_DISTRIBUTION_ID=""
RDS_ENDPOINT=""
RDS_PASSWORD=""
DOMAIN=""

echo -e "${BLUE}🚀 Task Manager AWS Deployment Script${NC}"
echo -e "${BLUE}=====================================${NC}"

# Function to check if required tools are installed
check_prerequisites() {
    echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI not found. Please install it first.${NC}"
        exit 1
    fi
    
    # Check if AWS CLI is configured
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}❌ AWS CLI not configured. Please run 'aws configure' first.${NC}"
        exit 1
    fi
    
    # Check if required files exist
    if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
        echo -e "${RED}❌ Backend or frontend directory not found.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
}

# Function to get user input
get_user_input() {
    echo -e "${YELLOW}📝 Please provide the following information:${NC}"
    
    read -p "EC2 Public IP: " EC2_HOST
    read -p "S3 Bucket Name: " S3_BUCKET
    read -p "CloudFront Distribution ID (optional): " CLOUDFRONT_DISTRIBUTION_ID
    read -p "RDS Endpoint: " RDS_ENDPOINT
    read -s -p "RDS Password: " RDS_PASSWORD
    echo
    read -p "Domain (optional): " DOMAIN
    
    # Validate required inputs
    if [ -z "$EC2_HOST" ] || [ -z "$S3_BUCKET" ] || [ -z "$RDS_ENDPOINT" ] || [ -z "$RDS_PASSWORD" ]; then
        echo -e "${RED}❌ Missing required information. Please provide all required fields.${NC}"
        exit 1
    fi
}

# Function to generate JWT secret
generate_jwt_secret() {
    openssl rand -base64 32
}

# Function to deploy backend
deploy_backend() {
    echo -e "${YELLOW}🔧 Deploying backend...${NC}"
    
    # Generate JWT secret
    JWT_SECRET=$(generate_jwt_secret)
    
    # Create production environment file
    cat > backend/.env << EOF
NODE_ENV=production
PORT=5000
DB_HOST=$RDS_ENDPOINT
DB_NAME=task_manager_prod
DB_USER=admin
DB_PASS=$RDS_PASSWORD
DB_PORT=5432
JWT_SECRET=$JWT_SECRET
FRONTEND_URL=https://$DOMAIN
EOF
    
    # Set environment variables for deployment script
    export EC2_HOST
    export RDS_ENDPOINT
    export RDS_PASSWORD
    export JWT_SECRET
    export DOMAIN
    
    # Run backend deployment
    chmod +x deploy/deploy-backend.sh
    ./deploy/deploy-backend.sh
    
    echo -e "${GREEN}✅ Backend deployment completed${NC}"
}

# Function to deploy frontend
deploy_frontend() {
    echo -e "${YELLOW}🎨 Deploying frontend...${NC}"
    
    # Create production environment file
    cat > frontend/.env.production << EOF
REACT_APP_API_URL=https://$DOMAIN/api
REACT_APP_ENV=production
REACT_APP_VERSION=1.0.0
EOF
    
    # Set environment variables for deployment script
    export S3_BUCKET
    export CLOUDFRONT_DISTRIBUTION_ID
    
    # Run frontend deployment
    chmod +x deploy/deploy-frontend.sh
    ./deploy/deploy-frontend.sh
    
    echo -e "${GREEN}✅ Frontend deployment completed${NC}"
}

# Function to test deployment
test_deployment() {
    echo -e "${YELLOW}🧪 Testing deployment...${NC}"
    
    # Test backend health
    echo "Testing backend health..."
    if curl -f -s "http://$EC2_HOST/health" > /dev/null; then
        echo -e "${GREEN}✅ Backend health check passed${NC}"
    else
        echo -e "${RED}❌ Backend health check failed${NC}"
    fi
    
    # Test frontend
    echo "Testing frontend..."
    if curl -f -s "http://$S3_BUCKET.s3-website-us-east-1.amazonaws.com" > /dev/null; then
        echo -e "${GREEN}✅ Frontend accessible${NC}"
    else
        echo -e "${RED}❌ Frontend not accessible${NC}"
    fi
}

# Function to display deployment summary
show_summary() {
    echo -e "${BLUE}📋 Deployment Summary${NC}"
    echo -e "${BLUE}===================${NC}"
    echo "Backend URL: http://$EC2_HOST"
    echo "Frontend URL: http://$S3_BUCKET.s3-website-us-east-1.amazonaws.com"
    if [ ! -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
        echo "CloudFront URL: https://$CLOUDFRONT_DISTRIBUTION_ID.cloudfront.net"
    fi
    echo "Database: $RDS_ENDPOINT"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Configure SSL certificate for HTTPS"
    echo "2. Set up domain DNS if using custom domain"
    echo "3. Test all application features"
    echo "4. Set up monitoring and alerts"
    echo "5. Configure automated backups"
}

# Main execution
main() {
    check_prerequisites
    get_user_input
    
    echo -e "${YELLOW}🚀 Starting deployment process...${NC}"
    
    deploy_backend
    deploy_frontend
    test_deployment
    show_summary
    
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
}

# Run main function
main "$@"
