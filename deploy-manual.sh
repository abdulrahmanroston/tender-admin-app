#!/bin/bash

##############################################################################
# Manual Deployment Script
# 
# Use this script to manually deploy updates without webhook.
# Useful for testing or when webhook is not available.
##############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Manual Deployment Started${NC}"
echo

# Get repository directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${REPO_DIR}"

# Check if in git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1:${NC} Fetching latest changes..."
git fetch origin main

echo -e "${YELLOW}Step 2:${NC} Checking for updates..."
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo -e "${GREEN}✓ Already up to date!${NC}"
    echo "No deployment needed."
    exit 0
fi

echo -e "${YELLOW}Step 3:${NC} Changes detected, deploying..."
echo

# Show what will be updated
echo "Changes to be deployed:"
git log --oneline "$LOCAL".."$REMOTE" | head -5
echo

# Confirm deployment
read -p "Continue with deployment? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Run deployment script
echo -e "${YELLOW}Step 4:${NC} Executing deployment..."
./deploy.sh

echo
echo -e "${GREEN}✓ Manual deployment completed!${NC}"
echo
echo "View deployment log: tail -f deploy.log"
