# Deployment Steps

Followed these steps to deploy the static website on Azure.

## Step 1: Set Up Local Environment
- Installed Azure CLI, Git, VS Code
- Logged in to Azure: `az login`
- Created GitHub repo: `group5-static-website`

## Step 2: Build Unique Website
- Created `website/index.html` with custom content (Cloud Project 3: Static Site Deployment)
- Added CSS styling and personal info

## Step 3: Write Infrastructure Script
- Created `scripts/deploy-infrastructure.sh`
- Configured:
  - Resource Group: `group5`
  - VNet/Subnet/NSG
  - VM: `victoria-vm`, Ubuntu 22.04
  - Public IP + NSG rules for port 80/22

## Step 4: Write Deployment Script
- Created `scripts/deploy-website.sh`
- Copies `website/` to VM via SCP
- Installs NGINX, deploys files, sets permissions

## Step 5: Deploy
- Ran `./scripts/deploy-infrastructure.sh`
- Waited 90 seconds for VM to boot
- Ran `./scripts/deploy-website.sh`
- Verified site live at `http://<public-IP>`

## Step 6: Document & Submit
- Took screenshots of each step
- Wrote architecture and deployment docs
- Recorded demo video
- Pushed all code to GitHub

## ⚠️ Challenges Faced
- **SSH timeouts**: Fixed by ensuring NSG attached to subnet
- **SCP failures**: Fixed by cleaning `/tmp/site` before copy
- **Admin user name**: Used lowercase `cloudproject` (no special chars)

## ✅ Success Criteria Met
- [x] Website accessible at `http://<IP>` (port 80 only)
- [x] No manual portal steps — all via CLI
- [x] All scripts in GitHub with version control
- [x] Screenshots and documentation included
