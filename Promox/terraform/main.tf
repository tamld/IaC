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
  pm_api_url = "https://10.241.217.6:8006/api2/json"
  pm_api_token_id = var.token_id
  pm_api_token_secret = var.token_secret
  pm_tls_insecure = true # Disable TLS verification while connecting to the proxmox server.
  # pm_otp - (Optional; or use environment variable PM_OTP) The 2FA OTP code.
  # pm_otp = true 
  pm_log_enable = true
  pm_log_file = "crash.log"
  pm_debug = true
  pm_log_levels = {
  # export TF_LOG=TRACE
  # export TF_LOG_PATH="/Users/tamld/Documents/GitHub/IaC/Promox/terraform/crash.log" 
    _default = "debug"
    _capturelog = ""
 }
}

# resource is formatted to be "[type]" "[entity_name]" so in this case
resource "proxmox_vm_qemu" "test-server-1"  {
  count = 1 # just want 1 for now, set to 0 and apply to destroy VM
  #name = "test-vm-${count.index + 1}" #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox
  name = "test-server-1"
  target_node = var.proxmox_host
  ### Clone mode
  clone = var.template_name # The base VM from which to clone to create the new VM. Note that clone is mutually exclussive with pxe and iso modes
  ### PXE boot VM operation
  # pxe = true
  # boot = "scsi0;net0"
  # agent = 0

  ### basic VM settings here. agent refers to guest agent
  onboot = false # Whether to have the VM startup after the PVE node starts.
  oncreate = false #Whether to have the VM startup after the VM is created.
  agent = 1
  os_type = "cloud-init" #os_type options: ubuntu, centos or cloud-init
  cores = 2 #cores int 1 The number of CPU cores per CPU socket to allocate to the VM.
  sockets = 1 #sockets int 1 The number of CPU sockets to allocate to the VM.
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-pci"
  #bootdisk = "scsi0"

  disk {
    slot = 0
    # set disk size here. leave it small for testing because expanding the disk takes time.
    size = "40G"
    type = "scsi"
    storage = "zfs"
    iothread = 1
  }
  
  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    model = "virtio"
    bridge = "vmbr0"
    #bridge = "vmbr1"
  }

  # not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  # the ${count.index + 1} thing appends text to the end of the ip address
  # in this case, since we are only adding a single VM, the IP will
  # be 10.98.1.91 since count.index starts at 0. this is how you can create
  # multiple VMs and have an IP assigned to each (.91, .92, .93, etc.)

  #ipconfig0 = "ip=10.98.1.9${count.index + 1}/24,gw=10.98.1.1"
  ipconfig0 = "ip=DHCP"
  
  # sshkeys set using variables. the variable contains the text of the key.
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}