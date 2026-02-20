#!/bin/bash
# OC-AI Multi-Client Status Checker
# For support staff to check status of all deployed systems

# Configuration
CLIENT_LIST_FILE="$HOME/.oc-ai-clients.txt"
SSH_KEY="$HOME/.ssh/oc-ai-support"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create client list file if it doesn't exist
if [ ! -f "$CLIENT_LIST_FILE" ]; then
    cat > "$CLIENT_LIST_FILE" << 'EOF'
# OC-AI Client List
# Format: client_name:ip_or_hostname:username
# Example: missy-mcdonald:100.64.0.1:milaai-assistant
# Example: john-smith:js-mac-mini.local:johnai-assistant

missy-mcdonald:100.64.0.1:milaai-assistant
EOF
    echo -e "${YELLOW}Created client list at $CLIENT_LIST_FILE${NC}"
    echo -e "${YELLOW}Please edit this file to add your clients${NC}"
    exit 1
fi

log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Function to check a single client
check_client() {
    local client_name=$1
    local client_host=$2
    local client_user=$3
    
    echo ""
    echo "======================================"
    echo "Checking: $client_name ($client_host)"
    echo "======================================"
    
    # Test SSH connectivity
    if ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes "$client_user@$client_host" "echo 'SSH OK'" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ SSH Connection: OK${NC}"
        
        # Run remote status check
        ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes "$client_user@$client_host" "
            echo '--- System Info ---'
            echo 'Hostname: \$(hostname)'
            echo 'Uptime: \$(uptime | awk '{print \$3 \$4}' | sed 's/,//')'
            echo 'macOS: \$(sw_vers -productVersion)'
            echo ''
            
            echo '--- OpenClaw Status ---'
            if pgrep -f 'openclaw-gateway' > /dev/null; then
                echo '✅ OpenClaw: RUNNING'
            else
                echo '❌ OpenClaw: NOT RUNNING'
            fi
            echo ''
            
            echo '--- Mila Status ---'
            if python3 ~/mila_gmail_calendar.py status > /dev/null 2>&1; then
                echo '✅ Mila: OPERATIONAL'
                python3 ~/mila_gmail_calendar.py status 2>/dev/null | head -3
            else
                echo '❌ Mila: NOT FUNCTIONAL'
            fi
            echo ''
            
            echo '--- Recent Health Checks ---'
            if [ -f ~/oc-ai-logs/health.log ]; then
                tail -3 ~/oc-ai-logs/health.log
            else
                echo 'No health log found'
            fi
            echo ''
            
            echo '--- System Resources ---'
            echo \"Disk Usage: \$(df -h / | tail -1 | awk '{print \$5}')\"
            echo \"Load Average: \$(uptime | awk -F'load average:' '{print \$2}')\"
        "
    else
        echo -e "${RED}❌ SSH Connection: FAILED${NC}"
        warning "Cannot connect to $client_name ($client_host)"
        warning "Check network connectivity and SSH key authentication"
    fi
}

# Main function
main() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "  OC-AI Multi-Client Status Check"
    echo "  Overclocked Technologies"
    echo "=================================================="
    echo -e "${NC}"
    
    # Check if SSH key exists
    if [ ! -f "$SSH_KEY" ]; then
        error "SSH key not found: $SSH_KEY"
        info "Generate SSH key with: ssh-keygen -t rsa -b 4096 -f $SSH_KEY"
        info "Then deploy to clients with setup script"
        exit 1
    fi
    
    # Read client list and check each one
    local client_count=0
    while IFS=':' read -r client_name client_host client_user; do
        # Skip comments and empty lines
        [[ "$client_name" =~ ^#.*$ ]] && continue
        [[ -z "$client_name" ]] && continue
        
        check_client "$client_name" "$client_host" "$client_user"
        ((client_count++))
    done < "$CLIENT_LIST_FILE"
    
    echo ""
    echo -e "${GREEN}======================================"
    echo "Status check complete!"
    echo "Checked $client_count clients"
    echo "======================================${NC}"
    
    if [ $client_count -eq 0 ]; then
        warning "No clients found in $CLIENT_LIST_FILE"
        info "Edit the file to add your deployed clients"
    fi
}

# Show usage if requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Configuration:"
    echo "  Client list: $CLIENT_LIST_FILE"
    echo "  SSH key: $SSH_KEY"
    echo ""
    echo "This script checks the status of all deployed OC-AI systems."
    echo "Edit $CLIENT_LIST_FILE to configure your client list."
    exit 0
fi

# Run main function
main "$@"