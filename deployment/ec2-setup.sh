#!/bin/bash

# EC2 Setup Script for Task Manager Backend
# This script installs Node.js, PM2, and configures the environment

echo "🚀 Starting EC2 setup for Task Manager Backend..."

# Update system packages
echo "📦 Updating system packages..."
sudo yum update -y

# Install Node.js 18.x (LTS)
echo "📦 Installing Node.js..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install PM2 globally for process management
echo "📦 Installing PM2 process manager..."
sudo npm install -g pm2

# Install Git for code deployment
echo "📦 Installing Git..."
sudo yum install -y git

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p /var/www/task-manager
sudo chown ec2-user:ec2-user /var/www/task-manager

# Install PostgreSQL client (for running migrations)
echo "📦 Installing PostgreSQL client..."
sudo yum install -y postgresql

# Create PM2 startup script
echo "⚙️ Configuring PM2 startup..."
pm2 startup
# Note: You'll need to run the command that PM2 outputs

echo "✅ EC2 setup complete!"
echo "📋 Next steps:"
echo "1. Clone your repository to /var/www/task-manager"
echo "2. Install dependencies with npm install"
echo "3. Configure environment variables"
echo "4. Start the application with PM2"