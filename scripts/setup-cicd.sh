#!/bin/bash

# CI/CD Setup Script for Task Manager
# This script helps you set up GitHub Actions for automatic deployment

echo "🚀 Setting up CI/CD Pipeline for Task Manager"
echo "=============================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository. Please run 'git init' first."
    exit 1
fi

# Check if GitHub remote exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "❌ Error: No GitHub remote found. Please add your GitHub repository:"
    echo "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
    exit 1
fi

echo "✅ Git repository found"

# Create .github/workflows directory if it doesn't exist
mkdir -p .github/workflows

echo "📋 Setting up GitHub Secrets..."
echo ""
echo "You need to add these secrets to your GitHub repository:"
echo "1. Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
echo "2. Add these secrets:"
echo ""
echo "   EC2_HOST: 3.99.190.114"
echo "   EC2_SSH_KEY: [Your private key content]"
echo "   AWS_ACCESS_KEY_ID: [Your AWS access key]"
echo "   AWS_SECRET_ACCESS_KEY: [Your AWS secret key]"
echo ""
echo "📝 To get your AWS credentials:"
echo "   1. Go to AWS Console → IAM → Users → Your User → Security Credentials"
echo "   2. Create Access Key if you don't have one"
echo ""
echo "🔑 To get your SSH key content:"
echo "   cat task-manager-key.pem"
echo ""

# Add test scripts if they don't exist
if [ ! -f "backend/package.json" ] || ! grep -q '"test"' backend/package.json; then
    echo "📝 Adding test script to backend..."
    cd backend
    npm install --save-dev jest supertest
    cd ..
fi

if [ ! -f "frontend/package.json" ] || ! grep -q '"test"' frontend/package.json; then
    echo "📝 Adding test script to frontend..."
    cd frontend
    npm install --save-dev @testing-library/jest-dom @testing-library/react @testing-library/user-event
    cd ..
fi

echo ""
echo "🎉 CI/CD setup complete!"
echo ""
echo "Next steps:"
echo "1. Add the GitHub secrets mentioned above"
echo "2. Push your code to GitHub:"
echo "   git add ."
echo "   git commit -m 'Add CI/CD pipeline'"
echo "   git push origin main"
echo ""
echo "3. Watch your deployment at:"
echo "   https://github.com/YOUR_USERNAME/YOUR_REPO/actions"
echo ""
echo "✨ Your app will automatically deploy when you push to main branch!"
