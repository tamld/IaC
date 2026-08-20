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
---

## 📜 Terraform Provider Evolution Note (Proxmox VE 7 vs PVE 8/9)

> **Historical Context**: The configurations in this directory originally targeted **`Telmate/proxmox: 2.9.14`** (designed for Proxmox VE 6.x and 7.x).

| Provider | Supported PVE Versions | Recommended Use Case | Status |
|:---|:---|:---|:---:|
| **`telmate/proxmox` (v2.9.14)** | Proxmox VE 6.x – 7.x | Legacy cloud-init template cloning with QEMU agent | 📦 `[HISTORICAL]` |
| **`telmate/proxmox` (>= v3.0.1)** | Proxmox VE 8.x+ | Community-updated Telmate provider with PVE 8 API support | 🟡 `[ALTERNATIVE]` |
| **`bpg/proxmox` (>= v0.66)** | Proxmox VE 8.x – 9.x | Modern official OpenTofu / Terraform provider with full LXC, VM, and ACL support | 🟢 `[RECOMMENDED STANDARD]` |

> 💡 **Tip for PVE 8/9 Users**: If you encounter QEMU guest agent timeouts or disk resize errors with `telmate 2.9.14`, upgrade your provider block to `bpg/proxmox` or `telmate/proxmox >= 3.0.1-rc6`.
