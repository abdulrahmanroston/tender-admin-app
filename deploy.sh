#!/bin/bash

##############################################################################
# Auto-Deployment Script for tender-admin-app
# 
# This script pulls the latest changes from GitHub and updates the website.
# It includes error handling and rollback capabilities.
##############################################################################

set -e  # Exit on any error

# Configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRANCH="main"
LOG_FILE="${REPO_DIR}/deploy.log"
BACKUP_DIR="${REPO_DIR}/.deploy_backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    log "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    log "ERROR: $1"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
    log "INFO: $1"
}

# Function to create backup
create_backup() {
    print_info "Creating backup..."
    
    mkdir -p "${BACKUP_DIR}"
    
    BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"
    
    tar -czf "${BACKUP_PATH}" \
        --exclude='.git' \
        --exclude='.deploy_backups' \
        --exclude='deploy.log' \
        -C "${REPO_DIR}" .
    
    if [ $? -eq 0 ]; then
        print_success "Backup created: ${BACKUP_NAME}"
        
        # Keep only last 5 backups
        cd "${BACKUP_DIR}"
        ls -t backup_*.tar.gz | tail -n +6 | xargs -r rm --
        
        return 0
    else
        print_error "Backup creation failed"
        return 1
    fi
}

# Function to check if directory is a git repository
check_git_repo() {
    if [ ! -d "${REPO_DIR}/.git" ]; then
        print_error "Not a git repository. Please run: git clone https://github.com/abdulrahmanroston/tender-admin-app.git"
        exit 1
    fi
}

# Main deployment process
main() {
    print_info "========================================"
    print_info "Starting deployment process"
    print_info "========================================"
    
    # Change to repository directory
    cd "${REPO_DIR}"
    
    # Check if git repository
    check_git_repo
    
    # Create backup
    create_backup || exit 1
    
    # Reset any local changes to tracked files (FIX: Prevents deployment blocking)
    print_info "Resetting local changes to tracked files..."
    git reset --hard HEAD
    
    # Clean untracked files (optional, commented out by default)
    # git clean -fd
    
    # Fetch latest changes
    print_info "Fetching latest changes from GitHub..."
    if git fetch origin "${BRANCH}"; then
        print_success "Fetch completed"
    else
        print_error "Failed to fetch from remote"
        exit 1
    fi
    
    # Get current commit before pull
    OLD_COMMIT=$(git rev-parse HEAD)
    
    # Pull latest changes with force reset
    print_info "Pulling latest changes..."
    if git reset --hard "origin/${BRANCH}"; then
        NEW_COMMIT=$(git rev-parse HEAD)
        
        if [ "${OLD_COMMIT}" = "${NEW_COMMIT}" ]; then
            print_info "Already up to date. No changes to deploy."
        else
            print_success "Updated from ${OLD_COMMIT:0:7} to ${NEW_COMMIT:0:7}"
            
            # Show what changed
            print_info "Changes deployed:"
            git log --oneline "${OLD_COMMIT}".."${NEW_COMMIT}" | head -5
        fi
        
        # Set correct permissions
        print_info "Setting file permissions..."
        find "${REPO_DIR}" -type f -name "*.html" -exec chmod 644 {} \;
        find "${REPO_DIR}" -type f -name "*.css" -exec chmod 644 {} \;
        find "${REPO_DIR}" -type f -name "*.js" -exec chmod 644 {} \;
        find "${REPO_DIR}" -type f -name "*.json" -exec chmod 644 {} \;
        chmod 755 "${REPO_DIR}"/*.sh 2>/dev/null || true
        
        print_success "File permissions updated"
        
        print_info "========================================"
        print_success "Deployment completed successfully!"
        print_info "========================================"
        
        exit 0
    else
        print_error "Git reset failed"
        print_info "Attempting to restore from backup..."
        
        # Restore from backup if reset failed
        LATEST_BACKUP=$(ls -t "${BACKUP_DIR}"/backup_*.tar.gz 2>/dev/null | head -1)
        
        if [ -n "${LATEST_BACKUP}" ]; then
            tar -xzf "${LATEST_BACKUP}" -C "${REPO_DIR}"
            print_success "Restored from backup: $(basename "${LATEST_BACKUP}")"
        fi
        
        exit 1
    fi
}

# Run main function
main "$@"
