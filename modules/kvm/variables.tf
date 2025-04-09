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

variable "package_upgrade" {
  description = "Whether to upgrade os in cloud init"
  type        = bool
  default     = false
}

variable "mac_prefix" {
  type    = list(number)
  default = [170, 0, 4]
}

variable "debug_enabled" {
  description = "Enable verbose debugging output and preserve temporary resources"
  type        = bool
  default     = true
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
      uri     = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
      format  = "qcow2"
      os_type = "linux"
    },
    fedora41 = {
      uri     = "https://dl.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2"
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
    pool = object({
      name = string
      type = optional(string, "dir")
      path = string
    })
    networks = list(object({
      name             = string
      mode             = string
      cidr             = list(string)
      domain           = optional(string)
      bridge_interface = optional(string)
      autostart        = optional(bool, false)
    }))
  })
}

variable "vm_instances" {
  description = <<-EOT
  [Required] List of virtual machine configurations
  Default: Creates a basic Ubuntu VM with dual network interfaces
  EOT
  type = list(object({
    name     = optional(string, "vm")
    domain   = optional(string, "local.lan")
    username = optional(string, "user")

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
        network_name = string
        name         = string
        mac_address  = optional(string)
        ipv4_address = optional(string)
        ipv6_address = optional(string)
        cidr_block   = optional(number, 24)
        gateway      = optional(string)
        dns_servers  = optional(list(string))
      }))
    })
    qemu_agent = optional(bool, true)
    autostart  = optional(bool, false)
  }))
}
