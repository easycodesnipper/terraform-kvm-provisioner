resource "libvirt_pool" "pool" {
  name = var.kvm_host.pool.name
  type = var.kvm_host.pool.type
  target {
    path = var.kvm_host.pool.path
  }
}

resource "libvirt_volume" "os_image" {
  for_each = local.vm_instances_map

  name   = replace(var.os_images[each.value.storage_spec.os_disk.os_image].uri, "/.*//", "")
  pool   = libvirt_pool.pool.name
  source = var.os_images[each.value.storage_spec.os_disk.os_image].uri
  format = var.os_images[each.value.storage_spec.os_disk.os_image].format
}

resource "libvirt_volume" "os_disk" {
  for_each = local.vm_instances_map

  name           = "${each.key}-os-disk.qcow2"
  pool           = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.os_image[each.key].id
  size           = each.value.storage_spec.os_disk.size_gb * 1073741824
  format         = "qcow2"
}

resource "libvirt_volume" "data_disks" {
  for_each = local.data_disks_map

  name   = "${each.value.vm_key}-data-disk-${each.value.disk_index}.qcow2"
  pool   = libvirt_pool.pool.name
  size   = each.value.size_gb * 1073741824
  format = "qcow2"
}
