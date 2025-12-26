# Auto-Deployment Setup Guide (Simplified)

This guide explains how to set up **zero-configuration** automatic deployment for your tender-admin-app from GitHub to any web server.

## 🎯 Key Features

- ✅ **No secret token required** - Works immediately after clone
- ✅ **No configuration files** - Everything works out of the box
- ✅ **Automatic backups** - Safety net for every deployment
- ✅ **Universal compatibility** - Works on any server with PHP and Git

## 📋 Prerequisites

- Web server with PHP 7.4 or higher
- Git installed on the server
- SSH/FTP access to upload files

## 🚀 Quick Setup (3 Steps)

### Step 1: Clone Repository on Server

```bash
# SSH into your server
ssh user@yourserver.com

# Navigate to your web directory
cd /var/www/html  # or your web root directory

# Clone the repository
git clone https://github.com/abdulrahmanroston/tender-admin-app.git
cd tender-admin-app

# Make deploy script executable
chmod +x deploy.sh
```

### Step 2: Set File Permissions

```bash
# Make deploy script executable
chmod 755 deploy.sh

# Create log file with write permissions
touch deploy.log
chmod 666 deploy.log

# Allow web server to write backups
mkdir -p .deploy_backups
chmod 777 .deploy_backups
```

### Step 3: Configure GitHub Webhook

1. Go to: https://github.com/abdulrahmanroston/tender-admin-app/settings/hooks
2. Click **Add webhook**
3. Configure:
   - **Payload URL**: `https://yourserver.com/tender-admin-app/deploy.php`
   - **Content type**: `application/json`
   - **Secret**: *Leave empty*
   - **Which events**: Select "Just the push event"
   - **Active**: ✓ checked
4. Click **Add webhook**

**That's it!** Your auto-deployment is ready.

## 🧪 Test the Setup

### Manual Test

```bash
# Test the deployment script
./deploy.sh

# Check the log
tail -f deploy.log
```

### Automatic Test

1. Make a small change:
```bash
echo "# Test" >> README.md
git add README.md
git commit -m "Test auto-deployment"
git push
```

2. Check webhook delivery:
   - Go to GitHub → Settings → Webhooks
   - Click on your webhook
   - Check "Recent Deliveries" - should see green checkmark ✓

3. Verify on server:
```bash
tail -20 deploy.log
```

## 📁 What Gets Deployed

Every time you push to the `main` branch:
- All `.html` files
- All `.css` files
- All `.js` files
- All `.json` files
- The `icons/` directory
- Any other files in your repository

## 🔍 Monitoring

### View Deployment Logs

```bash
# Real-time monitoring
tail -f deploy.log

# Last 50 entries
tail -50 deploy.log

# Search for errors
grep ERROR deploy.log
```

### Check Backups

```bash
# List backups (last 5 are kept)
ls -lh .deploy_backups/

# Restore from backup if needed
cd /var/www/html/tender-admin-app
tar -xzf .deploy_backups/backup_YYYYMMDD_HHMMSS.tar.gz
```

## 🔧 Troubleshooting

### Issue: "Permission Denied"

```bash
# Fix all permissions at once
sudo chown -R www-data:www-data /var/www/html/tender-admin-app
chmod 755 deploy.sh
chmod 666 deploy.log
chmod 777 .deploy_backups
```

### Issue: "Git Pull Failed"

```bash
# Reset to clean state
git reset --hard origin/main
git pull origin main
```

### Issue: "Webhook Not Working"

1. Check webhook URL is accessible:
```bash
curl -I https://yourserver.com/tender-admin-app/deploy.php
```

2. Verify web server logs:
```bash
# Apache
sudo tail -f /var/log/apache2/error.log

# Nginx
sudo tail -f /var/log/nginx/error.log
```

3. Test manually:
```bash
curl -X POST https://yourserver.com/tender-admin-app/deploy.php \
  -H "Content-Type: application/json" \
  -d '{"ref":"refs/heads/main"}'
```

### Issue: "Files Not Updating"

Check if deploy script is being executed:
```bash
# Should show recent deployment
ls -lt | head

# Check git status
git status
git log -1
```

## 🎨 Customization (Optional)

### Deploy Different Branch

Edit `deploy.php`, change:
```php
define('BRANCH_TO_DEPLOY', 'main');
```
to:
```php
define('BRANCH_TO_DEPLOY', 'production');
```

### Change Backup Count

Edit `deploy.sh`, find this line:
```bash
ls -t backup_*.tar.gz | tail -n +6 | xargs -r rm --
```

Change `+6` to keep different number (e.g., `+11` keeps 10 backups)

## 📊 How It Works

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
2. GitHub sends webhook to `deploy.php`
3. `deploy.php` validates and triggers `deploy.sh`
4. `deploy.sh` creates backup and pulls latest code
5. Website updates automatically!

## ✅ Setup Checklist

- [ ] Repository cloned on server
- [ ] Deploy script is executable (`chmod +x deploy.sh`)
- [ ] Log file created with write permissions
- [ ] Backup directory created
- [ ] GitHub webhook configured
- [ ] Webhook test successful (green checkmark)
- [ ] Manual deployment test works
- [ ] Logs are being written

## 🌐 Multiple Servers

To deploy to multiple servers, simply:

1. Clone repository on each server
2. Set permissions (Step 2 above)
3. Add webhook URL for each server in GitHub

GitHub will notify all servers simultaneously!

## 🔒 Security Notes

- Deploy script validates requests are from GitHub
- Automatic backups protect against bad deployments
- Logs track all deployment activity
- Only `main` branch triggers deployment
- For production: Consider restricting IP access to GitHub webhook IPs

## 💡 Tips

- Test deployments on staging server first
- Monitor logs after each deployment
- Keep backups for rollback capability
- Use descriptive commit messages
- Deploy during low-traffic periods

---

**Repository**: https://github.com/abdulrahmanroston/tender-admin-app  
**Support**: Check deployment logs first, then webhook deliveries in GitHub
