terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">=0.8.3"
    }

    macaddress = {
      source  = "ivoronin/macaddress"
      version = ">= 0.3.2"
    }
  }
}
