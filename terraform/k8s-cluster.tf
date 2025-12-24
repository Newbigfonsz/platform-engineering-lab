############################################
# Kubernetes Cluster on Proxmox (Brownfield)
# Managed safely with Terraform
############################################


############################################
# Variables
############################################

variable "k8s_nodes" {
  description = "Kubernetes cluster nodes"
  type = map(object({
    vmid   = number
    name   = string
    cores  = number
    memory = number
    ip     = string
    role   = string
  }))

  default = {
    cp01 = {
      vmid   = 103
      name   = "k8s-cp01"
      cores  = 2
      memory = 4096
      ip     = "10.10.0.103"
      role   = "control-plane"
    }

    worker01 = {
      vmid   = 104
      name   = "k8s-worker01"
      cores  = 2
      memory = 4096
      ip     = "10.10.0.104"
      role   = "worker"
    }

    worker02 = {
      vmid   = 105
      name   = "k8s-worker02"
      cores  = 2
      memory = 4096
      ip     = "10.10.0.105"
      role   = "worker"
    }
  }
}

############################################
# Locals (used by outputs + integrations)
############################################

locals {
  control_plane_ip = var.k8s_nodes["cp01"].ip

  worker_ips = [
    for k, v in var.k8s_nodes :
    v.ip if v.role == "worker"
  ]
}

############################################
# Proxmox VMs (Imported / Brownfield)
############################################

resource "proxmox_virtual_environment_vm" "k8s_node" {
  for_each = var.k8s_nodes

  name      = each.value.name
  node_name = "pve"
  vm_id     = each.value.vmid

  # CPU & Memory (observed, not enforced)
  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  # Cloud-init (existing state observed)
  initialization {
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = "10.10.0.1"
      }
    }

    user_account {
      username = "ubuntu"
      password = "ApexJonesJr2026!"
      keys     = [file(pathexpand("~/.ssh/id_ed25519.pub"))]
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "tank-vmstore"
    interface    = "scsi0"
    size         = 32
  }

  tags = [each.value.role]

  # ----------------------------------------
  # Lifecycle Protection (CRITICAL)
  # ----------------------------------------
  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      initialization,
      disk,
      network_device,
      cpu,
      memory,
      agent,
      vga,
      serial_device,
      operating_system,
      keyboard_layout,
      on_boot,
    ]
  }
}

############################################
# Outputs (Terraform as a Platform API)
############################################

output "k8s_inventory" {
  description = "Kubernetes node inventory"
  value = {
    for k, v in proxmox_virtual_environment_vm.k8s_node :
    k => {
      name = v.name
      ip   = var.k8s_nodes[k].ip
      role = var.k8s_nodes[k].role
    }
  }
}

output "k8s_control_plane_ip" {
  description = "Control-plane IP"
  value       = local.control_plane_ip
}

output "k8s_worker_ips" {
  description = "Worker node IPs"
  value       = local.worker_ips
}

############################################
# Integration Example: Ansible Inventory
############################################

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"

  content = <<EOF
[k8s_control_plane]
${local.control_plane_ip}

[k8s_workers]
%{for ip in local.worker_ips~}
${ip}
%{endfor}

[k8s:children]
k8s_control_plane
k8s_workers
EOF
}


# Safety: Prevent accidental VM destruction
# To destroy, you must first remove this lifecycle block
