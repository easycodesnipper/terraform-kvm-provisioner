output "vm_metadata" {
  description = "Complete metadata of the created VMs"
  value = [for idx, vm in libvirt_domain.vm : {
    ip_address = try(vm.network_interface[0].addresses[0], "DHCP_PENDING")
    hostname   = "${var.vm_hostname_prefix}-${idx}"
    os_type    = local.final_vm_os[idx]
    vcpus      = vm.vcpu
    memory     = vm.memory
  }]
}