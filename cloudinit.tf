resource "libvirt_cloudinit_disk" "vm_init" {
  count = var.vm_count
  name  = "${var.vm_hostname_prefix}-${count.index}-cloudinit.iso"
  pool  = libvirt_pool.vm_pool.name

  user_data = templatefile("${path.module}/config/user-data.yml", {
    hostname       = "${var.vm_hostname_prefix}-${count.index}"
    domain         = var.vm_domain
    username       = var.vm_username
    ssh_public_key = file(var.ssh_public_key_path)
    packages       = concat(["qemu-guest-agent"], var.vm_packages)
    timezone       = var.vm_timezone
    debug_enabled  = var.debug_enabled
  })

  network_config = templatefile("${path.module}/config/network-config.yml", {
    interface_name = var.vm_interface != "" ? var.vm_interface : "eth${count.index}"
    mac_address    = local.vm_mac_addresses[count.index]
    dhcp_enabled   = var.network_mode == "nat" ? true : var.dhcp_enabled
    static_ip      = local.final_static_ips[count.index]
    gateway_ip     = var.gateway_ip
    dns_servers    = var.dns_servers
  })
}

