# export TF_LOG=TRACE
# export TF_LOG_PATH="/Users/tamld/Documents/GitHub/IaC/Promox/terraform/crash.log" 
#name = "test-vm-${count.index + 1}" #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox

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