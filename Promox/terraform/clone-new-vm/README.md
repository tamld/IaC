
# Info:
+ Terraform clone VM from a template
+ Using Provider Telmate
+ Image name: focal-server-cloudimg-amd64.img
+ Add packages: openssh-server,w get, git,c url, zsh, net-tools, nano (virt-customize )
# Action Steps
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
+ Run Terraform plan with type of resource
  + [Create a Qemu VM resource](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#create-a-qemu-vm-resource)
  + [Provision through PXE Network Boot](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#provision-through-pxe-network-boot).
  
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
### 2.2 [Server Proxmox Settings](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
#### [Create user](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform)
```ruby
# Add role name 'TerraformProv' with privileges
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
# Add user, password
pveum user add terraform-prov@pve --password P@ssw0rd
# Assign user to role 'TerraformProv'
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

#### Create user API token, permisions, privileges
```ruby
pveum user token add terraform-prov@pve terraform-token --privsep=0
pveum acl modify / -user terraform-prov@pve -role Administrator
pveum acl modify /storage/zfs -user terraform-prov@pve -role Administrator
```
> [!NOTES]
> The token value is only displayed/returned once when the token is generated. It cannot be retrieved again over the API at a later time!
<!-- terraform-prov@pve: user token
terraform-token: token id (token name)
--privsep=0: false, user and api has the same settings
-->
### 2.3 Terraform actions ([Telmate plugin](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/guides/installation.md)).
#### Init Telmate plugin
```bash
# Bash shell
vi terraform
```
```ruby
# Add provider Telmate
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

```bash
# Bash shell
terraform init
```
```bash
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of telmate/proxmox from the dependency lock file
- Using previously-installed telmate/proxmox v2.9.14

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
