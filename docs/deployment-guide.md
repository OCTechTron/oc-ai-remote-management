# OC-AI Remote Management Deployment Guide

## For Support Staff: Client Device Setup

### Pre-Deployment Checklist

- [ ] Client Mac Mini has OpenClaw installed and functional
- [ ] AI assistant (Mila) is operational with email/calendar access  
- [ ] Client has provided consent for remote management installation
- [ ] Network connectivity confirmed (internet access required)
- [ ] Administrative access to Mac Mini available

### Deployment Methods

#### Method 1: One-Line Installation (Recommended)

```bash
# Run this command on the client Mac Mini
curl -fsSL https://raw.githubusercontent.com/OCTechTron/oc-ai-remote-management/main/setup-remote-management.sh | bash
```

**Advantages:**
- Fastest deployment
- Always gets latest version
- No manual file management

#### Method 2: Manual Installation

```bash
# Clone and run manually
git clone https://github.com/OCTechTron/oc-ai-remote-management.git
cd oc-ai-remote-management
chmod +x setup-remote-management.sh
./setup-remote-management.sh
```

**Advantages:**
- Full control over installation process
- Can review scripts before execution
- Works without internet during installation

### Post-Installation Steps

#### 1. Verify Installation
```bash
# Check that all scripts were created
ls -la ~/oc-ai-scripts/

# Verify health monitoring
~/oc-ai-scripts/health-monitor.sh
tail -5 ~/oc-ai-logs/health.log
```

#### 2. Setup Tailscale VPN (Recommended)
```bash
# Initialize Tailscale
sudo tailscale up

# Follow the authentication link provided
# Device will be accessible via Tailscale network
```

#### 3. Test Remote Access
```bash
# From support workstation
ssh milaai-assistant@[TAILSCALE-IP]

# Run diagnostic check
~/oc-ai-scripts/system-info.sh
```

#### 4. Client Communication
Send client the auto-generated README:
- Location: `~/OC-AI-Remote-Management-README.txt`
- Contains usage instructions and support information
- Explains what was installed and why

## For Clients: Understanding Remote Management

### What Was Installed

**Monitoring System:**
- Health checks run every 4 hours
- Tests your AI assistant functionality
- Monitors system resources (disk, memory)
- All checks run silently in background

**Update System:**
- Weekly updates on Sundays at 3 AM
- Creates backup before updating
- Tests system after updates
- Automatic rollback if problems occur

**Remote Access:**
- Secure SSH access for troubleshooting
- VPN access through Tailscale
- Only Overclocked Technologies support staff
- All access is logged and auditable

**Diagnostic Tools:**
- System information scripts
- Service restart capabilities  
- Log analysis tools
- Emergency recovery procedures

### What This Means for You

**✅ Benefits:**
- Proactive monitoring prevents issues
- Faster support response times
- Automatic updates keep system secure
- Less downtime due to early problem detection

**🔐 Security:**
- No passwords stored or transmitted
- Encrypted connections only
- Access limited to support staff
- All activity logged for transparency

**📞 Support:**
- 24/7 monitoring capability
- Remote troubleshooting available
- Faster issue resolution
- Proactive maintenance

### Controlling Remote Management

#### Disable Remote Access (if needed)
```bash
# Disable SSH access
sudo systemsetup -setremotelogin off

# Stop Tailscale
sudo tailscale down

# Remove cron jobs
crontab -r
```

#### Re-enable Remote Access
```bash
# Re-enable SSH
sudo systemsetup -setremotelogin on

# Restart Tailscale
sudo tailscale up

# Restore monitoring
(crontab -l 2>/dev/null; echo "0 */4 * * * $HOME/oc-ai-scripts/health-monitor.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 3 * * 0 $HOME/oc-ai-scripts/auto-update.sh") | crontab -
```

## Troubleshooting Installation

### Common Issues

#### 1. Script Download Fails
```bash
# Check internet connectivity
ping -c 3 google.com

# Try alternative download method
wget https://raw.githubusercontent.com/OCTechTron/oc-ai-remote-management/main/setup-remote-management.sh
chmod +x setup-remote-management.sh
./setup-remote-management.sh
```

#### 2. Permission Errors
```bash
# Ensure user has proper permissions
whoami  # Should not be root
ls -la ~  # Should show user owns home directory

# Fix permissions if needed
sudo chown -R $(whoami) ~/oc-ai-*
```

#### 3. Homebrew Installation Fails
```bash
# Manual Homebrew installation
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (for Apple Silicon Macs)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

#### 4. SSH Access Not Working
```bash
# Check SSH service status
sudo systemsetup -getremotelogin

# Check SSH configuration
sudo launchctl list | grep ssh

# Restart SSH service
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
sudo launchctl load /System/Library/LaunchDaemons/ssh.plist
```

#### 5. Mila Health Check Fails
```bash
# Test Mila manually
python3 ~/mila_gmail_calendar.py status

# Check if credentials are intact
ls -la ~/.mila_credentials.json ~/.mila_token.pickle

# Restore from backup if needed
cp ~/oc-ai-backups/[LATEST]/*.json ~/.mila_credentials.json
cp ~/oc-ai-backups/[LATEST]/*.pickle ~/.mila_token.pickle
```

### Log Analysis

#### Check Installation Logs
```bash
# View setup log
cat ~/oc-ai-logs/setup.log

# Check for errors
grep -i error ~/oc-ai-logs/setup.log
```

#### Monitor System Health
```bash
# View recent health checks
tail -20 ~/oc-ai-logs/health.log

# Watch health checks in real-time
tail -f ~/oc-ai-logs/health.log
```

#### Check Update History
```bash
# View update attempts
cat ~/oc-ai-logs/updates.log

# Check for failed updates
grep -i failed ~/oc-ai-logs/updates.log
```

## Security Considerations

### Access Control
- Remote access uses SSH key authentication only
- No password-based access enabled
- VPN access through Tailscale provides additional security layer
- All remote sessions are logged

### Data Protection  
- No client data is transmitted off-device
- Only system metrics and logs are monitored
- Backups remain on client device
- All communications are encrypted

### Monitoring Transparency
- All monitoring activity is logged locally
- Client can review all logs at any time
- Support access can be disabled by client
- No hidden or secret monitoring

### Update Security
- Updates only come from official OpenClaw sources
- Pre-update backups protect against failures
- Client can disable automatic updates if desired
- All updates are logged with timestamps

---

**Questions or Issues?**  
Contact: ai@overclockedtech.net