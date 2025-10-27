#  Deployment Steps & Challenges Faced

This document outlines the step-by-step process used to deploy the Group 5 Static Website on Microsoft Azure, along with key challenges encountered and how they were resolved.

---

##  Deployment Workflow

1. **Local Setup**
   - Installed Azure CLI, Git, and VS Code
   - Logged in via `az login`
   - Created a unique, responsive static website (`index.html`, `about.html`, `contact.html`, `style.css`)

2. **GitHub Repository**
   - Initialized Git repo locally
   - Created remote repo on GitHub: `group5-static-website`
   - Pushed all project files (website, scripts, docs, README)

3. **Infrastructure Automation**
   - Wrote `scripts/deploy-infrastructure.sh` to create:
     - Resource Group: `group5`
     - VNet + Subnet
     - NSG with rules for port 80 (HTTP) and 22 (SSH)
     - Public IP (non-zonal, for `uksouth`)
     - Ubuntu 22.04 VM: `victoria-vm`
   - Fixed critical Azure CLI syntax errors (e.g., NSG attachment, NIC creation)

4. **Website Deployment Script**
   - Wrote `scripts/deploy-website.sh` to:
     - Copy website files via `scp`
     - Install NGINX
     - Set correct ownership (`www-data`)
     - Restart web server
   - Added retry logic and `/tmp/site` cleanup to fix SCP failures

5. **Documentation**
   - Created architecture diagram and deployment guide
   - Captured all required screenshots (local site, GitHub, Azure Portal, live site)

6. **Bonus: GitHub Actions Automation**
   - Created Service Principal via Azure Portal
   - Added secrets to GitHub
   - Built `.github/workflows/deploy.yml`
   - Resolved YAML syntax and JSON credential errors

7. **Final Deployment**
   - Ran scripts locally → site live at `http://<public-IP>`
   - Verified accessibility on port 80 (no port number needed)

---

##  Challenges Faced & Solutions

| Challenge | Root Cause | Solution |
|---------|-----------|--------|
| **SSH/SCP Connection Timeouts** | NSG not properly attached to subnet → port 22 blocked | Explicitly bound NSG to subnet using `az network vnet subnet update` |
| **`unrecognized arguments` in `az vm create`** | Mixing `--nics` with `--vnet-name`/`--subnet` | Used only `--nics $NIC_NAME`; created NIC separately with full network config |
| **Public IP Zone Error in `uksouth`** | Tried to use `--zone ""` in non-zonal region | Removed `--zone` entirely from `public-ip create` |
| **SCP Failed: `/tmp/site` not a directory** | Previous failed run created `/tmp/site` as a file | Added `rm -rf /tmp/site && mkdir -p /tmp/site` before copy |
| **Invalid User: `www-www-data`** | Typo in NGINX ownership command | Corrected to `www-data:www-data` |
| **Git Push Rejected** | Remote repo had commits not present locally (e.g., from browser edits) | Ran `git pull origin main`, resolved merge, then pushed |
| **Merge Conflicts on `index.html`** | Remote version deleted file; local version modified | Used `git checkout --ours website/` to keep local files |
| **GitHub Actions Login Failed** | Invalid or expired Service Principal secret | Recreated Service Principal via Azure Portal and updated GitHub Secrets |
| **YAML Syntax Errors in Workflow** | Malformed indentation or multiline JSON | Used single-line JSON string wrapped in single quotes |
| **Workflow Taking Too Long** | Azure VM provisioning is inherently slow (~5 min) | Waited patiently; confirmed success after 8 minutes |

---

##  Success Criteria Met

-  Website accessible at `http://<public-IP>` (port 80 only)
-  No manual steps in Azure Portal — all via CLI scripts
-  All code stored in GitHub with version control
-  Professional documentation with screenshots
-  (Bonus) GitHub Actions automation implemented
-  Site is beautiful, responsive, and fully clickable

> “Automation is not just convenience — it’s reliability.”  
> — Group 5 Cloud Project, October 2025
