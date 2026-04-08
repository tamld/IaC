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