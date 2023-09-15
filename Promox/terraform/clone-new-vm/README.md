
# Info:
+ Terraform clone VM from a template
+ Using Provider Telmate
+ Image name: focal-server-cloudimg-amd64.img
+ Add packages: openssh-server,w get, git,c url, zsh, net-tools, nano (virt-customize )
# Action Steps
## 1. Overview
We will do the steps below to create a new VM from the template
### 1.1 Create template
+ Download a base Ubuntu cloud image
+ Install some packages into the image
+ Create a Proxmox VM using the image and then convert it to a template
+ Clone the template into a full VM and set some parameters

### 1.2 Server Proxmox Settings
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
# bash shell
root@pve ~  ll
lrwxrwxrwx 1 root root   27 Sep 11 15:08 lct -> /var/lib/vz/template/cache//
lrwxrwxrwx 1 root root   25 Sep 11 15:02 liso -> /var/lib/vz/template/iso//
```
#### Download a base Ubuntu cloud image
+ We will create a template VM, based on an Image
+ My OS option is Ubuntu because it is familiar to me, you can create your own
+ Download from [Official Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)

```bash
# bash shell
# Download focal ubuntu (20.04 LTS) 
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
# Download focal ubuntu 22.04 LTS
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img 
```
#### Install [libguestfs-tools](https://www.libguestfs.org/)
```bash
# bash shell
apt update -y && apt install libguestfs-tools -y
```
#### Modify, add qemu-guest-agent into the Ubuntu image file
+ When finish download image, add qemu-guest-agent for the default installation
+ Add packages:
```bash
# virt-customize -a [Downloaded image] --install package1,package2,...
virt-customize -a focal-server-cloudimg-amd64.img --install openssh-server,wget,git,curl,zsh,net-tools,nano
```

#### List available storages
+ Define the storage that VMs will be located on
+ In this section, we are going to use the **zfs** 
  
```bash
# bash shell
root@pve ~ pvesm status 
Name             Type     Status           Total            Used       Available        %
local             dir     active        71017632        21094416        46269996   29.70%
local-lvm     lvmthin     active       148086784               0       148086784    0.00%
zfs           zfspool     active       942931968          947828       941984140    0.10%
```
#### Create a Proxmox VM using the image
```bash
# bash shell
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
# bash shell
qm shutdown 9000
qm template 9000
qm clone 9000 999 --name test-clone-cloud-init
qm set 999 --cipassword="password" --ciuser="ubuntu"
qm resize 999 scsi0 60G
qm set 999 -net0 virtio,bridge=vmbr0
qm set 999 --sshkey ~/.ssh/id_rsa.pub
```
List VMs:
```bash
# bash shell
root@pve ~ qm list
VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID       
       999 test-clone-cloud-init stopped    2048               2.20 0         
      9000 ubuntu-2004-cloudinit-template stopped    2048               2.20 0  
```
### 2.2 [Server Proxmox Settings](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
#### [Create user](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform)
Create a new user, a role and token APIs for terraform building
```bash
# bash shell
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
### 2.3 Terraform actions using ([Telmate plugin](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/guides/installation.md)).
#### Init Telmate plugin
```bash
# bash shell
vi main.tf
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
# bash shell
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
### Create VM by cloning the template
+ In the remote (terraform installed), create a project name terraform add set configs
+ Add config into the tf.main file with appropriate settings
+ My example at [tf.main](https://github.com/tamld/IaC/blob/main/Promox/terraform/clone-new-vm/main.tf)
```
# bash shell
md terraform & cd terraform
```
### Init terraform var.tf
+ Add variables will be used in the tf.main
+ Read more at [input-variables](https://developer.hashicorp.com/terraform/language/values/variables#input-variables)
```vi var.tf```
```ruby
variable "ssh_key" {
  description = "List of public keys for SSH access."
  type        = string
}

variable "proxmox_host" {
  description = "Proxmox host IP address or hostname."
  type        = string
}

variable "template_name" {
  description = "Name of the virtual machine template."
  type        = string
}

variable "token_id" {
  description = "Proxmox API token ID."
  type        = string
}

variable "token_secret" {
  description = "Proxmox API token secret."
  type        = string
}

variable "pm_api_url" {
  description = "URL of the Proxmox API."
  type        = string
}

variable "vm_name" {
  description = "Prefix for the virtual machine name."
  type        = string
  default     = "VM"
}

variable "vm_os" {
  description = "Prefix for the virtual machine os."
  type        = string
  default     = "Ubuntu"
}

variable "username" {
  description = "Username for the virtual machine."
  type        = string
}

variable "password" {
  description = "Password for the virtual machine"
  type        = string
}
```

### Init terraform terraform.tfvars
+ All the sensitive information should be store in the tfvars and keep secret
+ Read more at [Using terraform with proxmox](https://tcude.net/using-terraform-with-proxmox/)

```bash
# bash shell
vi terraform.tfvars```
```ruby
# Proxmox settings
proxmox_host = "YOUR_PROMOX_HOST"
template_name = "YOUR_IMAGE_TEMPLATE"
token_id = "YOUR_TOKEN_ID"
token_secret = "YOUR_TOKEN_SECRET"
pm_api_url = "https://YOUR_IP/DOMAIN:8006/api2/json"
vm_name = "YOUR_VM_NAME"
vm_os = "YOUR_VM_OS"
username = "YOUR_USERNAME"
password = "YOUR_PASSWORD"
ssh_key="YOUR_PUBLIC_KEYS"
```