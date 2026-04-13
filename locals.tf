## locals.tf
locals {
  vm_instances_flat = flatten([
    for config_key, config in var.vm_instances : [
      for idx in range(try(config.count, 1)) : {
        vm_key         = "${config_key}-${idx + 1}"
        config_key     = config_key
        instance_index = idx

        domain       = config.profile.domain
        username     = config.profile.username
        password     = config.profile.password
        compute_spec = config.profile.compute_spec
        storage_spec = config.profile.storage_spec
        network_spec = config.profile.network_spec
        qemu_agent   = config.profile.qemu_agent
        autostart    = config.profile.autostart
        os_image     = config.profile.storage_spec.os_disk.os_image

        ipv4_address_start = try(config.profile.network_spec.ipv4_address_start, null)
        ipv4_prefix_length = try(config.profile.network_spec.ipv4_prefix_length, 24)
        gateway_default    = try(config.profile.network_spec.gateway, null)
        dns_servers_default = try(config.profile.network_spec.dns_servers, ["8.8.8.8", "8.8.4.4"])
      }
    ]
  ])

  vm_instances_map = {
    for inst in local.vm_instances_flat : inst.vm_key => inst
  }

  data_disks_flat = flatten([
    for vm_key, vm in local.vm_instances_map : [
      for disk_idx, disk in try(vm.storage_spec.data_disks, []) : {
        id          = "${vm_key}-data-disk-${disk_idx}"
        vm_key      = vm_key
        disk_index  = disk_idx
        size_gb     = disk.size_gb
        mount_point = disk.mount_point
        filesystem  = disk.filesystem
      }
    ]
  ])

  network_interfaces_flat = flatten([
    for vm_key, vm in local.vm_instances_map : [
      for nic_idx, nic in try(vm.network_spec.interfaces, []) : {
        id          = "${vm_key}-nic-${nic_idx}"
        vm_key      = vm_key
        name        = nic.name
        mac_address = coalesce(nic.mac_address, macaddress.prefix_address["${vm_key}-nic-${nic_idx}"].address)

        # Compute CIDR:
        ipv4_address = try(nic.ipv4_address, null) != null ? (
          # If explicit IP is given, check if it already contains a slash
          can(regex("/", nic.ipv4_address)) ? nic.ipv4_address : "${nic.ipv4_address}/${vm.ipv4_prefix_length}"
        ) : (
          vm.ipv4_address_start != null ? (
            format("%s/%d",
              join(".", concat(
                slice(split(".", vm.ipv4_address_start), 0, 3),
                [tostring(tonumber(element(split(".", vm.ipv4_address_start), 3)) + vm.instance_index)]
              )),
              vm.ipv4_prefix_length
            )
          ) : ""
        )

        ipv6_address = try(nic.ipv6_address, "")
        gateway      = coalesce(nic.gateway, vm.gateway_default, "")
        dns_servers  = try(nic.dns_servers, vm.dns_servers_default, ["8.8.8.8", "8.8.4.4"])
        network_name = nic.network_name
        metric       = try(nic.metric, 100)
      }
    ]
  ])

  data_disks_map = {
    for disk in local.data_disks_flat : disk.id => disk
  }

  network_interfaces_map = {
    for nic in local.network_interfaces_flat : nic.id => nic
  }
}