resource "libvirt_network" "vm_network" {
  name   = "${var.network_name}-${var.network_mode}"
  mode   = var.network_mode
  domain = var.network_mode == "nat" ? var.vm_domain : null

  # Bridge configuration (only for bridge mode)
  bridge = var.network_mode == "bridge" ? var.bridge_interface : null

  # NAT configuration (only for nat mode)
  addresses = var.network_mode == "nat" ? [var.nat_network_cidr] : null

  dhcp {
    enabled = var.network_mode == "nat" ? true : var.dhcp_enabled
  }

  dns {
    enabled    = var.dns_enabled
    local_only = var.dns_local_only
  }
}
