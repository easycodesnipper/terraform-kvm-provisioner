resource "libvirt_domain" "vm" {
  for_each = local.vm_instances_map

  name   = each.key
  vcpu   = each.value.compute_spec.cpu_cores
  memory = each.value.compute_spec.memory_gb * 1024

  cpu {
    mode = each.value.compute_spec.cpu_mode
  }

  arch = each.value.compute_spec.architecture

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  dynamic "graphics" {
    for_each = each.value.compute_spec.gpu_enabled ? [1] : []
    content {
      type        = "spice"
      listen_type = "address"
      autoport    = true
    }
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit[each.key].id

  qemu_agent = each.value.qemu_agent

  autostart = each.value.autostart

  dynamic "network_interface" {
    for_each = [
      for nic in local.network_interfaces_map : nic
      if nic.vm_key == each.key
    ]

    content {
      network_name   = network_interface.value.network_name # here `network_interface` represents local.network_interfaces_map's entry
      mac            = network_interface.value.mac_address
      wait_for_lease = true
    }
  }

  disk {
    volume_id = libvirt_volume.os_disk[each.key].id
  }

  dynamic "disk" {
    for_each = {
      for disk_key, disk in local.data_disks_map : disk_key => disk
      if disk.vm_key == each.key
    }

    content {
      volume_id = libvirt_volume.data_disks[disk.key].id
    }
  }
}
