#!/bin/bash
# =============================================================================
# T-Pot Honeypot Installation Script
# Cloud-Native Deception Architecture
# =============================================================================
#
# This script installs T-Pot (https://github.com/telekom-security/tpotce)
# on an Azure Ubuntu VM.
#
# Prerequisites:
#   - Ubuntu 20.04 LTS or newer
#   - Minimum 8GB RAM, 128GB storage
#   - Root/sudo access
#   - Ports configured via NSG (see infrastructure/network-security/nsg-rules.md)
#
# Usage:
#   chmod +x tpot-install.sh
#   sudo ./tpot-install.sh
# =============================================================================

set -e

echo "=============================================="
echo "  T-Pot Honeypot Installation"
echo "  Cloud-Native Deception Architecture"
echo "=============================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (sudo ./tpot-install.sh)"
    exit 1
fi

# Update system packages
echo "[1/5] Updating system packages..."
apt-get update && apt-get upgrade -y

# Install prerequisites
echo "[2/5] Installing prerequisites..."
apt-get install -y git curl

# Clone T-Pot repository
echo "[3/5] Cloning T-Pot repository..."
cd /opt
git clone https://github.com/telekom-security/tpotce.git
cd tpotce

# Run T-Pot installer
echo "[4/5] Running T-Pot installer..."
echo "Note: Select 'Standard' installation type when prompted."
echo "      This includes all honeypots and the ELK stack."
./install.sh

# Post-installation notes
echo "[5/5] Installation complete!"
echo ""
echo "=============================================="
echo "  Post-Installation Notes"
echo "=============================================="
echo ""
echo "1. The system will reboot after installation."
echo ""
echo "2. Access points after reboot:"
echo "   - SSH (Management):  Port 64295"
echo "   - T-Pot Web UI:      https://<IP>:64297"
echo "   - Kibana Dashboard:  https://<IP>:64297/kibana"
echo ""
echo "3. Default credentials were set during installation."
echo "   Change them immediately after first login!"
echo ""
echo "4. Ensure NSG rules allow traffic:"
echo "   - Ports 0-64000: Allow from Internet (honeypot)"
echo "   - Port 64295: Allow from Admin IP only (SSH)"
echo "   - Port 64297: Allow from Admin IP only (Web UI)"
echo ""
echo "=============================================="
