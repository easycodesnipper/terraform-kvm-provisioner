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
    target_type = "serial"
    target_port = "0"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  # Dynamically creates graphics for virtual machines
  dynamic "graphics" {
    for_each = each.value.compute_spec.gpu_enabled ? [1] : []
    content {
      type        = "spice"
      listen_type = "address"
      autoport    = true
    }
  }

  timeouts {
    create = var.domain_create_timeouts
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit[each.key].id

  qemu_agent = each.value.qemu_agent

  autostart = each.value.autostart

  # Dynamically creates network interfaces for virtual machines
  dynamic "network_interface" {
    for_each = [
      for nic in local.network_interfaces_map : nic
      if nic.vm_key == each.key
    ]

    content {
      network_name   = network_interface.value.network_name
      mac            = network_interface.value.mac_address
      wait_for_lease = true
      addresses      = network_interface.value.ipv4_address != null && length(network_interface.value.ipv4_address) > 0 ? [split("/", network_interface.value.ipv4_address)[0]] : null
    }
  }

  disk {
    volume_id = libvirt_volume.os_disk[each.key].id
  }

  # Dynamically creates data disks for virtual machines
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
