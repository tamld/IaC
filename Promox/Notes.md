
# A. Fresh Proxmox VE Installation
# Things to do when install a fresh Proxmox VE 
## 1. Run proxmox scripts helper that can obtain useful settings
> https://tteck.github.io/Proxmox/

> [!NOTE]  
> Subscription Enterprise is enabled by default. Disable and use no-subscription to update/upgrade

 + `Proxmox VE Tools` should be run first
 + Scripts are recommended to run directly from the server web GUI shell instead of the client terminal/ssh

## 2. Install Webmin System Administration for Web administrative purposes
`bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/webmin.sh)"`

## 3. Install ISC DHCPd Server (Webmin) for Host only Setting 
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

| Settings | Description |
| --- | --- |
| `Subnet description` | Host only |
| `Network address` | 192.168.153.0 | 
|`Netmask` | 255.255.255.0 |
| `Address ranges` | 192.168.153.20-200 |
| `Listen on interfaces` | vmbr1 |

## 4. Add vmbr1 with Scope Network Host Only
`vi /etc/network/interfaces.new`
```ruby
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
```

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

> [!WARNING]
> Known Limitations
  + ***proxmox_vm_qemu.disk.size*** attribute does not match what is displayed in the Proxmox UI.
  + Updates to ***proxmox_vm_qemu*** resources almost always result as a failed task within the Proxmox UI. This appears to be harmless and the desired configuration changes do get applied.
  + ***proxmox_vm_qemu*** does not (yet) validate vm names, be sure to only use alphanumeric and dashes otherwise you may get an opaque 400 Parameter Verification failed (indicating a bad value was sent to proxmox).
  + When using the ***proxmox_lxc*** resource, the provider will crash unless rootfs is defined.
  + When using the **Network Boot mode (PXE)**, a valid NIC must be defined for the VM, and the boot order must specify network first.

# C. Procedure steps
## 1. Overview
`Create template`
+ Download a base Ubuntu cloud image
+ Install some packages into the image
+ Create a Proxmox VM using the image and then convert it to a template
+ Clone the template into a full VM and set some parameters

`Server Proxmox Settings` 
+ Install Terraform and determine authentication method for Terraform to interact with Proxmox (user/pass vs API keys)
  
`Terraform actions`
+ Terraform basic initialization and provider installation
+ Terraform plan
+ Run Terraform plan
  
## 2. Installation
### 2.1 Creat template
#### Make symlink for relative path (optional)
+ ISO Images
`ln -s /var/lib/vz/template/iso/ liso`

+ CT Templates
`ln -s /var/lib/vz/template/cache/ lct`
```bash
root@pve ~  ll
lrwxrwxrwx 1 root root   27 Sep 11 15:08 lct -> /var/lib/vz/template/cache//
lrwxrwxrwx 1 root root   25 Sep 11 15:02 liso -> /var/lib/vz/template/iso//
```
#### Download a base Ubuntu cloud image
Download from [Official Ubuntu Cloud Images](https://cloud-images.ubuntu.com/).

```bash
# Download focal ubuntu (20.04 LTS) 
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
# Download focal ubuntu 22.04 LTS
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img 
```
#### Install [libguestfs-tools](https://www.libguestfs.org/)
```bash
apt update -y && apt install libguestfs-tools -y
```
#### Modify, add qemu-guest-agent into the Ubuntu image file
+ When finish download image, add qemu-guest-agent for the default installation
 + Add apps within the command
```bash
virt-customize -a focal-server-cloudimg-amd64.img --install openssh-server,wget,git,curl,zsh,net-tools,nano
```

#### List available storages
In this section, we are going to use the **zfs** as the storage location.
```bash
root@pve ~ pvesm status 
Name             Type     Status           Total            Used       Available        %
local             dir     active        71017632        21094416        46269996   29.70%
local-lvm     lvmthin     active       148086784               0       148086784    0.00%
zfs           zfspool     active       942931968          947828       941984140    0.10%
```
#### Create a Proxmox VM using the image
```bash
qm create 9000 --name "ubuntu-2004-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr1 #vmbr0 as Bridge, vmbr1 as Host only
qm importdisk 9000 focal-server-cloudimg-amd64.img zfs
qm set 9000 --scsihw virtio-scsi-pci --scsi0 zfs:vm-9000-disk-0 #disk type, location storage to save
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --ide2 zfs:cloudinit #keep template can be maintained, updated using cloud-init
qm set 9000 --serial0 socket --vga serial0 # default display instead of serial console
qm set 9000 --agent enabled=1 #enable qemu-guest-agent
```
List VMs:
```bash
root@pve ~ qm list
VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID       
       999 test-clone-cloud-init stopped    2048               2.20 0         
      9000 ubuntu-2004-cloudinit-template stopped    2048               2.20 0         
```

#### Convert VMID 9000 to a template
```bash
qm shutdown 9000
qm template 9000
qm clone 9000 999 --name test-clone-cloud-init
qm set 999 --cipassword="password" --ciuser="ubuntu"
qm resize 999 scsi0 60G
#qm set 999 -net0 virtio,bridge=vmbr0
qm set 999 --sshkey ~/.ssh/id_rsa.pub
```
List VMs:
```bash
root@pve ~ qm list
VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID       
       999 test-clone-cloud-init stopped    2048               2.20 0         
      9000 ubuntu-2004-cloudinit-template stopped    2048               2.20 0  
```
### 2.2 [Server Proxmox Settings](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli). 
#### [Create user](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform)
```ruby
# Add role name 'TerraformProv' with privileges
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
# Add user, password
pveum user add terraform-prov@pve --password P@ssw0rd
# Assign user to role 'TerraformProv'
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

#### Create user API token, permisions, privilege
```ruby
pveum user token add terraform-prov@pve terraform-token --privsep=0
pveum acl modify / -user terraform-prov@pve -role PVEAdmin
pveum acl modify /storage/zfs -user terraform-prov@pve -role Administrator
```
> [!NOTES]
> The token value is only displayed/returned once when the token is generated. It cannot be retrieved again over the API at a later time!
<!-- terraform-prov@pve: user token
terraform-token: token id (token name)
--privsep=0: false, user and api has the same settings
-->
### 2.3 Terraform actions ([Telmate plugin](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/guides/installation.md)).
```ruby
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      # Lastest version on Sep 10, 2023
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  # Configuration options
}
```
Ref:
[Cloud Init Guide](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/guides/cloud_init.md#cloud-init-guide)

## 3. Reference Links
+ `Infrastructure as Code with Terraform`: [Hashicorp](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code).
+ `Proxmox VE Administration Guide`[version 8.0.4](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_introduction).
+ `Terraform provider plugin for Proxmox`: [Telmate Github Repo](https://github.com/Telmate/terraform-provider-proxmox#terraform-provider-plugin-for-proxmox).
+ `ChristianLempa`: [Github ßboilerplates](https://github.com/ChristianLempa/boilerplates/tree/main/terraform/proxmox).
+ `How to deploy VMs in Proxmox with Terraform`: [Blog](https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/).
+ `Proxmox virtual machine *automation* in Terraform`: [Youtube](https://www.youtube.com/watch?v=dvyeoDBUtsU&ab_channel=ChristianLempa).
+ `Terraform Infrastructure as Code for Proxmox`: [Youtube](https://www.youtube.com/watch?v=DjmzVHj3AK0&ab_channel=EngineeringwithMorris).
+ `Github Markdown Basic Writing`: [Github](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#headings).