terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  alias = "kvm" # Must match a key in your var.kvm_host_vm_instances
  uri   = var.libvirt_uri
}

module "kvm" {
  source = "./modules/kvm"
  providers = {
    libvirt = libvirt.kvm # Static reference to one of your provider aliases
  }
  kvm_host            = var.kvm_host
  vm_instances        = var.vm_instances
  os_images           = var.os_images
  ssh_public_key_path = var.ssh_public_key_path
  install_packages    = var.install_packages
  package_upgrade     = var.package_upgrade
  timezone            = var.timezone
  mac_prefix          = var.mac_prefix
  debug_enabled       = var.debug_enabled
}
