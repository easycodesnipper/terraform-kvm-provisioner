variable "timezone" {
  description = "System timezone configuration using tz database format"
  type        = string
  default     = "UTC"
}

variable "ssh_public_key_path" {
  description = "Local filesystem path to SSH public key for VM access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "install_packages" {
  description = "List of additional system packages to install during provisioning"
  type        = list(string)
  default     = ["qemu-guest-agent"]
}

variable "package_update" {
  description = "Whether to update packages in cloud init"
  type        = bool
  default     = false
}

variable "package_upgrade" {
  description = "Whether to upgrade packages in cloud init"
  type        = bool
  default     = false
}

variable "mac_prefix" {
  description = "MAC address prefix"
  type        = list(number)
  default     = [170, 0, 4]
}

variable "debug_enabled" {
  description = "Enable verbose debugging output and preserve temporary resources"
  type        = bool
  default     = false
}

variable "os_images" {
  description = "OS images shared"
  type = map(object({
    uri     = string
    format  = optional(string, "qcow2")
    os_type = optional(string, "linux") # windows/linux/android
  }))
  default = {
    ubuntu2204 = {
      uri     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
      format  = "qcow2"
      os_type = "linux"
    },
    debian12 = {
      uri     = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-backports-genericcloud-amd64.qcow2"
      format  = "qcow2"
      os_type = "linux"
    },
    fedora43 = {
      uri     = "https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
      format  = "qcow2"
      os_type = "linux"
    }
  }
}

variable "kvm_host" {
  description = <<-EOT
  [Required] Configuration object for KVM host infrastructure
  Default: Creates basic storage pool with NAT and bridge networks
  EOT
  type = object({
    uri = string
    pool = object({
      name = optional(string, "default")
      type = optional(string, "dir")
      path = optional(string, "/var/lib/libvirt/images")
    })
    networks = list(object({
      name             = string
      mode             = string
      cidr             = optional(list(string), [])
      domain           = optional(string, "local.lan")
      bridge_interface = optional(string)
      autostart        = optional(bool, false)
    }))
  })
}

variable "vm_instances" {
  description = "VM configurations with instance counts"
  type = map(object({
    count = optional(number, 1)
    profile = object({
      domain   = optional(string, "local.lan")
      username = optional(string, "user")
      compute_spec = object({
        cpu_cores    = optional(number, 1)
        memory_gb    = optional(number, 1)
        cpu_mode     = optional(string, "host-passthrough")
        architecture = optional(string, "x86_64")
        gpu_enabled  = optional(bool, false)
      })
      storage_spec = object({
        os_disk = object({
          os_image = string
          size_gb  = optional(number, 20)
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
          network_name = string
          name         = string
          mac_address  = optional(string)
          ipv4_address = optional(string)
          ipv6_address = optional(string)
          gateway      = optional(string)
          dns_servers  = optional(list(string))
        }))
      })
      qemu_agent = optional(bool, true)
      autostart  = optional(bool, false)
    })
  }))
}
