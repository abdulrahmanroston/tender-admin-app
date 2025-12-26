#!/bin/bash

##############################################################################
# Auto-Setup Script for tender-admin-app
# 
# This script automatically configures the deployment system after git clone.
# Run this once after cloning the repository.
##############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}"
echo "═══════════════════════════════════════════════════════════"
echo "  Tender Admin App - Auto-Deployment Setup"
echo "═══════════════════════════════════════════════════════════"
echo -e "${NC}"

# Get current directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${REPO_DIR}"

echo -e "${YELLOW}[1/5]${NC} Checking prerequisites..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed${NC}"
    exit 1
fi

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"

echo -e "${YELLOW}[2/5]${NC} Setting file permissions..."

# Make deploy script executable
chmod +x deploy.sh
echo -e "  ${GREEN}✓${NC} deploy.sh is executable"

# Create and set permissions for log file
touch deploy.log
chmod 666 deploy.log
echo -e "  ${GREEN}✓${NC} deploy.log created with write permissions"

# Create backup directory
mkdir -p .deploy_backups
chmod 777 .deploy_backups
echo -e "  ${GREEN}✓${NC} .deploy_backups directory created"

# Set permissions for deploy.php
chmod 644 deploy.php
echo -e "  ${GREEN}✓${NC} deploy.php permissions set"

echo -e "${YELLOW}[3/5]${NC} Configuring Git..."

# Get current git remote URL
REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")

if [ -n "${REMOTE_URL}" ]; then
    echo -e "  ${GREEN}✓${NC} Repository: ${REMOTE_URL}"
else
    echo -e "  ${YELLOW}!${NC} No remote repository configured"
fi

# Set git to store credentials (optional)
read -p "Do you want to store git credentials? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git config credential.helper store
    echo -e "  ${GREEN}✓${NC} Git credentials will be stored"
fi

echo -e "${YELLOW}[4/5]${NC} Testing deployment script..."

# Test if deployment script runs
if ./deploy.sh > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Deployment script test passed"
else
    echo -e "  ${YELLOW}!${NC} Deployment script test warning (this is normal on first run)"
fi

echo -e "${YELLOW}[5/5]${NC} Getting server information..."

# Try to detect web server document root
if [ -f "/etc/apache2/sites-available/000-default.conf" ]; then
    DOC_ROOT=$(grep -i DocumentRoot /etc/apache2/sites-available/000-default.conf | awk '{print $2}' | tr -d '"')
    echo -e "  ${GREEN}✓${NC} Detected Apache DocumentRoot: ${DOC_ROOT}"
elif [ -f "/etc/nginx/sites-available/default" ]; then
    DOC_ROOT=$(grep -i "root" /etc/nginx/sites-available/default | head -1 | awk '{print $2}' | tr -d ';')
    echo -e "  ${GREEN}✓${NC} Detected Nginx root: ${DOC_ROOT}"
fi

# Get current path
CURRENT_PATH=$(pwd)
echo -e "  Current installation path: ${CURRENT_PATH}"

# Try to get server domain/IP
if command -v hostname &> /dev/null; then
    HOSTNAME=$(hostname -f 2>/dev/null || hostname)
    echo -e "  Server hostname: ${HOSTNAME}"
fi

if command -v curl &> /dev/null; then
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unable to detect")
    echo -e "  Public IP: ${PUBLIC_IP}"
fi

echo
echo -e "${GREEN}"
echo "═══════════════════════════════════════════════════════════"
echo "  Setup Complete! ✓"
echo "═══════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${YELLOW}Next Steps:${NC}"
echo
echo "1. Configure GitHub Webhook:"
echo "   - Go to: https://github.com/abdulrahmanroston/tender-admin-app/settings/hooks"
echo "   - Click 'Add webhook'"
echo "   - Payload URL: http://YOUR-DOMAIN${CURRENT_PATH}/deploy.php"
echo "   - Content type: application/json"
echo "   - Secret: leave empty"
echo "   - Events: Just the push event"
echo
echo "2. Test deployment:"
echo "   - Make a change on GitHub"
echo "   - Push to main branch"
echo "   - Check: tail -f deploy.log"
echo
echo "3. View logs anytime:"
echo "   - Deployment log: tail -f deploy.log"
echo "   - Backups: ls -lh .deploy_backups/"
echo
echo -e "${GREEN}Happy deploying! 🚀${NC}"
echo
