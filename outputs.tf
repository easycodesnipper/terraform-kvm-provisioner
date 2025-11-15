# outputs.tf
output "vm_metadata" {
  description = "Map of VM names to details of their network interfaces"
  value = {
    for vm_name, vm in libvirt_domain.vm : vm_name => merge(
      {
        name           = vm_name
        username       = local.vm_instances_map[vm_name].username
        os_image       = local.vm_instances_map[vm_name].os_image
        ssh_public_key = var.ssh_public_key_path
      },
      {
        ip_addresses = [
          for nic in vm.network_interface : {
            ip = length(nic.addresses) > 0 ? nic.addresses[0] : null
          }
        ]
      }
    )
  }
}

# output "local_vm_instances_flat" {
#   description = "vm_instances_flat"
#   value = {
#     flat = local.vm_instances_flat
#   }
# }