locals {

  # VM instance map, key is "${vm.name}-${idx}", value is vm object
  vm_instances_map = {
    for idx, vm in var.vm_instances : "${vm.name}-${idx}" => vm
  }

  # Data disk flatten array
  data_disks_flat = flatten([
    for vm_key, vm in local.vm_instances_map : [
      for disk_idx, disk in try(vm.storage_spec.data_disks, []) : {
        # Unique name: "${vm.name}-${vm_idx}-data-disk-${disk_idx}"
        id          = "${vm_key}-data-disk-${disk_idx}"
        vm_key      = vm_key   # Reference back to the VM
        disk_index  = disk_idx # Index of the disk in data_disks
        size_gb     = disk.size_gb
        mount_point = disk.mount_point
        filesystem  = disk.filesystem
      }
    ]
  ])
  # Data disk map, key is "${vm.name}-${vm_idx}-data-disk-${disk_idx}"
  data_disks_map = {
    for disk in local.data_disks_flat :
    disk.id => disk
  }

  # Network intarface flatten array
  network_interfaces_flat = flatten([
    for vm_key, vm in local.vm_instances_map : [
      for nic_idx, nic in try(vm.network_spec.interfaces, []) : {
        # Unique name: "${vm.name}-${vm_idx}-nic-${nic_idx}"
        id           = "${vm_key}-nic-${nic_idx}"
        vm_key       = vm_key # Reference back to the VM
        name         = nic.name
        mac_address  = coalesce(nic.mac_address, macaddress.prefix_address[format("%s-nic-%d", vm_key, nic_idx)].address)
        ipv4_address = try(nic.ipv4_address, null)
        ipv6_address = try(nic.ipv6_address, null)
        cidr_block   = coalesce(nic.cidr_block, 24)
        gateway      = try(nic.gateway, null)
        dns_servers  = coalesce(nic.dns_servers, ["8.8.8.8", "8.8.4.4"])
        network_name = nic.network_name
      }
    ]
  ])
  # Network intarface map
  network_interfaces_map = {
    for nic in local.network_interfaces_flat :
    nic.id => nic
  }

}
