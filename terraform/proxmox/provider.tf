terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.38.1"
    }
  }
}

provider "proxmox" {
  endpoint = "https://10.10.0.210:8006/"
  username = "root@pam"
  password = var.proxmox_password
  insecure = true
}

variable "proxmox_password" {
  description = "Proxmox root password"
  type        = string
  sensitive   = true
}
