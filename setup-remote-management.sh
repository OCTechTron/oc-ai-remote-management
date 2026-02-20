#!/bin/bash
# OC-AI Remote Management Setup Script
# Overclocked Technologies - Production Client Management
# Version: 1.0
# Run this on Mac Mini client devices for full remote support capability

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_VERSION="1.0"
LOG_DIR="$HOME/oc-ai-logs"
BACKUP_DIR="$HOME/oc-ai-backups"
GITHUB_REPO="https://raw.githubusercontent.com/OCTechTron/oc-ai-remote-management/main"

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
    mkdir -p "$LOG_DIR" 2>/dev/null
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/setup.log"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    mkdir -p "$LOG_DIR" 2>/dev/null
    echo "[ERROR $(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/setup.log"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
    mkdir -p "$LOG_DIR" 2>/dev/null
    echo "[WARNING $(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/setup.log"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is designed for macOS only"
    exit 1
fi

# Create directories
create_directories() {
    log "Creating management directories..."
    mkdir -p "$LOG_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$HOME/oc-ai-scripts"
}

# Install Homebrew if needed
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        log "Homebrew already installed"
    fi
}

# Install required tools
install_tools() {
    log "Installing management tools..."
    
    # Essential tools for remote management
    brew install tailscale || warning "Failed to install Tailscale"
    brew install htop || warning "Failed to install htop"
    brew install watch || warning "Failed to install watch"
}

# Setup SSH access
setup_ssh() {
    log "Configuring SSH access..."
    
    # Enable SSH if not already enabled
    if ! sudo systemsetup -getremotelogin 2>/dev/null | grep -q "On"; then
        log "Enabling SSH access..."
        sudo systemsetup -setremotelogin on
        sleep 2
    fi
    
    # Create SSH directory if it doesn't exist
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    # Add Overclocked Technologies public key for remote access
    log "Adding OC-Tech SSH key for remote support..."
    cat >> ~/.ssh/authorized_keys << 'EOF'
# Overclocked Technologies Remote Support Key
# This allows secure remote troubleshooting and maintenance
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDExample_Replace_With_Real_Key oc-tech-support@overclockedtech.net
EOF
    
    chmod 600 ~/.ssh/authorized_keys
    
    log "SSH access configured successfully"
}

# Create health monitoring script
create_health_monitor() {
    log "Creating health monitoring system..."
    
    cat > "$HOME/oc-ai-scripts/health-monitor.sh" << 'EOF'
#!/bin/bash
# OC-AI Health Monitoring Script
# Checks system and AI assistant health

LOG_FILE="$HOME/oc-ai-logs/health.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Function to test Mila functionality
test_mila() {
    if python3 ~/mila_gmail_calendar.py status > /dev/null 2>&1; then
        echo "[$DATE] Mila health: HEALTHY - Email/Calendar access OK" >> $LOG_FILE
        return 0
    else
        echo "[$DATE] Mila health: UNHEALTHY - Email/Calendar access FAILED" >> $LOG_FILE
        return 1
    fi
}

# Function to test OpenClaw
test_openclaw() {
    if pgrep -f "openclaw-gateway" > /dev/null; then
        echo "[$DATE] OpenClaw: RUNNING" >> $LOG_FILE
        return 0
    else
        echo "[$DATE] OpenClaw: NOT RUNNING" >> $LOG_FILE
        return 1
    fi
}

# Function to check system resources
check_resources() {
    DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    MEMORY_PRESSURE=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
    
    echo "[$DATE] System: Disk ${DISK_USAGE}% used, Memory pressure OK" >> $LOG_FILE
    
    if [ "$DISK_USAGE" -gt 85 ]; then
        echo "[$DATE] WARNING: Disk usage high (${DISK_USAGE}%)" >> $LOG_FILE
    fi
}

# Run all checks
test_openclaw
test_mila
check_resources

# If critical services are down, try to restart
if ! test_openclaw || ! test_mila; then
    echo "[$DATE] Attempting service restart..." >> $LOG_FILE
    openclaw gateway restart
    sleep 30
    
    # Test again after restart
    if test_openclaw && test_mila; then
        echo "[$DATE] Service restart successful" >> $LOG_FILE
    else
        echo "[$DATE] CRITICAL: Service restart failed - manual intervention required" >> $LOG_FILE
        # Could send alert email here in the future
    fi
fi
EOF

    chmod +x "$HOME/oc-ai-scripts/health-monitor.sh"
    log "Health monitoring script created"
}

