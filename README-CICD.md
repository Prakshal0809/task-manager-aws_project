# 🚀 CI/CD Pipeline for Task Manager

## Quick Start

### 1. Set up GitHub Secrets
Go to your GitHub repo → Settings → Secrets and variables → Actions

Add these secrets:
- `EC2_HOST`: `3.99.190.114`
- `EC2_SSH_KEY`: Content of your `task-manager-key.pem` file
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### 2. Push to GitHub
```bash
git add .
git commit -m "Add CI/CD pipeline"
git push origin main
```

### 3. Watch the Magic! ✨
- Go to your GitHub repo → Actions tab
- Watch your app automatically deploy when you push code!

## What Happens When You Push?

1. **🧪 Tests Run** - Backend and frontend tests execute
2. **🏗️ Build** - Frontend gets built for production  
3. **🚀 Deploy Backend** - Code is pulled to EC2 and PM2 restarts
4. **🌐 Deploy Frontend** - Built files are uploaded to S3

## Benefits

- ✅ **No more manual deployment**
- ✅ **Automatic testing** before deployment
- ✅ **Consistent environment** every time
- ✅ **Professional workflow**

## Files Created

- `.github/workflows/deploy.yml` - GitHub Actions workflow
- `scripts/setup-cicd.sh` - Setup script
- `docs/CI-CD-SETUP.md` - Detailed documentation
- `backend/src/tests/app.test.js` - Backend tests
- `frontend/src/App.test.js` - Frontend tests

## Need Help?

Check the detailed guide: `docs/CI-CD-SETUP.md`

---

**Happy Deploying! 🎉**
