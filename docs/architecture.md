# Architecture Diagram & Description

This project deploys a static website on Azure using Infrastructure-as-Code (IaC) via Azure CLI.

## Components

| Component | Value |
|----------|-------|
| Resource Group | `group5` |
| VM Name | `victoria-vm` |
| OS | Ubuntu 22.04 LTS |
| Web Server | NGINX |
| VNet | `group5-vnet` (CIDR: `10.0.0.0/16`) |
| Subnet | `web-subnet` (CIDR: `10.0.0.0/24`) |
| NSG | `web-nsg` (allows ports 80 and 22) |
| Public IP | Static, assigned to VM NIC |
| Admin User | `cloudproject` |

##  Network Flow

## Why This Design?

- No manual steps: All resources created via `deploy-infrastructure.sh`
- Secure by default: NSG restricts traffic to only HTTP (80) and SSH (22)
- Scalable: Can be extended to multiple VMs or load balancers later
- Automated: Deployment script copies files and configures NGINX
