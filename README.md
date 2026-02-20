# OC-AI Remote Management System

**Professional remote management and monitoring for Overclocked Technologies AI deployments**

## Overview

This repository contains the remote management infrastructure for OC-AI client devices. It enables:

- 🔄 **Automated Updates** - Weekly OpenClaw updates with rollback capability
- 📊 **Health Monitoring** - Continuous system and AI assistant monitoring  
- 🔐 **Secure Remote Access** - SSH and VPN access for troubleshooting
- 📋 **Diagnostic Tools** - Comprehensive system information and maintenance scripts
- 💾 **Automated Backups** - Critical configuration backup and retention

## Quick Deployment

### For Client Devices (Mac Mini)

```bash
# Run this on the client Mac Mini
curl -fsSL https://raw.githubusercontent.com/OCTechTron/oc-ai-remote-management/main/setup-remote-management.sh | bash
```

### Manual Installation

```bash
# Clone repository
git clone https://github.com/OCTechTron/oc-ai-remote-management.git
cd oc-ai-remote-management

# Run setup
chmod +x setup-remote-management.sh
./setup-remote-management.sh
```

## What Gets Installed

### 🔍 Monitoring System
- **Health checks every 4 hours** - Tests Mila email/calendar functionality
- **System resource monitoring** - Disk space, memory, CPU usage
- **Service status tracking** - OpenClaw gateway monitoring
- **Automatic restart attempts** - Self-healing capabilities

### 🔄 Update System  
- **Weekly auto-updates** - Sundays at 3 AM
- **Pre-update testing** - Ensures system is functional before updating
- **Automatic backups** - Creates timestamped backups before updates
- **Rollback capability** - Manual recovery if updates fail
- **Backup retention** - Keeps last 5 backups automatically

### 🔐 Remote Access
- **SSH Access** - Secure shell access for troubleshooting
- **Tailscale VPN** - Secure remote access from anywhere
- **Support Key Installation** - Pre-authorized OC-Tech support access
- **Screen Sharing Ready** - macOS native remote desktop capability

### 🛠️ Diagnostic Tools
- **System Information Script** - Complete system status report
- **Service Restart Tool** - Quick recovery commands
- **Log Analysis Tools** - Centralized logging and monitoring
- **Manual Maintenance Scripts** - Emergency recovery procedures

## File Structure

```
oc-ai-remote-management/
├── setup-remote-management.sh     # Main installation script
├── scripts/
│   ├── health-monitor.sh          # Health monitoring system
│   ├── auto-update.sh            # Update system with rollback
│   ├── system-info.sh            # Diagnostic information
│   └── restart-services.sh       # Service recovery
├── config/
│   ├── crontab.txt               # Scheduled job definitions
│   └── ssh-keys/                 # Support team SSH keys
└── docs/
    ├── deployment-guide.md       # Client deployment instructions
    ├── troubleshooting.md        # Common issues and solutions
    └── security.md               # Security considerations
```

## Security Features

### 🔐 Access Control
- **SSH Key Authentication** - No password-based access
- **Limited User Privileges** - Non-root access where possible  
- **VPN-Only Access** - Tailscale network isolation
- **Audit Logging** - All access attempts logged

### 🛡️ Update Safety
- **Pre-Update Testing** - Validates system before changes
- **Automatic Backups** - Critical files backed up before updates
- **Rollback Procedures** - Manual recovery if updates fail
- **Staged Rollout** - Updates can be tested on development systems first

### 📊 Monitoring Privacy
- **Local Logging Only** - No data transmitted to external servers
- **Encrypted Communications** - All remote access encrypted
- **Minimal Data Collection** - Only operational metrics collected
- **Client Control** - All monitoring can be disabled by client

## Usage

### For Support Staff

#### Remote System Check
```bash
# SSH into client system
ssh -i ~/.ssh/oc-ai-support milaai-assistant@[CLIENT-IP]

# Run diagnostic report
~/oc-ai-scripts/system-info.sh
```

#### Emergency Recovery
```bash
# Restart all services
~/oc-ai-scripts/restart-services.sh

# Manual health check
~/oc-ai-scripts/health-monitor.sh

# Check recent logs
tail -20 ~/oc-ai-logs/health.log
```

### For Clients

#### Check System Status
```bash
# View system information
~/oc-ai-scripts/system-info.sh

# Check logs
less ~/oc-ai-logs/health.log
```

#### Manual Service Control
```bash
# Restart AI services
~/oc-ai-scripts/restart-services.sh

# Test Mila functionality
python3 ~/mila_gmail_calendar.py status
```

## Log Locations

- **Health Monitoring**: `~/oc-ai-logs/health.log`
- **Update History**: `~/oc-ai-logs/updates.log`  
- **Setup Information**: `~/oc-ai-logs/setup.log`
- **Maintenance Actions**: `~/oc-ai-logs/maintenance.log`

## Scheduled Jobs

- **Health Check**: Every 4 hours (0 */4 * * *)
- **Auto-Update**: Sundays at 3 AM (0 3 * * 0)
- **Log Cleanup**: Daily at 2 AM (0 2 * * *)

## Support

### Professional Support
- **Email**: ai@overclockedtech.net
- **Remote Access**: Available 24/7 for critical issues
- **Response Time**: < 4 hours for system-down issues

### Self-Service Resources
- **System Status**: Run `~/oc-ai-scripts/system-info.sh`
- **Service Recovery**: Run `~/oc-ai-scripts/restart-services.sh`
- **Documentation**: `~/OC-AI-Remote-Management-README.txt`

## Version History

### Version 1.0
- Initial release with full remote management capability
- Health monitoring and auto-update systems
- SSH and VPN access configuration
- Comprehensive diagnostic tools

---

**Overclocked Technologies** - Professional AI Assistant Deployments  
*Supporting Client Success Through Proactive System Management*