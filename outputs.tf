## outputs.tf
output "vm_metadata" {
  description = "Map of VM names to details of their network interfaces"
  value = {
    for vm_name, vm in libvirt_domain.vm : vm_name => {
      hostname     = vm_name
      username     = local.vm_instances_map[vm_name].username
      os_image     = local.vm_instances_map[vm_name].os_image
      ip_addresses = [for addr in flatten(vm.network_interface[*].addresses) : { ip_address = addr }]
    }
  }
}

# output "debug_vm_instances_flat" {
#   value = {
#     for inst in local.vm_instances_flat : inst.vm_key => {
#       instance_index       = inst.instance_index
#       ipv4_address_start   = inst.ipv4_address_start
#       gateway_default      = inst.gateway_default
#       dns_servers_default  = inst.dns_servers_default
#       domain               = inst.domain
#       username             = inst.username
#       os_image             = inst.os_image
#       compute_spec         = inst.compute_spec
#       storage_spec_summary = {
#         os_disk_size = inst.storage_spec.os_disk.size_gb
#         data_disk_count = length(try(inst.storage_spec.data_disks, []))
#       }
#       network_spec_summary = {
#         interfaces_count = length(try(inst.network_spec.interfaces, []))
#       }
#     }
#   }
# }


# output "debug_data_disks_flat" {
#   value = {
#     for disk in local.data_disks_flat : disk.id => {
#       vm_key      = disk.vm_key
#       size_gb     = disk.size_gb
#       mount_point = disk.mount_point
#       filesystem  = disk.filesystem
#     }
#   }
# }


# output "debug_network_interfaces_flat" {
#   value = {
#     for nic in local.network_interfaces_flat : nic.id => {
#       vm_key       = nic.vm_key
#       name         = nic.name
#       ipv4_address = nic.ipv4_address
#       gateway      = nic.gateway
#       dns_servers  = nic.dns_servers
#       network_name = nic.network_name
#       mac_address  = nic.mac_address
#       metric       = nic.metric
#     }
#   }
# }


output "vm_passwords" {
  description = "Generated passwords for each VM (sensitive)"
  value = {
    for k, vm in random_password.vm_password : k => vm.result
  }
  sensitive = true
}



