# the variable for terraform
variable "vm_vmid" {
  type    = list(string)
  default = ["1","2","3","4","5","6"]
  description = "Define value for vmid"
}
variable "vm_number" {
  type    = number
  default = 1
  description = "The number of VMs will be created"
}
variable "ssh_key" {
  description = "List of public keys for SSH access."
  type        = string
}

variable "public_keys" {
  description = "List of public SSH keys"
  type        = list(string)
  default     = []
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