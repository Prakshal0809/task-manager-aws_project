#!/bin/bash

# Backend Deployment Script
# Run this script from your local machine to deploy to EC2

set -e

# Configuration
EC2_HOST=""
EC2_USER="ubuntu"
APP_DIR="/var/www/task-manager"
LOCAL_BACKEND_DIR="./backend"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting backend deployment...${NC}"

# Check if EC2_HOST is provided
if [ -z "$EC2_HOST" ]; then
    echo -e "${RED}❌ Please set EC2_HOST environment variable${NC}"
    echo "Usage: EC2_HOST=your-ec2-ip ./deploy-backend.sh"
    exit 1
fi

# Check if backend directory exists
if [ ! -d "$LOCAL_BACKEND_DIR" ]; then
    echo -e "${RED}❌ Backend directory not found: $LOCAL_BACKEND_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Creating deployment package...${NC}"

# Create temporary deployment directory
TEMP_DIR=$(mktemp -d)
DEPLOY_DIR="$TEMP_DIR/task-manager-backend"

# Copy backend files
cp -r "$LOCAL_BACKEND_DIR" "$DEPLOY_DIR"

# Remove unnecessary files
cd "$DEPLOY_DIR"
rm -rf node_modules
rm -rf .git
rm -f .env
rm -f .env.local
rm -f .env.development

# Create production package.json
cat > package.json << 'EOF'
{
  "name": "task-manager-backend",
  "version": "1.0.0",
  "description": "Task Manager backend API with Express.js and PostgreSQL",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "db:migrate": "npx sequelize-cli db:migrate",
    "db:seed": "npx sequelize-cli db:seed:all"
  },
  "keywords": ["task-manager", "express", "postgresql", "jwt"],
  "author": "Your Name",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "sequelize": "^6.35.0",
    "pg": "^8.11.3",
    "pg-hstore": "^2.3.4",
    "bcrypt": "^5.1.1",
    "jsonwebtoken": "^9.0.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "helmet": "^7.1.0",
    "express-rate-limit": "^7.1.5"
  }
}
EOF

# Create production environment file
cat > .env << 'EOF'
NODE_ENV=production
PORT=5000
DB_HOST=[RDS_ENDPOINT]
DB_NAME=task_manager_prod
DB_USER=admin
DB_PASS=[RDS_PASSWORD]
DB_PORT=5432
JWT_SECRET=[GENERATE_SECURE_SECRET]
FRONTEND_URL=https://[YOUR_DOMAIN]
EOF

echo -e "${YELLOW}📤 Uploading files to EC2...${NC}"

# Create deployment archive
cd "$TEMP_DIR"
tar -czf task-manager-backend.tar.gz task-manager-backend/

# Upload to EC2
scp -o StrictHostKeyChecking=no task-manager-backend.tar.gz "$EC2_USER@$EC2_HOST:/tmp/"

echo -e "${YELLOW}🔧 Setting up application on EC2...${NC}"

# Run setup commands on EC2
ssh -o StrictHostKeyChecking=no "$EC2_USER@$EC2_HOST" << 'EOF'
set -e

# Stop existing PM2 process
pm2 stop task-manager-backend 2>/dev/null || true
pm2 delete task-manager-backend 2>/dev/null || true

# Remove old application files
sudo rm -rf /var/www/task-manager/*

# Extract new files
cd /var/www/task-manager
sudo tar -xzf /tmp/task-manager-backend.tar.gz --strip-components=1

# Set permissions
sudo chown -R $USER:$USER /var/www/task-manager

# Install dependencies
npm install --production

# Run database migrations
npm run db:migrate

# Start application with PM2
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup

echo "✅ Backend deployment completed!"
echo "📋 Application is running on port 5000"
echo "🔗 Health check: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/health"
EOF

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Backend deployment completed successfully!${NC}"
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Update .env file on EC2 with your database credentials"
echo "2. Restart the application: ssh $EC2_USER@$EC2_HOST 'pm2 restart task-manager-backend'"
echo "3. Configure SSL certificate"
echo "4. Test the API endpoints"
