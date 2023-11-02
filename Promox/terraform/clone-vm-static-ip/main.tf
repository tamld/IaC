# Config terraform privder plugin
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}
# Get NextID Values
data "external" "nextid" {
  # program = ["bash", "-c", "ssh proxmox pvesh get /cluster/nextid"]
  program = ["bash", "-c", "echo -n '{\"data\":\"' && ssh proxmox pvesh get /cluster/nextid | tr -d '\n' && echo -n '\"}'"]
}


# Proxmox config
provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_api_token_id = var.token_id
  pm_api_token_secret = var.token_secret
  pm_tls_insecure = true # Disable TLS verification while connecting to the proxmox server.
  # pm_otp - (Optional; or use environment variable PM_OTP) The 2FA OTP code.
  # pm_otp = true 
  pm_log_enable = true
  pm_log_file = "crash.log"
  pm_debug = true
  pm_log_levels = {
    _default = "debug"
    _capturelog = ""
 }
}
#resource is formatted to be "[type]" "[entity_name]" so in this case
resource "proxmox_vm_qemu" "test-server-1"  {
  count = var.vm_number
  name        = "${var.vm_name}-${data.external.nextid.result["data"] + count.index}"
  target_node = var.proxmox_host
  clone = var.template_name
  onboot = false # Whether to have the VM startup after the PVE node starts.
  oncreate = true #Whether to have the VM startup after the VM is created.
  agent = 1 
  os_type = "cloud-init" #os_type options: ubuntu, centos or cloud-init
  cores = var.vm_cores
  sockets = var.vm_sockets
  memory = var.vm_memory
  network {
    model = "virtio"
    bridge = "vmbr0"
  } 
  # ipconfig0 = "ip=dhcp"
  ipconfig0 = "ip=${var.ip_address}/${var.subnet_mask},gw=${var.gateway}"
  
  #virtio-scsi-pci (high perfomance mode), virtio-scsi-single, lsi (compatible mode)
  scsihw = "virtio-scsi-pci" # for high perfomance disk
  
  disk {
    type = "scsi"
    storage = "zfs"
    size = "80G"
    backup = true
  }

  lifecycle {
    ignore_changes = [disk, network]
  }
  
  ## Username, password, ssh
  ciuser     = var.username
  cipassword = var.password

  sshkeys = join("\n", var.ssh_keys)

  timeouts {
      create = "5m"
      update = "5m"
      delete = "3m"
  }
  # provisioner "local-exec" {
  #   command = "ansible-playbook -i ansible/inventory.ini ansible/playbook.yml"
  # }
  provisioner "local-exec" {
    command = <<EOF
  echo "${var.ip_address} ansible_user=${var.username}" > ansible/inventory.ini
  ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
  EOF
  }
}