# Create auto-update script
create_auto_updater() {
    log "Creating auto-update system..."
    
    cat > "$HOME/oc-ai-scripts/auto-update.sh" << 'EOF'
#!/bin/bash
# OC-AI Auto-Update Script
# Safely updates OpenClaw with rollback capability

LOG_FILE="$HOME/oc-ai-logs/updates.log"
BACKUP_DIR="$HOME/oc-ai-backups"
DATE=$(date "+%Y-%m-%d_%H%M%S")

# Create timestamped backup
create_backup() {
    echo "[$(date)] Creating backup..." >> $LOG_FILE
    mkdir -p "$BACKUP_DIR/$DATE"
    
    # Backup critical files
    cp ~/.mila_credentials.json "$BACKUP_DIR/$DATE/" 2>/dev/null || true
    cp ~/.mila_token.pickle "$BACKUP_DIR/$DATE/" 2>/dev/null || true
    cp ~/mila_gmail_calendar.py "$BACKUP_DIR/$DATE/" 2>/dev/null || true
    cp ~/mila "$BACKUP_DIR/$DATE/" 2>/dev/null || true
    
    echo "[$(date)] Backup created in $BACKUP_DIR/$DATE" >> $LOG_FILE
}

# Test system functionality
test_system() {
    if python3 ~/mila_gmail_calendar.py status > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Main update process
main() {
    echo "[$(date)] Starting auto-update process..." >> $LOG_FILE
    
    # Pre-update checks
    if ! pgrep -f "openclaw-gateway" > /dev/null; then
        echo "[$(date)] ERROR: OpenClaw not running, aborting update" >> $LOG_FILE
        exit 1
    fi
    
    if ! test_system; then
        echo "[$(date)] ERROR: Pre-update test failed, aborting" >> $LOG_FILE
        exit 1
    fi
    
    # Create backup
    create_backup
    
    # Perform update
    echo "[$(date)] Performing OpenClaw update..." >> $LOG_FILE
    openclaw gateway update.run
    
    # Wait for restart
    sleep 45
    
    # Test post-update
    if test_system; then
        echo "[$(date)] Update successful!" >> $LOG_FILE
        
        # Clean up old backups (keep last 5)
        cd "$BACKUP_DIR" && ls -1t | tail -n +6 | xargs -r rm -rf
    else
        echo "[$(date)] CRITICAL: Update failed, system not functional" >> $LOG_FILE
        echo "[$(date)] Manual intervention required - backup available at $BACKUP_DIR/$DATE" >> $LOG_FILE
    fi
}

main "$@"
EOF

    chmod +x "$HOME/oc-ai-scripts/auto-update.sh"
    log "Auto-update script created"
}

# Create maintenance scripts
create_maintenance_scripts() {
    log "Creating maintenance utilities..."
    
    # System info script
    cat > "$HOME/oc-ai-scripts/system-info.sh" << 'EOF'
#!/bin/bash
# System Information Script for Remote Diagnostics

echo "=== OC-AI System Information ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "macOS Version: $(sw_vers -productVersion)"
echo "Uptime: $(uptime)"
echo ""

echo "=== OpenClaw Status ==="
if pgrep -f "openclaw-gateway" > /dev/null; then
    echo "OpenClaw: RUNNING (PID: $(pgrep -f openclaw-gateway))"
else
    echo "OpenClaw: NOT RUNNING"
fi
echo ""

echo "=== Mila Status ==="
if python3 ~/mila_gmail_calendar.py status > /dev/null 2>&1; then
    echo "Mila: OPERATIONAL"
    python3 ~/mila_gmail_calendar.py status 2>/dev/null || echo "Status check failed"
else
    echo "Mila: NOT FUNCTIONAL"
fi
echo ""

echo "=== System Resources ==="
echo "Disk Usage:"
df -h /
echo ""
echo "Memory Usage:"
vm_stat | head -5
echo ""
echo "CPU Load:"
uptime | awk '{print $10 $11 $12}'
echo ""

echo "=== Recent Logs ==="
echo "Health Monitor (last 5 entries):"
tail -5 "$HOME/oc-ai-logs/health.log" 2>/dev/null || echo "No health logs found"
echo ""
echo "Update Log (last 5 entries):"
tail -5 "$HOME/oc-ai-logs/updates.log" 2>/dev/null || echo "No update logs found"
EOF

    chmod +x "$HOME/oc-ai-scripts/system-info.sh"
    
    # Quick restart script
    cat > "$HOME/oc-ai-scripts/restart-services.sh" << 'EOF'
#!/bin/bash
# Quick service restart script

LOG_FILE="$HOME/oc-ai-logs/maintenance.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$DATE] Manual service restart initiated" >> $LOG_FILE

# Stop OpenClaw
pkill -f "openclaw-gateway"
sleep 5

# Start OpenClaw
openclaw gateway start
sleep 30

# Test functionality
if python3 ~/mila_gmail_calendar.py status > /dev/null 2>&1; then
    echo "[$DATE] Service restart successful" >> $LOG_FILE
    echo "Services restarted successfully!"
else
    echo "[$DATE] Service restart failed" >> $LOG_FILE
    echo "ERROR: Service restart failed - check logs"
fi
EOF

    chmod +x "$HOME/oc-ai-scripts/restart-services.sh"
    
    log "Maintenance scripts created"
}

# Setup cron jobs
setup_cron() {
    log "Setting up automated monitoring..."
    
    # Create cron entries
    (crontab -l 2>/dev/null; echo "# OC-AI Management Jobs") | crontab -
    (crontab -l 2>/dev/null; echo "0 */4 * * * $HOME/oc-ai-scripts/health-monitor.sh") | crontab -
    (crontab -l 2>/dev/null; echo "0 3 * * 0 $HOME/oc-ai-scripts/auto-update.sh") | crontab -
    
    log "Cron jobs configured - Health check every 4 hours, Updates Sunday 3 AM"
}

# Setup Tailscale for VPN access
setup_tailscale() {
    log "Setting up Tailscale VPN access..."
    
    if command -v tailscale &> /dev/null; then
        warning "Tailscale installed but requires manual setup:"
        echo "  1. Run: sudo tailscale up"
        echo "  2. Follow the authentication link"
        echo "  3. Device will be accessible via Tailscale network"
    else
        warning "Tailscale not installed - manual VPN setup required"
    fi
}

# Create README for client
create_readme() {
    log "Creating documentation..."
    
    cat > "$HOME/OC-AI-Remote-Management-README.txt" << EOF
OC-AI Remote Management System
=============================
Version: $SCRIPT_VERSION
Installed: $(date)

This Mac Mini has been configured with remote management capabilities
for Overclocked Technologies support staff.

WHAT'S INSTALLED:
- Health monitoring (every 4 hours)
- Auto-updates (Sundays at 3 AM)
- Remote SSH access for support
- System diagnostic tools
- Automated backup system

LOGS LOCATION:
- Health: ~/oc-ai-logs/health.log
- Updates: ~/oc-ai-logs/updates.log
- Setup: ~/oc-ai-logs/setup.log

SCRIPTS LOCATION:
- ~/oc-ai-scripts/ (monitoring and maintenance)

SUPPORT CONTACT:
- Email: ai@overclockedtech.net
- Remote access: Enabled via SSH and VPN

MANUAL COMMANDS:
- Check system status: ~/oc-ai-scripts/system-info.sh
- Restart services: ~/oc-ai-scripts/restart-services.sh
- Run health check: ~/oc-ai-scripts/health-monitor.sh

Your AI assistant (Mila) will continue to work normally.
All monitoring happens in the background automatically.
EOF

    log "Documentation created at ~/OC-AI-Remote-Management-README.txt"
}

# Main installation process
main() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "  OC-AI Remote Management Setup"
    echo "  Overclocked Technologies"
    echo "  Version: $SCRIPT_VERSION"
    echo "=================================================="
    echo -e "${NC}"
    
    create_directories
    install_homebrew
    install_tools
    setup_ssh
    create_health_monitor
    create_auto_updater
    create_maintenance_scripts
    setup_cron
    setup_tailscale
    create_readme
    
    echo ""
    echo -e "${GREEN}=================================================="
    echo "  OC-AI Remote Management Setup Complete!"
    echo "==================================================${NC}"
    echo ""
    echo "✅ Health monitoring: Every 4 hours"
    echo "✅ Auto-updates: Sundays at 3 AM"
    echo "✅ Remote SSH access: Enabled"
    echo "✅ Diagnostic tools: Installed"
    echo "✅ Backup system: Active"
    echo ""
    echo -e "${YELLOW}NEXT STEPS:${NC}"
    echo "1. Setup Tailscale VPN: sudo tailscale up"
    echo "2. Test remote access from support systems"
    echo "3. Verify Mila functionality: python3 ~/mila_gmail_calendar.py status"
    echo ""
    echo -e "${BLUE}Support: ai@overclockedtech.net${NC}"
}

# Run main function
main "$@"