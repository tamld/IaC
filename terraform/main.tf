# Proxmox Provider
provider "proxmox" {
  pm_api_url = "https://192.168.100.71:8006/api2/json"
  pm_user    = "root@pam"
  pm_password = "abc@123"
  pm_tls_insecure = true
}

# ZFS Declare
resource "proxmox_storage_zfs" "storage" {
name = "rpool/data"
nodes = ["pve"]
zpool = "rpool"
}

# Container Info
resource "proxmox_lxc" "example_ct" {
  name       = "ubuntu-ct"
  target_node = "pve"
  ostemplate = "local:vztmpl/ubuntu-20.04-custom.tar.gz"  # Đường dẫn đến file template của Ubuntu
  storage    = proxmox_storage_zfs.zfs_storage.id  # Sử dụng lưu trữ ZFS
  password   = "your_container_password_here"  # Đặt mật khẩu cho container
  memory     = 1024  # Dung lượng bộ nhớ cho container
  cores      = 1     # Số lõi CPU
  swap       = 512   # Dung lượng swap cho container
  rootfs_size = 10G   # Dung lượng ổ cứng cho container
  net        = "name=eth0,bridge=vmbr0"  # Cấu hình mạng cho container
}






Storage chung cho các VM/CT


Template Ubuntu
data "local_file" "ubuntu_tmpl" {
filename = "/var/lib/vz/template/cache/ubuntu-22.04-standard_22.04-1_amd64.tar.gz"
}

Tạo container 1
resource "proxmox_lxc" "container_1" {
name = "ubuntu-ct1"
target_node = "pve"

ostemplate = data.local_file.ubuntu_tmpl.filename

storage {
content_type = "block"
type = "zfs"
name = "subvol-ct1-disk1"
zpool = proxmox_storage_zfs.storage.name
}

memory = 1024
cores = 1
rootfs_size = "10G"

network {
model = "virtio"
bridge = "vmbr0"
}

ips = ["192.168.1.100/24"]
}

Output id và disk number
output "ct1_id" {
value = proxmox_lxc.container_1.id
}

output "ct1_disk" {
value = proxmox_lxc.container_1.root_disk
}


#terraform init 
#terraform plan
#terraform apply