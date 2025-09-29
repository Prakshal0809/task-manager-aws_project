# CI/CD Pipeline Setup Guide

## 🎯 What is CI/CD?

**CI/CD** stands for **Continuous Integration** and **Continuous Deployment**:

- **Continuous Integration (CI)**: Automatically tests your code when you push changes
- **Continuous Deployment (CD)**: Automatically deploys your app when tests pass

## 🚀 Benefits

- ✅ **Automatic deployment** when you push to GitHub
- ✅ **No more manual SSH** and file copying
- ✅ **Consistent environment** every time
- ✅ **Faster development** cycle
- ✅ **Professional workflow**

## 📋 Setup Steps

### 1. Prepare Your Repository

```bash
# Initialize git if not already done
git init

# Add your GitHub repository
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Add all files
git add .
git commit -m "Initial commit"
git push origin main
```

### 2. Set Up GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `EC2_HOST` | `3.99.190.114` | Your EC2 public IP |
| `EC2_SSH_KEY` | Content of `task-manager-key.pem` | Your SSH private key |
| `AWS_ACCESS_KEY_ID` | Your AWS access key | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | AWS credentials |

### 3. Get AWS Credentials

1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Navigate to **IAM** → **Users** → **Your User** → **Security Credentials**
3. Click **Create Access Key**
4. Copy the **Access Key ID** and **Secret Access Key**

### 4. Get SSH Key Content

```bash
# In your project directory
cat task-manager-key.pem
```

Copy the entire content (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`)

### 5. Run Setup Script

```bash
# Make the script executable
chmod +x scripts/setup-cicd.sh

# Run the setup script
./scripts/setup-cicd.sh
```

### 6. Push to GitHub

```bash
git add .
git commit -m "Add CI/CD pipeline"
git push origin main
```

## 🔄 How It Works

### When You Push Code:

1. **Tests Run**: Backend and frontend tests execute
2. **Build**: Frontend gets built for production
3. **Deploy Backend**: Code is pulled to EC2 and PM2 restarts
4. **Deploy Frontend**: Built files are uploaded to S3

### Pipeline Stages:

```mermaid
graph LR
    A[Push Code] --> B[Run Tests]
    B --> C{Tests Pass?}
    C -->|Yes| D[Deploy Backend]
    C -->|Yes| E[Deploy Frontend]
    C -->|No| F[❌ Stop Pipeline]
    D --> G[✅ Success]
    E --> G
```

## 📊 Monitoring

- **View Pipeline Status**: Go to your GitHub repo → Actions tab
- **View Logs**: Click on any workflow run to see detailed logs
- **Debug Issues**: Check the logs for any errors

## 🛠️ Customization

### Adding More Tests

**Backend Tests** (`backend/src/tests/`):
```javascript
// Add more test files
describe('Task API', () => {
  it('should create a task', async () => {
    // Test implementation
  });
});
```

**Frontend Tests** (`frontend/src/`):
```javascript
// Add more test files
test('renders task list', () => {
  // Test implementation
});
```

### Environment Variables

Add more secrets in GitHub for different environments:

| Secret | Description |
|--------|-------------|
| `STAGING_DB_URL` | Staging database URL |
| `PRODUCTION_DB_URL` | Production database URL |

### Branch Protection

Set up branch protection rules:
1. Go to Settings → Branches
2. Add rule for `main` branch
3. Require status checks to pass
4. Require pull request reviews

## 🚨 Troubleshooting

### Common Issues:

**1. SSH Connection Failed**
- Check if `EC2_HOST` secret is correct
- Verify `EC2_SSH_KEY` contains the full private key
- Ensure EC2 security group allows SSH (port 22)

**2. AWS Upload Failed**
- Verify AWS credentials are correct
- Check if S3 bucket name matches
- Ensure AWS region is correct (`ca-central-1`)

**3. Tests Failing**
- Check test files are properly written
- Verify all dependencies are installed
- Check if database connection is working

**4. Deployment Not Triggering**
- Ensure you're pushing to `main` branch
- Check if workflow file is in `.github/workflows/`
- Verify YAML syntax is correct

### Debug Commands:

```bash
# Check GitHub Actions logs
# Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/actions

# Test SSH connection manually
ssh -i task-manager-key.pem ubuntu@3.99.190.114

# Test AWS CLI
aws s3 ls s3://task-manager-frontend-prakshal
```

## 🎉 Success!

Once set up, your workflow will be:

1. **Code** → Push to GitHub
2. **Test** → Automatic testing
3. **Deploy** → Automatic deployment
4. **Live** → Your app is updated!

## 📚 Next Steps

- **Add more tests** for better coverage
- **Set up staging environment** for testing
- **Add notifications** (Slack, email) for deployment status
- **Implement rollback** strategy for failed deployments
- **Add performance monitoring**

---

**Happy Deploying! 🚀**
