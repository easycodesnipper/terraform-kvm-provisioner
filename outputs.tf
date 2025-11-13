# Child module outputs.tf
output "vm_network_interfaces" {
  description = "Map of VM names to details of their network interfaces"
  value = {
    for vm_name, vm in libvirt_domain.vm : vm_name => [
      for nic in vm.network_interface : {
        ip = nic.addresses[0]
      }
  ] }
}
