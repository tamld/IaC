# Config terraform privder plugin
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
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

# resource is formatted to be "[type]" "[entity_name]" so in this case
resource "proxmox_vm_qemu" "test-server-1"  {
  count = 1 # 1 = keep while 0 = destroy
  name         = "test-vm"
  target_node = var.proxmox_host
  ### Clone mode
  clone = var.template_name
  #full_clone = true # if fales, it will use link clone instead of full clone
  
  ### PXE boot VM operation
  # pxe = true
  # boot = "scsi0;net0"
  # agent = 0

  ### basic VM settings here. agent refers to guest agent
  onboot = false # Whether to have the VM startup after the PVE node starts.
  oncreate = true #Whether to have the VM startup after the VM is created.
  agent = 1 
  os_type = "cloud-init" #os_type options: ubuntu, centos or cloud-init
  cores = 2 #cores int 1 The number of CPU cores per CPU socket to allocate to the VM.
  sockets = 1 #sockets int 1 The number of CPU sockets to allocate to the VM.
  memory = 2048
  network {
    model = "virtio"
    bridge = "vmbr1"
  } 
    # virtio-scsi-pci (high perfomance mode), virtio-scsi-single, lsi (compatible mode)
    scsihw = "virtio-scsi-pci" # for high perfomance disk
  disk {
    type = "scsi"
    storage = "zfs"
    size = "40G"
    #format = "qcow2"
    backup = true
  }
  ###
  lifecycle {
  ignore_changes = [disk, network]
  }
  ####################
  #Network setting
  # the ${count.index + 1} thing appends text to the end of the ip address
  # in this case, since we are only adding a single VM, the IP will
  # be 10.98.1.91 since count.index starts at 0. this is how you can create
  # multiple VMs and have an IP assigned to each (.91, .92, .93, etc.)

  #ipconfig0 = "ip=10.98.1.9${count.index + 1}/24,gw=10.98.1.1"
  ipconfig0 = "ip=dhcp"
  
  # sshkeys set using variables. the variable contains the text of the key.
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}