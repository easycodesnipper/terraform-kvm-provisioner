locals {

  vm_instances_flat = flatten([
    for config_key, config in var.vm_instances : [
      for instance_idx in range(try(config.count, 1)) : {
        vm_key         = "${config_key}-${instance_idx}"
        config_key     = config_key
        instance_index = instance_idx
        profile        = config.profile
        domain         = config.profile.domain
        username       = config.profile.username
        compute_spec   = config.profile.compute_spec
        storage_spec   = config.profile.storage_spec
        network_spec   = config.profile.network_spec
        qemu_agent     = config.profile.qemu_agent
        autostart      = config.profile.autostart
      }
    ]
  ])

  # VM instance map, key is "${config_key}-${instance_idx}", value is expanded vm object
  vm_instances_map = {
    for instance in local.vm_instances_flat :
    instance.vm_key => instance
  }

  # Data disk flatten array
  data_disks_flat = flatten([
    for vm_key, vm in local.vm_instances_map : [
      for disk_idx, disk in try(vm.storage_spec.data_disks, []) : {
        # Unique name: "${vm_key}-data-disk-${disk_idx}"
        id          = "${vm_key}-data-disk-${disk_idx}"
        vm_key      = vm_key   # Reference back to the VM
        disk_index  = disk_idx # Index of the disk in data_disks
        size_gb     = disk.size_gb
        mount_point = disk.mount_point
        filesystem  = disk.filesystem
      }
    ]
  ])

  # Data disk map, key is "${vm_key}-data-disk-${disk_idx}"
  data_disks_map = {
    for disk in local.data_disks_flat :
    disk.id => disk
  }

  # Network interface flatten array
  network_interfaces_flat = flatten([
    for vm_key, vm in local.vm_instances_map : [
      for nic_idx, nic in try(vm.network_spec.interfaces, []) : {
        # Unique name: "${vm_key}-nic-${nic_idx}"
        id           = "${vm_key}-nic-${nic_idx}"
        vm_key       = vm_key # Reference back to the VM
        name         = nic.name
        mac_address  = coalesce(nic.mac_address, macaddress.prefix_address[format("%s-nic-%d", vm_key, nic_idx)].address)
        ipv4_address = try(nic.ipv4_address, "")
        ipv6_address = try(nic.ipv6_address, "")
        gateway      = try(nic.gateway, "")
        dns_servers  = try(nic.dns_servers, ["8.8.8.8", "8.8.4.4"])
        network_name = nic.network_name
        metric       = try(nic.metric, 100)
      }
    ]
  ])

  # Network interface map
  network_interfaces_map = {
    for nic in local.network_interfaces_flat :
    nic.id => nic
  }

}
