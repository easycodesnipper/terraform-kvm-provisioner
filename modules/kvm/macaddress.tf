resource "macaddress" "prefix_address" {
  for_each = toset(flatten([
    for k, v in local.vm_instances_map : [
      for n in range(v.network_spec != null ? length(v.network_spec.interfaces) : 0) :
      format("%s-nic-%d", k, n)
    ]
  ]))
  prefix = var.mac_prefix
}
