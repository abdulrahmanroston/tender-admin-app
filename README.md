# Tender Admin App

A complete web-based application for managing tenders, warehouses, and accounts.

## 🚀 Auto-Deployment System

This repository comes with a complete auto-deployment system. Any changes pushed to GitHub will be automatically deployed to your server.

### Quick Setup (3 Steps)

**1. On Your Server:**
```bash
cd /var/www/html
git clone https://github.com/abdulrahmanroston/tender-admin-app.git
cd tender-admin-app
chmod +x setup.sh && ./setup.sh
```

The setup script will automatically:
- Set correct file permissions
- Configure Git
- Create necessary directories
- Detect server information
- Show webhook instructions

**2. On GitHub:**
- Go to [Settings → Webhooks](https://github.com/abdulrahmanroston/tender-admin-app/settings/hooks)
- Click "Add webhook"
- Configure:
  - **Payload URL**: `https://your-domain.com/tender-admin-app/deploy.php`
  - **Content type**: `application/json`
  - **Secret**: Leave empty
  - **Events**: Just the push event ✓
- Click "Add webhook"

**3. Test It:**
```bash
echo "test" >> test.txt
git add test.txt
git commit -m "Test auto-deployment"
git push
```

Check deployment log on server:
```bash
tail -f deploy.log
```

### Documentation

- [Complete Deployment Guide](DEPLOYMENT.md) - Full setup instructions
- [Quick Start Guide](QUICK-START.md) - Step-by-step for beginners

## 📋 Application Files

- `index.html` - Main dashboard
- `pos.html` - Point of Sale
- `warehouses.html` - Warehouse management
- `acc.html` - Accounts management
- `navigation.js` - Navigation system
- `navigation.css` - Navigation styles
- `manifest.json` - Progressive Web App config
- `sww.js` - Service Worker
- `icons/` - Application icons

## 🔧 Deployment System Files

- `deploy.php` - Webhook handler (receives GitHub notifications)
- `deploy.sh` - Auto-deployment script (executes git pull)
- `deploy-manual.sh` - Manual deployment with confirmation
- `setup.sh` - Automatic setup script
- `check-status.sh` - System status checker
- `deploy.log` - Deployment logs
- `.deploy_backups/` - Automatic backups directory
- `.htaccess` - Security protection

## ✨ Features

✅ **Zero-Configuration Deployment** - Works immediately after clone  
✅ **Automatic Backups** - Creates backup before each deployment  
✅ **Automatic Rollback** - Restores from backup if deployment fails  
✅ **Complete Logging** - Tracks all deployment operations  
✅ **Security Protection** - .htaccess protects sensitive files  
✅ **Multi-Server Support** - Deploy to multiple servers simultaneously  
✅ **Status Monitoring** - Check system health anytime  

## 🛠️ Available Commands

Run these commands on your server:

```bash
# One-time setup
./setup.sh

# Check system status
./check-status.sh

# Manual deployment
./deploy-manual.sh

# View deployment logs
tail -f deploy.log

# View last 50 log entries
tail -50 deploy.log

# Search for errors
grep ERROR deploy.log

# List backups
ls -lh .deploy_backups/

# Restore from backup
tar -xzf .deploy_backups/backup_YYYYMMDD_HHMMSS.tar.gz
```

## 🔍 How It Works

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│  GitHub  │ ──────> │ Webhook  │ ──────> │  Server  │
│   Push   │  POST   │deploy.php│  exec   │deploy.sh │
└──────────┘         └──────────┘         └──────────┘
                           │                     │
                           ▼                     ▼
                     Validates          Creates Backup
                     Request            Pulls Changes
                                       Updates Files
```

1. You push code to GitHub
2. GitHub sends webhook notification to `deploy.php`
3. `deploy.php` validates the request and triggers `deploy.sh`
4. `deploy.sh` creates a backup and pulls latest changes
5. Your website updates automatically!

## 🌐 Deploy to Multiple Servers

To deploy to multiple servers:

1. Clone repository on each server
2. Run `./setup.sh` on each server
3. Add a separate webhook for each server in GitHub

GitHub will notify all servers simultaneously on every push!

## 🔒 Security Features

- ✅ **Request Validation** - Verifies requests come from GitHub
- ✅ **Automatic Backups** - Safety net for every deployment
- ✅ **File Protection** - .htaccess prevents direct access to sensitive files
- ✅ **Branch Control** - Only `main` branch triggers deployment
- ✅ **Complete Logging** - All operations are logged

## 📊 Monitoring

### Check Deployment Status

```bash
./check-status.sh
```

This will show:
- File permissions status
- Git repository status
- Backup count
- Recent deployments
- System information

### View Live Logs

```bash
tail -f deploy.log
```

### Check Webhook Deliveries

Go to GitHub: Settings → Webhooks → [Your webhook] → Recent Deliveries

You should see green checkmarks ✓ for successful deployments.

## 🆘 Troubleshooting

### Issue: Files Not Updating

```bash
# Check git status
git status
git log -1

# Check deployment log
tail -20 deploy.log

# Try manual deployment
./deploy-manual.sh
```

### Issue: Permission Denied

```bash
# Fix permissions
sudo chown -R www-data:www-data /var/www/html/tender-admin-app
chmod +x deploy.sh setup.sh deploy-manual.sh check-status.sh
chmod 666 deploy.log
chmod 777 .deploy_backups
```

### Issue: Webhook Not Working

1. Check Recent Deliveries in GitHub webhook settings
2. Verify payload URL is correct and accessible
3. Test manually:
```bash
curl -X POST https://your-domain.com/tender-admin-app/deploy.php \
  -H "Content-Type: application/json" \
  -d '{"ref":"refs/heads/main"}'
```

### Issue: Git Pull Failed

```bash
# Reset to clean state
git reset --hard origin/main
git pull origin main
```

## 🎯 Quick Reference

| Task | Command |
|------|---------|
| Initial setup | `./setup.sh` |
| Check status | `./check-status.sh` |
| Manual deploy | `./deploy-manual.sh` |
| View logs | `tail -f deploy.log` |
| List backups | `ls -lh .deploy_backups/` |
| Fix permissions | `chmod +x *.sh` |

## 📖 Full Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment guide with advanced options
- **[QUICK-START.md](QUICK-START.md)** - Beginner-friendly step-by-step guide

## 💡 Tips

- Always test deployments on a staging server first
- Monitor logs after each deployment
- Keep backups for rollback capability
- Use descriptive commit messages
- Deploy during low-traffic periods

## 📞 Support

If you encounter issues:

1. Check `deploy.log` for error messages
2. Review webhook deliveries in GitHub
3. Run `./check-status.sh` for diagnostics
4. Try manual deployment with `./deploy-manual.sh`
5. Check web server error logs

## 📄 License

This project is open source and available for use.

---

**Repository**: https://github.com/abdulrahmanroston/tender-admin-app  
**Last Updated**: December 26, 2025
