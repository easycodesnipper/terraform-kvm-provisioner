resource "libvirt_domain" "vm" {
  count  = var.vm_count
  name   = "${var.vm_hostname_prefix}-${count.index}"
  memory = local.final_memory_in_mb[count.index]
  vcpu   = local.final_vcpu_counts[count.index]

  cpu {
    mode = var.cpu_mode
  }

  cloudinit = libvirt_cloudinit_disk.vm_init[count.index].id

  timeouts {
    create = var.vm_create_timeout # time for (lease + boot)
  }

  network_interface {
    network_id     = libvirt_network.vm_network.id
    hostname       = "${var.vm_hostname_prefix}-${count.index}"
    mac            = local.vm_mac_addresses[count.index]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.boot_disk[count.index].id
  }

  disk {
    volume_id = libvirt_volume.data_disk[count.index].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  qemu_agent = var.network_mode == "bridge" ? true : false
}
