#!/bin/bash

##############################################################################
# Deployment Status Checker
# 
# Quick status check for the deployment system
##############################################################################

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "═══════════════════════════════════════════════════════════"
echo "  Deployment System Status Check"
echo "═══════════════════════════════════════════════════════════"
echo -e "${NC}"

# Check if in git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}✗ Not a git repository${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Git repository detected${NC}"

# Check deploy script
if [ -x "deploy.sh" ]; then
    echo -e "${GREEN}✓ deploy.sh is executable${NC}"
else
    echo -e "${RED}✗ deploy.sh is not executable${NC}"
    echo "  Fix: chmod +x deploy.sh"
fi

# Check deploy.php
if [ -f "deploy.php" ]; then
    echo -e "${GREEN}✓ deploy.php exists${NC}"
else
    echo -e "${RED}✗ deploy.php not found${NC}"
fi

# Check log file
if [ -f "deploy.log" ]; then
    if [ -w "deploy.log" ]; then
        echo -e "${GREEN}✓ deploy.log is writable${NC}"
        LOG_SIZE=$(du -h deploy.log | cut -f1)
        echo "  Log file size: ${LOG_SIZE}"
    else
        echo -e "${RED}✗ deploy.log is not writable${NC}"
        echo "  Fix: chmod 666 deploy.log"
    fi
else
    echo -e "${YELLOW}! deploy.log does not exist${NC}"
    echo "  It will be created on first deployment"
fi

# Check backup directory
if [ -d ".deploy_backups" ]; then
    BACKUP_COUNT=$(ls -1 .deploy_backups/*.tar.gz 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Backup directory exists${NC}"
    echo "  Number of backups: ${BACKUP_COUNT}"
else
    echo -e "${YELLOW}! Backup directory does not exist${NC}"
    echo "  Fix: mkdir -p .deploy_backups && chmod 777 .deploy_backups"
fi

# Check git status
echo
echo -e "${BLUE}Git Status:${NC}"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "  Current branch: ${CURRENT_BRANCH}"

CURRENT_COMMIT=$(git rev-parse --short HEAD)
echo "  Current commit: ${CURRENT_COMMIT}"

REMOTE_URL=$(git config --get remote.origin.url)
echo "  Remote: ${REMOTE_URL}"

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "  ${YELLOW}! Uncommitted changes detected${NC}"
else
    echo -e "  ${GREEN}✓ Working directory clean${NC}"
fi

# Check if up to date with remote
echo
echo "Checking for updates..."
git fetch origin ${CURRENT_BRANCH} 2>/dev/null

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/${CURRENT_BRANCH} 2>/dev/null || echo "$LOCAL")

if [ "$LOCAL" = "$REMOTE" ]; then
    echo -e "${GREEN}✓ Up to date with remote${NC}"
else
    echo -e "${YELLOW}! Updates available${NC}"
    echo "  Run: ./deploy-manual.sh to deploy"
fi

# Show recent deployments
if [ -f "deploy.log" ] && [ -s "deploy.log" ]; then
    echo
    echo -e "${BLUE}Recent Deployments:${NC}"
    tail -20 deploy.log | grep "\[INFO\]" | tail -5
fi

# System info
echo
echo -e "${BLUE}System Information:${NC}"
echo "  PHP version: $(php -v 2>/dev/null | head -1 | cut -d' ' -f2 || echo 'Not detected')"
echo "  Git version: $(git --version | cut -d' ' -f3)"

if command -v df &> /dev/null; then
    DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}')
    echo "  Disk usage: ${DISK_USAGE}"
fi

echo
echo -e "${GREEN}Status check complete!${NC}"
echo
