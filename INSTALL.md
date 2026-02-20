# Installation Instructions

## For Support Staff: Setting Up the GitHub Repository

### Initial Repository Setup

1. **Create GitHub Repository**
   ```bash
   # Create new repository on GitHub: OCTechTron/oc-ai-remote-management
   # Set as public repository for easy client access
   ```

2. **Deploy Local Files to GitHub**
   ```bash
   cd /path/to/oc-ai-remote-management
   chmod +x scripts/deploy-to-github.sh
   ./scripts/deploy-to-github.sh
   ```

3. **Verify Deployment**
   ```bash
   # Test the one-line installer
   curl -fsSL https://raw.githubusercontent.com/OCTechTron/oc-ai-remote-management/main/setup-remote-management.sh
   ```

### Setting Up Multi-Client Monitoring

1. **Generate SSH Key for Client Access**
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/oc-ai-support
   chmod 600 ~/.ssh/oc-ai-support*
   ```

2. **Update Setup Script with Real SSH Key**
   ```bash
   # Edit setup-remote-management.sh
   # Replace the example SSH key with your real public key
   nano setup-remote-management.sh
   # Look for the "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDExample" line
   ```

3. **Configure Client List**
   ```bash
   # After deploying to clients, update your client list
   nano ~/.oc-ai-clients.txt
   # Add each client: name:ip:username
   ```

## For Clients: Installation Methods

### Method 1: One-Line Installation (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/OCTechTron/oc-ai-remote-management/main/setup-remote-management.sh | bash
```

### Method 2: Manual Installation
```bash
git clone https://github.com/OCTechTron/oc-ai-remote-management.git
cd oc-ai-remote-management
chmod +x setup-remote-management.sh
./setup-remote-management.sh
```

### Method 3: Direct Download
```bash
wget https://raw.githubusercontent.com/OCTechTron/oc-ai-remote-management/main/setup-remote-management.sh
chmod +x setup-remote-management.sh
./setup-remote-management.sh
```

## Post-Installation Verification

### On Client Device
```bash
# Check installation
ls -la ~/oc-ai-scripts/
ls -la ~/oc-ai-logs/

# Test health monitoring
~/oc-ai-scripts/health-monitor.sh
tail -5 ~/oc-ai-logs/health.log

# Verify cron jobs
crontab -l | grep oc-ai
```

### From Support Workstation
```bash
# Test SSH access
ssh -i ~/.ssh/oc-ai-support milaai-assistant@[CLIENT-IP]

# Run diagnostic
~/oc-ai-scripts/system-info.sh

# Check all clients
chmod +x scripts/check-all-clients.sh
./scripts/check-all-clients.sh
```

## Updating the Repository

### Adding New Features
```bash
# Make changes to scripts or documentation
nano setup-remote-management.sh

# Deploy updates
./scripts/deploy-to-github.sh
```

### Deploying to Existing Clients
```bash
# Clients will auto-update, or manually trigger:
ssh -i ~/.ssh/oc-ai-support milaai-assistant@[CLIENT-IP]
curl -fsSL https://raw.githubusercontent.com/OCTechTron/oc-ai-remote-management/main/setup-remote-management.sh | bash
```

## Security Considerations

### SSH Key Management
- Generate unique SSH keys for support team
- Rotate keys periodically (quarterly recommended)
- Use strong passphrases on private keys
- Store keys securely (password manager or secure vault)

### Repository Security
- Review all code before deploying to main branch
- Use signed commits for sensitive changes
- Consider private repository for sensitive configurations
- Monitor repository access logs

### Client Privacy
- Only collect necessary operational data
- Document all data collection in client agreements
- Provide opt-out mechanisms for monitoring
- Regular security audits of deployed systems

---

**Questions?** Contact ai@overclockedtech.net