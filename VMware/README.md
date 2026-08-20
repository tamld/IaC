# 💻 VMware — Templates & Automation

Configuration templates and scripts for VMware ESXi and vSphere environments.

## Contents

| Resource | Description |
|----------|-------------|
| Templates | VM configuration templates for common workloads |
| Scripts | PowerCLI and shell scripts for VM lifecycle management |

## Prerequisites

- VMware ESXi 7.0+ or vSphere with vCenter
- [PowerCLI](https://developer.vmware.com/powercli) (for PowerShell scripts)

## Quick Start

```bash
# Connect to vCenter via PowerCLI
Connect-VIServer -Server <vcenter-host> -User <username> -Password <password>

# Or for ESXi direct:
Connect-VIServer -Server <esxi-host>
```

## Notes

- VMware tools (`vmware-tools`) should be installed on all guest VMs for proper lifecycle management
- Export credentials to environment variables rather than hardcoding them in scripts
- For mass deployment, prefer Packer to build reusable VM templates
---

## 🖥️ Scope & Platform Clarification: VMware Workstation Desktop vs ESXi

> **Note on Architecture**: The configurations in this directory target **VMware Workstation Pro Desktop** (via local REST API service `http://localhost:8697/api`) and **Vagrant local testbeds** for Windows/Linux workstations.
>
> For enterprise bare-metal **VMware ESXi / vSphere clusters**, use the official [`hashicorp/vsphere`](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs) Terraform provider instead of `elsudano/vmworkstation`.
