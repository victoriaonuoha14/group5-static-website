#!/bin/bash

RG_NAME="group5"
VM_NAME="web-vm"
ADMIN_USER="cloudproject"
PUBLIC_IP_NAME="web-public-ip"

# Get Public IP
PUBLIC_IP=$(az network public-ip show -g "$RG_NAME" -n "$PUBLIC_IP_NAME" --query ipAddress -o tsv)
if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" == "null" ]; then
  echo "❌ Failed to get public IP. Is the VM deployed?"
  exit 1
fi
echo "Public IP: $PUBLIC_IP"

# Wait for VM to finish booting
echo "Waiting 90 seconds for VM to be ready..."
sleep 90

# Clean up and ensure /tmp/site is a fresh directory
echo "Cleaning and creating /tmp/site directory on VM..."
ssh -o StrictHostKeyChecking=no "${ADMIN_USER}@${PUBLIC_IP}" "rm -rf /tmp/site && mkdir -p /tmp/site"

# Verify local website folder exists
if [ ! -d "website" ]; then
  echo "❌ Local 'website/' folder not found. Run this script from the project root."
  exit 1
fi

# Copy website files to VM
echo "Copying website files to VM..."
if ! scp -o StrictHostKeyChecking=no -r website/* "${ADMIN_USER}@${PUBLIC_IP}:/tmp/site/"; then
  echo "❌ SCP failed. Check local 'website/' folder and network."
  exit 1
fi

# Deploy via SSH
echo "Installing NGINX and deploying site..."
ssh -o StrictHostKeyChecking=no "${ADMIN_USER}@${PUBLIC_IP}" << 'EOF'
  set -e
  sudo apt update -y
  sudo apt install -y nginx
  sudo rm -rf /var/www/html/*
  sudo cp -r /tmp/site/* /var/www/html/
  sudo chown -R www-data:www-data /var/www/html
  sudo chmod -R 755 /var/www/html
  sudo systemctl restart nginx
  sudo systemctl enable nginx --quiet
  echo "✅ Website is LIVE!"
EOF

echo ""
echo "🎉 Deployment Complete!"
echo "🔗 Visit: http://$PUBLIC_IP"