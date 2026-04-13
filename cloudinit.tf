## cloudinit.tf
resource "random_password" "vm_password" {
  for_each = local.vm_instances_map
  length   = 20
  special  = true

  keepers = {
    # Only regenerate if the instance name or a specific trigger changes
    instance_name = each.key
    # Optionally add a version number to force regeneration manually
    version = var.password_version
  }
}

# Create the .debug directory only if debug is enabled
resource "null_resource" "create_debug_dir" {
  count = var.debug_enabled ? 1 : 0
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/.debug"
  }
}

# Write user-data to a file for debugging (only when debug_enabled = true)
resource "local_file" "debug_user_data" {
  for_each = var.debug_enabled ? local.vm_instances_map : {}

  filename = "${path.module}/.debug/${each.key}-user-data.yaml"
  content  = templatefile("${path.module}/template/user-data.yml.tpl", {
    # Same variables as in libvirt_cloudinit_disk
    instance = {
      debug_enabled = var.debug_enabled
      hostname      = each.key
      username      = each.value.username
      hashed_passwd = bcrypt(random_password.vm_password[each.key].result, 12)   # must exist
      domain        = each.value.domain != null ? each.value.domain : "local.lan"
      packages      = var.install_packages
      timezone      = var.timezone
      os_family = (
        can(regex("^(debian)", lower(each.value.os_image))) ? "debian" :
        can(regex("^(ubuntu)", lower(each.value.os_image))) ? "ubuntu" :
        can(regex("^(fedora|centos|rhel)", lower(each.value.os_image))) ? "rhel" :
        "rhel"
      )
      data_disk_fstab = [
        for data_disk in values(local.data_disks_map) : {
          disk_index  = data_disk.disk_index
          mount_point = data_disk.mount_point
          filesystem  = data_disk.filesystem
        } if data_disk.vm_key == each.key
      ]
    }
    use_apt_mirror   = var.use_apt_mirror
    apt_mirror       = var.apt_mirror
    use_yum_mirror   = var.use_yum_mirror
    yum_mirror       = var.yum_mirror
    ssh_public_key   = file(var.ssh_public_key_path)
    package_update   = var.package_update
    package_upgrade  = var.package_upgrade
    manage_etc_hosts = var.manage_etc_hosts
  })

  depends_on = [null_resource.create_debug_dir]
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each = local.vm_instances_map

  name = "${each.key}-cloudinit.iso"
  user_data = templatefile("${path.module}/template/user-data.yml.tpl", {
    instance = {
      debug_enabled = var.debug_enabled
      hostname      = each.key # using the instance name as hostname
      username      = each.value.username
      hashed_passwd = bcrypt(random_password.vm_password[each.key].result, 12)
      domain        = each.value.domain != null ? each.value.domain : "local.lan"
      packages      = var.install_packages
      timezone      = var.timezone
      os_family = (
        can(regex("^(debian)", lower(each.value.os_image))) ? "debian" :
        can(regex("^(ubuntu)", lower(each.value.os_image))) ? "ubuntu" :
        can(regex("^(fedora|centos|rhel)", lower(each.value.os_image))) ? "rhel" :
        "rhel"
      )
      data_disk_fstab = [
        for data_disk in values(local.data_disks_map) : {
          disk_index  = data_disk.disk_index
          mount_point = data_disk.mount_point
          filesystem  = data_disk.filesystem
        } if data_disk.vm_key == each.key
      ]
    }
    use_apt_mirror   = var.use_apt_mirror
    apt_mirror       = var.apt_mirror
    use_yum_mirror   = var.use_yum_mirror
    yum_mirror       = var.yum_mirror
    ssh_public_key   = file(var.ssh_public_key_path)
    package_update   = var.package_update
    package_upgrade  = var.package_upgrade
    manage_etc_hosts = var.manage_etc_hosts
  })

  network_config = templatefile("${path.module}/template/network-config.yml.tpl", {
    interfaces = [
      for nic in values(local.network_interfaces_map) : {
        name         = nic.name
        mac_address  = nic.mac_address
        ipv4_address = nic.ipv4_address
        gateway      = nic.gateway
        dns_servers  = nic.dns_servers
        metric       = nic.metric
      } if nic.vm_key == each.key
    ]
  })
  pool = libvirt_pool.pool.name

  lifecycle {
    ignore_changes = [user_data]   # prevents replacement of the ISO after creation
  }
}
