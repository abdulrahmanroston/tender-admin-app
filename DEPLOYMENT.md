# Auto-Deployment Setup Guide

This guide explains how to set up automatic deployment for your tender-admin-app from GitHub to your web server.

## 📋 Prerequisites

- A web server with SSH access
- PHP 7.4 or higher
- Git installed on the server
- sudo/root access for initial setup

## 🚀 Step-by-Step Setup

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

### Step 2: Configure Secret Token

1. Generate a secure random token:

```bash
openssl rand -hex 32
```

2. Edit `deploy.php` and replace the secret token:

```bash
nano deploy.php
```

Find this line:
```php
define('SECRET_TOKEN', 'CHANGE_THIS_TO_YOUR_SECRET_TOKEN');
```

Replace `CHANGE_THIS_TO_YOUR_SECRET_TOKEN` with your generated token.

3. Save and exit (Ctrl+X, then Y, then Enter)

### Step 3: Set File Permissions

```bash
# Make deploy script executable
chmod 755 deploy.sh

# Set proper permissions for deploy.php
chmod 644 deploy.php

# Create log file with write permissions
touch deploy.log
chmod 666 deploy.log

# Ensure web server can execute git
sudo usermod -a -G www-data $USER  # Add your user to web server group
```

### Step 4: Configure Git for Web Server User

```bash
# Allow web server user to run git commands
sudo -u www-data git config --global user.email "deploy@yourserver.com"
sudo -u www-data git config --global user.name "Auto Deploy"

# Set directory as safe for git operations
git config --global --add safe.directory /var/www/html/tender-admin-app
```

### Step 5: Configure GitHub Webhook

1. Go to your GitHub repository: https://github.com/abdulrahmanroston/tender-admin-app
2. Click **Settings** → **Webhooks** → **Add webhook**
3. Configure the webhook:
   - **Payload URL**: `https://yourserver.com/tender-admin-app/deploy.php`
   - **Content type**: `application/json`
   - **Secret**: (paste the token you generated in Step 2)
   - **Which events**: Select "Just the push event"
   - **Active**: ✓ checked
4. Click **Add webhook**

### Step 6: Test the Deployment

#### Manual Test

```bash
# Test the deployment script manually
./deploy.sh

# Check the log
tail -f deploy.log
```

#### Webhook Test

1. Make a small change to your repository (e.g., edit README.md)
2. Commit and push:

```bash
git add .
git commit -m "Test auto-deployment"
git push
```

3. Check the webhook delivery:
   - Go to GitHub → Settings → Webhooks
   - Click on your webhook
   - Check "Recent Deliveries"
   - You should see a successful delivery (green checkmark)

4. Verify on server:

```bash
# Check deployment log
tail -20 deploy.log

# Verify files updated
git log -1
```

## 🔍 Troubleshooting

### Issue: Permission Denied

```bash
# Fix ownership
sudo chown -R www-data:www-data /var/www/html/tender-admin-app

# Fix permissions
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
chmod 755 deploy.sh
```

### Issue: Git Pull Fails

```bash
# Check git status
git status

# Reset to clean state
git reset --hard origin/main

# Try pull again
git pull origin main
```

### Issue: Webhook Not Triggered

1. Check webhook deliveries in GitHub
2. Verify payload URL is accessible:

```bash
curl -I https://yourserver.com/tender-admin-app/deploy.php
```

3. Check web server error logs:

```bash
sudo tail -f /var/log/apache2/error.log  # For Apache
sudo tail -f /var/log/nginx/error.log    # For Nginx
```

### Issue: Signature Verification Failed

- Ensure the secret token in `deploy.php` matches exactly with the one in GitHub webhook settings
- No extra spaces or line breaks

## 📊 Monitoring

### View Deployment Logs

```bash
# Real-time log monitoring
tail -f deploy.log

# View last 50 lines
tail -50 deploy.log

# Search for errors
grep ERROR deploy.log
```

### View Backups

```bash
# List all backups
ls -lh .deploy_backups/

# Restore from backup if needed
tar -xzf .deploy_backups/backup_YYYYMMDD_HHMMSS.tar.gz
```

## 🔒 Security Best Practices

1. **Always use HTTPS** for webhook URL
2. **Keep secret token secure** - never commit it to git
3. **Restrict deploy.php access** in web server config:

```apache
# Apache .htaccess
<Files "deploy.php">
    Order Deny,Allow
    Deny from all
    Allow from 140.82.112.0/20  # GitHub webhook IPs
    Allow from 143.55.64.0/20
    Allow from 185.199.108.0/22
    Allow from 192.30.252.0/22
</Files>
```

4. **Regular backup rotation** - Script keeps last 5 backups automatically
5. **Monitor logs regularly** for suspicious activity

## 📝 File Structure

```
tender-admin-app/
├── deploy.php              # Webhook handler (receives GitHub notifications)
├── deploy.sh               # Deployment script (executes git pull)
├── deploy.log              # Deployment logs
├── .deploy_backups/        # Automatic backups (last 5 kept)
├── DEPLOYMENT.md           # This guide
├── .github/
│   └── workflows/
│       └── validate.yml    # GitHub Actions for validation
└── [your website files]
```

## 🎯 How It Works

1. You push code to GitHub
2. GitHub sends webhook to `deploy.php`
3. `deploy.php` verifies signature and triggers `deploy.sh`
4. `deploy.sh` creates backup and pulls latest changes
5. Your website is updated automatically!

## ✅ Deployment Checklist

- [ ] Repository cloned on server
- [ ] Secret token generated and configured
- [ ] File permissions set correctly
- [ ] Git configured for web server user
- [ ] GitHub webhook created and active
- [ ] Manual deployment test successful
- [ ] Webhook test successful
- [ ] Logs are being written correctly
- [ ] Backups are being created

## 📞 Support

If you encounter issues:

1. Check deployment logs: `tail -f deploy.log`
2. Verify webhook deliveries in GitHub
3. Test manual deployment: `./deploy.sh`
4. Check web server error logs

---

**Last Updated**: December 26, 2025
**Repository**: https://github.com/abdulrahmanroston/tender-admin-app
