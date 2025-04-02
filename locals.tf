locals {
  vm_mac_addresses = [for i in range(var.vm_count) :
    format(var.vm_mac_format, i, 0, 1)
  ]

  # Get the first key from vm_base_images if vm_os is empty(not specified)
  default_os = contains(keys(var.vm_base_images), "ubuntu") ? "ubuntu" : keys(var.vm_base_images)[0] # Fallback if base_images is empty

  # Final OS list: use provided vm_os or default to [default_os, default_os, ...]
  final_vm_os = length(var.vm_os) > 0 ? var.vm_os : [for _ in range(var.vm_count) : local.default_os]

  # Final vcpu counts
  final_vcpu_counts = length(var.vcpu_counts) > 0 ? var.vcpu_counts : [for _ in range(var.vm_count) : 1]

  final_memory_in_mb = length(var.memory_in_mb) > 0 ? var.memory_in_mb : [for _ in range(var.vm_count) : 1024]
}
