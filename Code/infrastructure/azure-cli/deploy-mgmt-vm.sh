#!/bin/bash
# =============================================================================
# Azure Management VM Deployment Script
# Cloud-Native Deception Architecture
# =============================================================================
#
# This script deploys a HARDENED management VM with restricted access.
# Unlike the honeypot, this VM is locked down to admin IP only.
#
# Prerequisites:
#   - Azure CLI installed and authenticated (az login)
#   - Appropriate Azure subscription permissions
#   - Know your public IP address for whitelist
#
# Usage:
#   chmod +x deploy-mgmt-vm.sh
#   ./deploy-mgmt-vm.sh
# =============================================================================

set -e

# Configuration Variables
RESOURCE_GROUP="HP-NETWORKSECURITY"
LOCATION="eastus"
VNET_NAME="hp-vnet"
SUBNET_NAME="mgmt-subnet"
NSG_NAME="mgmt-nsg"
VM_NAME="mgmt-vm"
VM_SIZE="Standard_B2s"  # 2 vCPU, 4GB RAM - Sufficient for management
ADMIN_USER="mojiz"

# IMPORTANT: Replace with your actual admin IP
ADMIN_IP="YOUR_ADMIN_IP_HERE"  # e.g., "203.0.113.50"

echo "=============================================="
echo "  Deploying Management VM (Hardened)"
echo "  Cloud-Native Deception Architecture"
echo "=============================================="

if [ "$ADMIN_IP" == "YOUR_ADMIN_IP_HERE" ]; then
    echo "ERROR: Please edit this script and set ADMIN_IP to your IP address."
    echo "       You can find your IP at: https://ifconfig.me"
    exit 1
fi

# Create Management Subnet (separate from honeypot)
echo "[1/5] Creating Management Subnet..."
az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET_NAME \
    --address-prefix 10.0.2.0/24

# Create Management NSG (RESTRICTED)
echo "[2/5] Creating Restricted NSG..."
az network nsg create \
    --resource-group $RESOURCE_GROUP \
    --name $NSG_NAME

# Configure NSG Rules - RESTRICTED ACCESS
echo "[3/5] Configuring Restricted NSG Rules..."

# Allow SSH from Admin IP only
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name SSH_AdminOnly \
    --priority 100 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --source-address-prefixes $ADMIN_IP \
    --source-port-ranges '*' \
    --destination-port-ranges 22

# Deny all other inbound traffic
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name DenyAllInbound \
    --priority 4096 \
    --access Deny \
    --protocol '*' \
    --direction Inbound \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-port-ranges '*'

# Deploy Virtual Machine
echo "[4/5] Deploying Management VM..."
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --vnet-name $VNET_NAME \
    --subnet $SUBNET_NAME \
    --image Ubuntu2204 \
    --size $VM_SIZE \
    --admin-username $ADMIN_USER \
    --generate-ssh-keys \
    --public-ip-sku Standard \
    --nsg $NSG_NAME

# Get Public IP
echo "[5/5] Retrieving Public IP..."
PUBLIC_IP=$(az vm show \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --show-details \
    --query publicIps \
    --output tsv)

echo ""
echo "=============================================="
echo "  Management VM Deployment Complete!"
echo "=============================================="
echo ""
echo "VM Name:        $VM_NAME"
echo "Public IP:      $PUBLIC_IP"
echo "Allowed Admin:  $ADMIN_IP"
echo "SSH Command:    ssh $ADMIN_USER@$PUBLIC_IP"
echo ""
echo "SECURITY NOTES:"
echo "- Only $ADMIN_IP can SSH to this VM"
echo "- All other traffic is DENIED"
echo "- Update ADMIN_IP if your IP changes"
echo ""
echo "=============================================="
