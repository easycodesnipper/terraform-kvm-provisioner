resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each = local.vm_instances_map

  name = "${each.key}-cloudinit.iso"
  user_data = templatefile("${path.module}/template/user-data.yml.tpl", {
    instance = {
      debug_enabled = var.debug_enabled
      hostname      = each.key
      username      = each.value.username
      domain        = each.value.domain != null ? each.value.domain : "local.lan"
      packages      = var.install_packages
      timezone      = var.timezone
      os_family = (
        can(regex("^(debian)", lower(each.value.os_image))) ? "debian" :
        can(regex("^(ubuntu)", lower(each.value.os_image))) ? "ubuntu" :
        can(regex("^(fedora|centos|rhel)", lower(each.value.os_image))) ? "redhat" :
        "redhat"
      )
      data_disk_fstab = [
        for data_disk in values(local.data_disks_map) : {
          disk_index  = data_disk.disk_index
          mount_point = data_disk.mount_point
          filesystem  = data_disk.filesystem
        } if data_disk.vm_key == each.key
      ]
    }
    use_apt_mirror  = var.use_apt_mirror
    apt_mirror      = var.apt_mirror
    ssh_public_key  = file(var.ssh_public_key_path)
    package_update  = var.package_update
    package_upgrade = var.package_upgrade
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
}
