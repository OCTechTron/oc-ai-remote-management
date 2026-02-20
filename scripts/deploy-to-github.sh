#!/bin/bash
# Deploy OC-AI Remote Management to GitHub
# Run this to push updates to the repository

set -e

# Configuration
REPO_URL="git@github.com:OCTechTron/oc-ai-remote-management.git"
BRANCH="main"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "setup-remote-management.sh" ]; then
    error "Must be run from oc-ai-remote-management directory"
    exit 1
fi

# Check git status
log "Checking git repository status..."

if [ ! -d ".git" ]; then
    log "Initializing git repository..."
    git init
    git remote add origin $REPO_URL
    git branch -M main
fi

# Add all files
log "Adding files to git..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    log "No changes to commit"
    exit 0
fi

# Get commit message
echo -e "${BLUE}Enter commit message (or press Enter for default):${NC}"
read -r commit_message

if [ -z "$commit_message" ]; then
    commit_message="Update remote management system - $(date '+%Y-%m-%d %H:%M')"
fi

# Commit changes
log "Committing changes..."
git commit -m "$commit_message"

# Push to GitHub
log "Pushing to GitHub repository..."
git push origin $BRANCH

log "Successfully deployed to GitHub!"
log "One-line install command:"
echo -e "${BLUE}curl -fsSL https://raw.githubusercontent.com/OCTechTron/oc-ai-remote-management/main/setup-remote-management.sh | bash${NC}"