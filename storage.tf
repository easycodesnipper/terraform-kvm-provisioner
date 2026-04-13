## storage.tf
locals {
  used_os_image_names = distinct([
    for vm in local.vm_instances_map : vm.storage_spec.os_disk.os_image
  ])

  filtered_os_images = {
    for name in local.used_os_image_names :
    name => var.os_images[name]
  }
}

resource "libvirt_pool" "pool" {
  name = var.kvm_host.pool.name
  type = var.kvm_host.pool.type
  target {
    path = var.kvm_host.pool.path
  }
}

resource "libvirt_volume" "base_image" {
  for_each = local.filtered_os_images

  name   = "${each.key}-base.qcow2"
  pool   = libvirt_pool.pool.name
  source = each.value.uri
  format = each.value.format
}

resource "libvirt_volume" "os_disk" {
  for_each = local.vm_instances_map

  name           = "${each.key}-os-disk.qcow2"
  pool           = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.base_image[each.value.storage_spec.os_disk.os_image].id
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
