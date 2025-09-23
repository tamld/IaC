// Minimal Terraform example for cloning a Proxmox VM template
// This file is intentionally minimal and contains no secrets.
// Fill variables via terraform.tfvars or environment variables as appropriate.

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_api_token_id = var.token_id
  pm_api_token_secret = var.token_secret
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "clone_vm" {
  name        = "${var.vm_name}-${count.index + var.vm_vmid}"
  target_node = var.proxmox_host
  clone       = var.template_name
  count       = var.vm_number
  cores       = var.vm_cores
  memory      = var.vm_memory
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  ipconfig0 = "ip=dhcp"
  disk {
    type    = "scsi"
    storage = "zfs"
    size    = "40G"
  }
  ciuser     = var.username
  cipassword = var.password
  sshkeys    = join("\n", var.ssh_keys)
}
