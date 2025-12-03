resource "proxmox_vm_qemu" "test" {
  name        = "test-vm"
  target_node = "pve"
  clone       = "ubuntu-template"
  vmid        = 200
  
  agent    = 1
  cores    = 2
  sockets  = 1
  memory   = 2048
  
  # Older provider uses 'disk' (singular) not 'disks'
  disk {
    slot    = 0
    size    = "20G"
    storage = "tank-vmstore"
    type    = "scsi"
  }
  
  # Older provider doesn't need 'id' field
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  ipconfig0 = "ip=dhcp"
  
  sshkeys = file("~/.ssh/id_ed25519.pub")
}

output "test_vm_info" {
  value = "VM ${proxmox_vm_qemu.test.name} created with ID ${proxmox_vm_qemu.test.vmid}"
}
