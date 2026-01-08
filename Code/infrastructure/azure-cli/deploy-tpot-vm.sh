#!/bin/bash
# =============================================================================
# Azure T-Pot Honeypot VM Deployment Script
# Cloud-Native Deception Architecture
# =============================================================================
#
# This script deploys the main honeypot VM on Azure with appropriate
# networking and NSG configurations.
#
# Prerequisites:
#   - Azure CLI installed and authenticated (az login)
#   - Appropriate Azure subscription permissions
#
# Usage:
#   chmod +x deploy-tpot-vm.sh
#   ./deploy-tpot-vm.sh
# =============================================================================

set -e

# Configuration Variables
RESOURCE_GROUP="HP-NETWORKSECURITY"
LOCATION="eastus"
VNET_NAME="hp-vnet"
SUBNET_NAME="hp-subnet"
NSG_NAME="hp-nsg"
VM_NAME="tpot-vm"
VM_SIZE="Standard_D4s_v3"  # 4 vCPU, 16GB RAM - Required for T-Pot
ADMIN_USER="mojiz"

echo "=============================================="
echo "  Deploying T-Pot Honeypot VM"
echo "  Cloud-Native Deception Architecture"
echo "=============================================="

# Create Resource Group
echo "[1/6] Creating Resource Group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION

# Create Virtual Network
echo "[2/6] Creating Virtual Network..."
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VNET_NAME \
    --address-prefix 10.0.0.0/16 \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix 10.0.1.0/24

# Create Network Security Group
echo "[3/6] Creating Network Security Group..."
az network nsg create \
    --resource-group $RESOURCE_GROUP \
    --name $NSG_NAME

# Configure NSG Rules - Honeypot (Open to capture traffic)
echo "[4/6] Configuring NSG Rules..."

# Allow custom SSH port for management
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name SSH_Management \
    --priority 100 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-port-ranges 64295

# Allow T-Pot Web UI
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name TPot_WebUI \
    --priority 110 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-port-ranges 64297

# Allow all dangerous ports for honeypot capture
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name Honeypot_AllPorts \
    --priority 120 \
    --access Allow \
    --protocol '*' \
    --direction Inbound \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-port-ranges 0-64000

# Allow Financial Decoy port
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name Financial_Decoy \
    --priority 130 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-port-ranges 8085

# Deploy Virtual Machine
echo "[5/6] Deploying Virtual Machine..."
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
echo "[6/6] Retrieving Public IP..."
PUBLIC_IP=$(az vm show \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --show-details \
    --query publicIps \
    --output tsv)

echo ""
echo "=============================================="
echo "  Deployment Complete!"
echo "=============================================="
echo ""
echo "VM Name:        $VM_NAME"
echo "Public IP:      $PUBLIC_IP"
echo "SSH Command:    ssh -p 64295 $ADMIN_USER@$PUBLIC_IP"
echo ""
echo "Next Steps:"
echo "1. SSH into the VM"
echo "2. Run tpot-install.sh to install T-Pot"
echo "3. Deploy the Financial Decoy application"
echo ""
echo "=============================================="
