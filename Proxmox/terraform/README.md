# 🏗️ Proxmox Terraform Provider

Infrastructure as Code configuration for Proxmox VE using the Terraform Telmate provider.

## Prerequisites

- Terraform ≥ 1.0
- Proxmox VE 7.x or 8.x with API token configured

## Quick Start

```bash
cd Proxmox/terraform
cp terraform.tfvars.example terraform.tfvars   # if provided
$EDITOR terraform.tfvars   # Set PM_API_URL, PM_API_TOKEN_ID, PM_API_TOKEN_SECRET
terraform init
terraform plan
terraform apply
```

## Proxmox API Token

```bash
# On Proxmox host:
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role PVEVMAdmin
pveum user token add terraform@pve terraform --privsep=0
```

## Notes

- Never commit `terraform.tfvars` — contains secrets
- State file (`terraform.tfstate`) should be stored remotely (S3, Consul, or Terraform Cloud)
- Provider: [Telmate/proxmox](https://registry.terraform.io/providers/Telmate/proxmox/latest)