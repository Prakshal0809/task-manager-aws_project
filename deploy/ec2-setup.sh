#!/bin/bash

# EC2 Instance Setup Script for Task Manager Backend
# Run this script on your EC2 instance after launching

set -e

echo "🚀 Starting EC2 setup for Task Manager..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Node.js 18
echo "📦 Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
echo "📦 Installing PM2..."
sudo npm install -g pm2

# Install Nginx
echo "📦 Installing Nginx..."
sudo apt install -y nginx

# Install Certbot for SSL
echo "📦 Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p /var/www/task-manager
sudo chown -R $USER:$USER /var/www/task-manager

# Create PM2 ecosystem file
echo "📝 Creating PM2 ecosystem file..."
cat > /var/www/task-manager/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'task-manager-backend',
    script: 'src/server.js',
    cwd: '/var/www/task-manager',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 5000
    },
    error_file: '/var/log/pm2/task-manager-error.log',
    out_file: '/var/log/pm2/task-manager-out.log',
    log_file: '/var/log/pm2/task-manager-combined.log',
    time: true
  }]
};
EOF

# Create Nginx configuration
echo "📝 Creating Nginx configuration..."
sudo tee /etc/nginx/sites-available/task-manager << 'EOF'
server {
    listen 80;
    server_name _;

    # Backend API
    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Frontend (will be served by CloudFront)
    location / {
        return 301 https://[YOUR_CLOUDFRONT_DOMAIN]$request_uri;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/task-manager /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Start and enable services
echo "🔄 Starting services..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Create log directory for PM2
sudo mkdir -p /var/log/pm2
sudo chown -R $USER:$USER /var/log/pm2

# Create environment file template
echo "📝 Creating environment file template..."
cat > /var/www/task-manager/.env.template << 'EOF'
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

echo "✅ EC2 setup completed!"
echo "📋 Next steps:"
echo "1. Copy your application files to /var/www/task-manager"
echo "2. Configure .env file with your database credentials"
echo "3. Run 'npm install' in the application directory"
echo "4. Run 'npm run db:migrate' to set up the database"
echo "5. Start the application with 'pm2 start ecosystem.config.js'"
echo "6. Configure SSL with 'sudo certbot --nginx'"
