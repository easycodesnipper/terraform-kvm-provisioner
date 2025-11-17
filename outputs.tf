# outputs.tf
output "vm_metadata" {
  description = "Map of VM names to details of their network interfaces"
  value = {
    for vm_name, vm in libvirt_domain.vm : vm_name => {
      hostname       = vm_name
      username       = local.vm_instances_map[vm_name].username
      os_image       = local.vm_instances_map[vm_name].os_image
      ssh_public_key = var.ssh_public_key_path
      ip_addresses   = [for addr in flatten(vm.network_interface[*].addresses) : { ip_address = addr }]
    }
  }
}

# output "network_interfaces_flat" {
#   description = "value"
#   value = {
#     nic_flat = local.network_interfaces_flat
#   }
# }