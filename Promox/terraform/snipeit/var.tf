# the variable for terraform
variable "vm_vmid" {
  type        = string
  default     = 100
  description = "Starting value for vmid"
}

variable "vm_number" {
  type    = number
  default = 1
  description = "The number of VMs will be created, 0 mean destroy"
}
variable "vm_cores" {
  type    = number
  default = 1
  description = "The number of VMs CPU core"
}

variable "vm_sockets" {
  type    = number
  default = 1
  description = "The number of VMs CPU sockets"
}

variable "vm_memory" {
  type    = number
  default = 2048
  description = "The amount of VMs RAM"
}

variable "ssh_keys" {
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

variable "vm_name" {
  description = "Prefix for the virtual machine os."
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