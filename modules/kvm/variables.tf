variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "install_packages" {
  description = "Additional packages to install"
  type        = list(string)
  default     = ["qemu-guest-agent"]
}

variable "package_upgrade" {
  description = "Whether to upgrade os in cloud init"
  type        = bool
  default     = false
}

variable "timezone" {
  description = "Timezone to configure"
  type        = string
  default     = "UTC"
}

variable "mac_prefix" {
  type    = list(number)
  default = [170, 0, 4]
}

variable "debug_enabled" {
  description = "Flag to be used to debug"
  type        = bool
  default     = false
}

variable "kvm_host" {
  type = object({

    pool = object({
      name = string
      type = string
      path = string
    })

    networks = list(object({
      name             = string
      mode             = string # nat or bridge
      cidr             = list(string)
      domain           = optional(string)
      bridge_interface = optional(string)
      autostart        = optional(bool, false)
    }))
  })
}

variable "os_images" {
  description = "OS images"
  type = map(object({
    uri     = string
    format  = string
    os_type = string # windows/linux/android
  }))
}

variable "vm_instances" {
  type = list(object({
    name     = string
    hostname = string
    domain   = optional(string)
    username = string

    compute_spec = object({
      cpu_cores    = number
      memory_gb    = number
      cpu_mode     = optional(string, "host-passthrough")
      architecture = optional(string, "x86_64")
      gpu_enabled  = optional(bool, false)
      gpu_type     = optional(string)
    })

    storage_spec = object({
      os_disk = object({
        os_image = string
        size_gb  = number
        type     = optional(string, "ssd")
      })

      data_disks = optional(list(object({
        size_gb     = number
        mount_point = string
        filesystem  = optional(string, "ext4")
      })), [])
    })

    network_spec = object({
      interfaces = list(object({
        name         = string
        mac_address  = string
        ipv4_address = optional(string)
        ipv6_address = optional(string)
        cidr_block   = optional(string)
        gateway      = optional(string)
        dns_servers  = optional(list(string))
        network_name = string
      }))
    })

    qemu_agent = optional(bool, true)
    autostart  = optional(bool, false)
  }))
}
