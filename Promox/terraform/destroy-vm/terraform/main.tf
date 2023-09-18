# Config terraform privder plugin
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
resource "proxmox_vm_qemu" "test-server-1" {
  count = var.vm_id_max - var.vm_id_min + 1
  #name = var.vm_name
  vmid = var.vm_id_min + count.index
  delete_on_destroy = true
}