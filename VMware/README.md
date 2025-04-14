# 🌀 VMware Infrastructure as Code

This directory contains Infrastructure as Code solutions for VMware environments, including templates, automation scripts, and configuration files.

## 📚 Table of Contents

| Component | Description |
|-----------|-------------|
| [🔄 PowerCLI](./powercli/) | PowerCLI scripts for VMware automation |
| [📜 Templates](./templates/) | VM templates and OVF configurations |
| [🧰 Tools](./tools/) | Utility scripts and tools for VMware management |

## 🚀 Features

### PowerCLI Automation

- VM deployment and configuration
- Host management
- Storage operations
- Network configuration
- Snapshot management
- Resource monitoring

### VM Templates

- Gold master templates
- Application-specific templates
- Multi-tier application templates

### Tools and Utilities

- OVA/OVF import/export
- VM optimization
- Configuration comparison
- Compliance checking

## 📋 Usage Guide

### PowerCLI Setup

1. Install VMware PowerCLI:
```powershell
Install-Module -Name VMware.PowerCLI -Scope CurrentUser
```

2. Connect to vCenter or ESXi host:
```powershell
Connect-VIServer -Server vcenter.example.com -User admin -Password password
```

### Deploy VM from Template

```powershell
# Example PowerCLI script to deploy a VM from template
$vmHost = Get-VMHost -Name "esxi01.example.com"
$vmName = "new-vm-01"
$template = Get-Template -Name "ubuntu-server-template"
$datastore = Get-Datastore -Name "datastore01"
$network = Get-VirtualPortGroup -Name "VM Network"

New-VM -Name $vmName -Template $template -VMHost $vmHost -Datastore $datastore
Get-VM -Name $vmName | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $network.Name -Confirm:$false
Start-VM -VM $vmName
```

### Manage VM Snapshots

```powershell
# Create snapshot
New-Snapshot -VM "vm-name" -Name "pre-update-snapshot" -Description "Before system update"

# Revert to snapshot
Get-Snapshot -VM "vm-name" -Name "pre-update-snapshot" | Set-VM -VM "vm-name" -Confirm:$false

# Remove snapshot
Get-Snapshot -VM "vm-name" -Name "old-snapshot" | Remove-Snapshot -Confirm:$false
```

## 🔧 Prerequisites

- VMware vSphere environment (ESXi hosts and optionally vCenter)
- PowerCLI for automation scripts
- PowerShell 5.1 or later
- Appropriate permissions to manage VMware resources

## 💡 Best Practices

1. **Template Management**: Create and maintain standardized templates
2. **Idempotency**: Ensure scripts can run multiple times without side effects
3. **Error Handling**: Include robust error handling in automation scripts
4. **Documentation**: Document all custom scripts and configurations
5. **Version Control**: Maintain script version history

## 🌐 Architecture Patterns

### Basic VM Deployment

```
Template → Clone → Customize → Configure → Power On → Verify
```

### Multi-tier Application

```
Database VMs → Application VMs → Web VMs → Load Balancer
```

### High Availability Deployment

```
Primary VM → Configure Replication → Secondary VM → Configure Failover
```

## 🔗 Related Resources

- [VMware PowerCLI Documentation](https://code.vmware.com/web/dp/tool/vmware-powercli/)
- [VMware vSphere Documentation](https://docs.vmware.com/en/VMware-vSphere/)
- [VMware Cloud Foundation](https://www.vmware.com/products/cloud-foundation.html)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request for:

- New automation scripts
- Template improvements
- Documentation updates
- Bug fixes