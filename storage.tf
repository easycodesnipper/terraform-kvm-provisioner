# Pool
resource "libvirt_pool" "vm_pool" {
  name = var.storage_pool_name
  type = var.storage_pool_type
  path = var.storage_pool_type == "dir" ? var.storage_pool_path : null
}

# Create base images for all needed OSes
resource "libvirt_volume" "base_images" {
  for_each = { for os in distinct(local.final_vm_os) : os => var.vm_base_images[os] }

  name   = basename(each.value.uri)
  pool   = libvirt_pool.vm_pool.name
  source = each.value.uri
  format = each.value.format
}

# Boot disk (OS disk)
resource "libvirt_volume" "boot_disk" {
  count          = var.vm_count
  name           = "${var.vm_hostname_prefix}-${count.index}-boot.qcow2"
  base_volume_id = libvirt_volume.base_images[local.final_vm_os[count.index]].id
  pool           = libvirt_pool.vm_pool.name
  format         = "qcow2"
  size           = var.boot_disk_in_gb * 1073741824
}

# Data disk
resource "libvirt_volume" "data_disk" {
  count  = var.vm_count
  name   = "${var.vm_hostname_prefix}-${count.index}-data.qcow2"
  pool   = libvirt_pool.vm_pool.name
  format = "qcow2"
  size   = var.data_disk_in_gb * 1073741824
}
