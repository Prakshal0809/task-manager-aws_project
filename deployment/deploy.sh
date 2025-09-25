#!/bin/bash

# Deployment script for Task Manager Backend on EC2
# Run this script on your EC2 instance after initial setup

APP_DIR="/var/www/task-manager"
REPO_URL="https://github.com/yourusername/task-manager.git"  # Update with your repo URL

echo "🚀 Deploying Task Manager Backend..."

# Navigate to application directory
cd $APP_DIR

# Pull latest changes (if updating)
if [ -d ".git" ]; then
    echo "📥 Pulling latest changes..."
    git pull origin main
else
    echo "📥 Cloning repository..."
    git clone $REPO_URL .
fi

# Navigate to backend directory
cd backend

# Install dependencies
echo "📦 Installing dependencies..."
npm ci --only=production

# Run database migrations
echo "🗄️ Running database migrations..."
npm run db:migrate

# Restart PM2 process
echo "🔄 Restarting application..."
pm2 restart ecosystem.config.json --update-env

# Save PM2 configuration
pm2 save

echo "✅ Deployment complete!"
echo "📊 Application status:"
pm2 status