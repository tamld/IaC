
# A. Fresh Proxmox VE Installation
# Overview
- Install a fresh Proxmox VE
- Setting Network plan for Host Only, NAT, Bridge
- Build Template then clone a new VM
- Deploy VM with config, package by using Terraform, Ansible
  
# Things to do when install a fresh Proxmox VE 
## 1. Run proxmox scripts helper that can obtain useful settings
> https://tteck.github.io/Proxmox/
> [!NOTE]  
> Subscription Enterprise is enabled by default. Disable and use no-subscription to update/upgrade
> This part is optional, consider to use into your system

 + `Proxmox VE Tools` is an optional choice that might help for fresher users
 + Scripts are recommended to run directly from the server web GUI shell instead of the client terminal/ssh

## 2. Install Webmin System Administration for Web administrative purposes
`bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/webmin.sh)"`

## 3. Install ISC DHCPd Server (Webmin) for Host Only and NAT 
+ This service can be installed within Webmin page.
+ Default Webmin port: https://IP:10000
+ In this scenario, VM/CT will get IP from the DHCP Server and run directly in the Network Infrastructure. The DHCPd acts as a service that allows VM/CT to communicate internally only and can't reach other devices on the Network infrastructure.
+ For NAT purposes, take a glance at: [Masquerading (NAT) with iptables](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#sysadmin_network_configuration)
> [!NOTE]  
> The config example below:

<!--
/etc/init.d/isc-dhcp-server stop
/etc/init.d/isc-dhcp-server start
/etc/init.d/isc-dhcp-server restart
/var/lib/dhcp/dhcpd.leases 
-->
Simply paste this scripts into the **Manually edit configuration** button
```bash
# Change the values setting to suit your network configuration
option domain-name-servers 8.8.8.8, 1.1.1.1;
ddns-update-style none;

# NAT Network on vmbr2
subnet 10.10.10.0 netmask 255.255.255.0 {
	option ntp-servers asia.pool.ntp.org;
	option domain-name-servers 8.8.8.8, 1.1.1.1;
	option routers 10.10.10.1;
	range 10.10.10.50 10.10.10.200;
	interface vmbr2;
}

# Host only on vmbr1
subnet 192.168.153.0 netmask 255.255.255.0 {
	option ntp-servers asia.pool.ntp.org;
	option domain-name-servers 8.8.8.8 , 1.1.1.1;
	option routers 192.168.153.1;
	range 192.168.153.50 192.168.153.200;
	interface vmbr1;
}
```
> [!WARNING]
>  The service can not start if only ONE configuration is not matched. For further configuration, read this [KB](https://webmin.com/docs/modules/dhcp-server/)

## 4. Add vmbr1, vmbr2 with Scope Network Host Only, NAT
`vi /etc/network/interfaces.new`
```bash
auto lo
iface lo inet loopback

iface enp3s0 inet manual

auto vmbr0
iface vmbr0 inet static
        address 192.168.100.71/24
        gateway 192.168.100.99
        bridge-ports enp3s0
        bridge-stp off
        bridge-fd 0

iface wlp4s0 inet manual

auto vmbr1
iface vmbr1 inet static
        address 192.168.153.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0
#Host Only

auto vmbr2
iface vmbr2 inet static
        address 10.10.10.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up iptables -t nat -A POSTROUTING -s '10.10.10.0/24' -o vmbr0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '10.10.10.0/24' -o vmbr0 -j MASQUERADE
#NAT
```
## 5. Build Template
- A Proxmox template is a pre-configured image used to create new virtual machines (VMs) or containers. 
- It simplifies the setup process by providing a blueprint for consistent deployments. 
- Templates are built by configuring a reference VM or container, and they save time and ensure uniformity when creating new instances.
Read more [here](https://github.com/tamld/IaC/tree/main/Promox/terraform/clone-vm-dhcp#11-create-template)

## 6. Deploy VM with config, package by using Terraform, Ansible
### 6.1 The main.tf
- Is the main configuration file in Proxmox VE, typically containing definitions of virtual machines and other virtual devices.
- Contains specific information about configuration and network resources, aiding in virtual machine and container management.
- Is used to create, configure, and manage virtual machines and elements within the virtualized environment.
- Serves as the control center for deploying and managing virtual machines and containers in Proxmox.
Read more [here](https://github.com/tamld/IaC/blob/main/Promox/terraform/clone-vm-dhcp/main.tf)

### 6.2 The var.tf
- Is used for variable definitions and is a file where variables are declared and assigned values.
- Enables parameterization of your Proxmox configuration, making it more flexible and reusable.
- Allows for customization of configuration settings without modifying the main main.tf file.
- Enhances the maintainability of your Proxmox infrastructure by separating variable declarations from the core configuration.
Read more [here](https://github.com/tamld/IaC/blob/main/Promox/terraform/clone-vm-dhcp/var.tf)

### 6.3 The terraform.tfvars
- Is a variable definition file used to set specific values for variables used in your Terraform configuration.
- Provides a means to customize the behavior of your Terraform scripts by supplying variable values in a separate file.
- Enhances reusability and maintainability by keeping variable assignments separate from the main configuration.
Read more [here](https://github.com/tamld/IaC/tree/main/Promox/terraform/clone-vm-dhcp#init-terraform-terraformtfvars)

# B. Self-learning
## 1. Keyword, explaination and example 
| Keyword | Description | Key Values | 
| --- | --- | --- |
| `pve` | Node Proxmox Name | pve |
| `localnetwork` | VNet in Proxmox | vmbr0, vmbr1 |
|[storage](https://pve.proxmox.com/wiki/Storage) | local | Store Backup, ISO Images, CT Templates |
| | zfs |block storage and **VM-vdisks** (ZVOL) and **LXCs** (ZFS dataset) |
| | CT Templates | PATH: ***/var/lib/vz/template/cache/*** |
| | ISO Images| PATH: ***/var/lib/vz/template/iso/*** |
| `local-lvm` | LVM storage | VM Disks, CT Volumes |
| `zfs` | storage pool | Snapshot, Clone, Checksum...etc |
|  | VM Disks | PATH /dev/zvol/zfs/ | 
|  | CT Volumes | PATH /zfs | 
| `CT` | Container (LXC) | Less resource, share kernel with host |
| | Virtual Machine (KVM) | More secure, seperate with host | 
| `Realms` | Authenticate Methods | PAM, PVE, LDAP, OpenID |
| `Permisions` | Datacenter settings | modify user settings |
| | Users | Add, modify user permisions |
|  | API Tokens | Add, edit, delete API settings |
|  | [Privilege Separation](https://pve.proxmox.com/wiki/User_Management#pveum_tokens) | Separated privileges, Full privileges |
| [Cloud Init Guide](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/guides/cloud_init.md) | Allows changing settings in the guest when deploying | NoCloud, ConfigDrive. See [Proxmox docs](https://pve.proxmox.com/wiki/Cloud-Init_Support). |
|  | [Custom Cloud Image](https://pve.proxmox.com/wiki/Cloud-Init_FAQ#Creating_a_custom_cloud_image) | rename network devices, add a default user settings, setup a serial terminal |
|  | [Cloud-Init specific Options](https://pve.proxmox.com/wiki/Cloud-Init_Support#_cloud_init_specific_options) | Key values: ***cicustom, meta, network,user, vendor, cipassword, citype, ciupgrade, ciuser, gw*** ...etc.|
| | [Ubuntu cloud-init image](https://cloud-images.ubuntu.com/) | Images list for cloud-init. Not only the Ubuntu images but the other distros are supported as well |
| `Provisioner`| [Provisioning infrastructure](https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#provisioners) | [file](https://developer.hashicorp.com/terraform/language/resources/provisioners/file#file-provisioner), [local-exec](https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec#local-exec-provisioner), [remote-exec](https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec#remote-exec-provisioner)|

> [!WARNING]
> Known Limitations
  + ***proxmox_vm_qemu.disk.size*** attribute does not match what is displayed in the Proxmox UI.
  + Updates to ***proxmox_vm_qemu*** resources almost always result as a failed task within the Proxmox UI. This appears to be harmless and the desired configuration changes do get applied.
  + ***proxmox_vm_qemu*** does not (yet) validate vm names, be sure to only use alphanumeric and dashes otherwise you may get an opaque 400 Parameter Verification failed (indicating a bad value was sent to proxmox).
  + When using the ***proxmox_lxc*** resource, the provider will crash unless rootfs is defined.
  + When using the **Network Boot mode (PXE)**, a valid NIC must be defined for the VM, and the boot order must specify network first.

## 2. Reference Links
+ `Infrastructure as Code with Terraform`: [Hashicorp](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code).
+ `Proxmox VE Administration Guide`[version 8.0.4](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_introduction).
+ `Terraform provider plugin for Proxmox`: [Telmate Github Repo](https://github.com/Telmate/terraform-provider-proxmox#terraform-provider-plugin-for-proxmox).
+ `ChristianLempa`: [Github ßboilerplates](https://github.com/ChristianLempa/boilerplates/tree/main/terraform/proxmox).
+ `How to deploy VMs in Proxmox with Terraform`: [Blog](https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/).
+ `Proxmox virtual machine *automation* in Terraform`: [Youtube](https://www.youtube.com/watch?v=dvyeoDBUtsU&ab_channel=ChristianLempa).
+ `Terraform Infrastructure as Code for Proxmox`: [Youtube](https://www.youtube.com/watch?v=DjmzVHj3AK0&ab_channel=EngineeringwithMorris).
+ `Github Markdown Basic Writing`: [Github](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#headings).