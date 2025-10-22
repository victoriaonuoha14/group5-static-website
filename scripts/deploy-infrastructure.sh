#!/bin/bash

# === CONFIGURATION ===
RG_NAME="group5"
LOCATION="uksouth"
VNET_NAME="group5-vnet"
SUBNET_NAME="web-subnet"
NSG_NAME="web-nsg"
VM_NAME="victoria-vm"
NIC_NAME="victoria-nic"
ADMIN_USER="cloudproject"        

PUBLIC_IP_NAME="web-public-ip"

# === STEP 1: Create Resource Group ===
echo "Creating Resource Group: $RG_NAME"
az group create --name $RG_NAME --location $LOCATION --output none

# === STEP 2: Create Virtual Network & Subnet ===
echo "Creating VNet and Subnet..."
az network vnet create \
  --resource-group $RG_NAME \
  --name $VNET_NAME \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name $SUBNET_NAME \
  --subnet-prefixes 10.0.0.0/24 \
  --output none

# === STEP 3: Create Network Security Group (NSG) ===
echo "Creating NSG and rules..."
az network nsg create --resource-group $RG_NAME --name $NSG_NAME --output none

# Allow HTTP (port 80)
az network nsg rule create \
  --resource-group $RG_NAME --nsg-name $NSG_NAME \
  --name AllowHTTP --priority 1000 --direction Inbound \
  --protocol Tcp --destination-port-ranges 80 --access Allow \
  --output none

# Allow SSH (port 22)
az network nsg rule create \
  --resource-group $RG_NAME --nsg-name $NSG_NAME \
  --name AllowSSH --priority 1010 --direction Inbound \
  --protocol Tcp --destination-port-ranges 22 --access Allow \
  --output none

# === STEP 4: Create Public IP (NO ZONE in uksouth) ===
echo "Creating Public IP..."
az network public-ip create \
  --resource-group $RG_NAME \
  --name $PUBLIC_IP_NAME \
  --allocation-method Static \
  --sku Standard \
  --output none

# === STEP 5: Attach NSG to Subnet ===
echo "Binding NSG to subnet for reliable firewall rules..."
az network vnet subnet update \
  --resource-group $RG_NAME \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --network-security-group $NSG_NAME \
  --output none

# === STEP 6: Create Network Interface (NIC) ===
echo "Creating Network Interface (NIC)..."
az network nic create \
  --resource-group $RG_NAME \
  --name $NIC_NAME \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_NAME \
  --public-ip-address $PUBLIC_IP_NAME \
  --network-security-group $NSG_NAME \
  --output none

# === STEP 7: Create Linux VM ===
echo "Creating Ubuntu VM..."
az vm create \
  --resource-group $RG_NAME \
  --name $VM_NAME \
  --nics $NIC_NAME \
  --image Ubuntu2204 \
  --size Standard_D4s_v3 \
  --admin-username $ADMIN_USER \
  --generate-ssh-keys \
  --output table

echo ""
echo "✅ Infrastructure deployed successfully!"
echo "🌐 Public IP: $(az network public-ip show -g $RG_NAME -n $PUBLIC_IP_NAME --query ipAddress -o tsv)"
echo "⏳ Next: Run './scripts/deploy-website.sh'"