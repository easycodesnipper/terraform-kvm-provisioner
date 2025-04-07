output "vm_network_interfaces" {
  description = "Expose child module's VM IP addresses"
  value       = module.kvm.vm_network_interfaces
}
