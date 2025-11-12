resource "libvirt_network" "networks" {
  for_each = {
    for net in var.kvm_host.networks : net.name => net
  }

  name      = each.value.name
  mode      = each.value.mode
  domain    = each.value.mode == "nat" ? each.value.domain : null
  bridge    = each.value.mode == "bridge" ? each.value.bridge_interface : null
  addresses = each.value.mode == "nat" ? each.value.cidr : null
  dhcp {
    enabled = each.value.mode == "nat" ? true : false
  }
  dns {
    enabled    = true
    local_only = true
  }

  autostart = each.value.autostart
}
