variable "timezone" {
  description = "System timezone configuration using tz database format"
  type        = string
  default     = "UTC"
}

variable "ssh_public_key_path" {
  description = "Local filesystem path to SSH public key for VM access"
  type        = string
  default     = "~/.ssh/id_rsa.pub" # Defaults to standard key location
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

variable "libvirt_uri" {
  description = <<-EOT
  [Required] Libvirt connection URI for KVM hypervisor management.
  Format: qemu+ssh://<user>@<host>:[port]/system
  Default: "qemu+ssh://user@localhost:22/system" (local libvirt connection)
  Example for remote host: "qemu+ssh://admin@kvm01.example.com/system"
  EOT
  type        = string
  default     = "qemu:///system"
}

variable "kvm_host" {
  description = <<-EOT
  [Required] Configuration object for KVM host infrastructure
  Default: Creates basic storage pool with NAT and bridge networks
  EOT
  type = object({
    pool = object({
      name = string
      type = string
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
  default = {
    pool = {
      name = "vm_pool"
      type = "dir"
      path = "/var/lib/libvirt/images/vm_pool"
    }
    networks = [
      # NAT network for internal connectivity
      {
        name   = "vm_nat"
        mode   = "nat"
        cidr   = ["10.0.1.0/24"]
        domain = "local.lan"
      },
      # Bridge network for external connectivity
      {
        name             = "vm_bridge"
        mode             = "bridge"
        cidr             = ["192.168.4.0/24"]
        bridge_interface = "br0" # Update with your physical interface
      }
    ]
  }
}

variable "os_images" {
  description = "OS images"
  type = map(object({
    uri     = string
    format  = string
    os_type = string # windows/linux/android
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

variable "vm_instances" {
  description = <<-EOT
  [Required] List of virtual machine configurations
  Default: Creates a basic Ubuntu VM with dual network interfaces
  EOT
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
        # os_image = object({
        #   uri     = string
        #   format  = string
        #   os_type = string # windows/linux/android
        # })
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
        mac_address  = optional(string)
        ipv4_address = optional(string)
        ipv6_address = optional(string)
        cidr_block   = optional(number, 24)
        gateway      = optional(string)
        dns_servers  = optional(list(string))
        network_name = string
      }))
    })

    qemu_agent = optional(bool, true)
    autostart  = optional(bool, false)
  }))

  default = [
    {
      name     = "vm"
      hostname = "ubuntu-server"
      domain   = "local.lan"
      username = "ubuntu"

      compute_spec = {
        cpu_cores    = 2
        memory_gb    = 2
        cpu_mode     = "host-passthrough"
        architecture = "x86_64"
        gpu_enabled  = false
      }

      storage_spec = {
        os_disk = {
          os_image = "ubuntu2204"
          size_gb  = 20
          type     = "ssd"
        }
        data_disks = [
          {
            size_gb     = 10
            mount_point = "/mnt/disk0"
          },
          {
            size_gb     = 20
            mount_point = "/mnt/disk1"
          },

        ]
      }

      network_spec = {
        interfaces = [
          # NAT interface for management
          {
            name = "eth0",
            # mac_address  = "52:54:00:ab:cd:ef",
            network_name = "vm_nat" # aligned with kvm_host.networks.name above
          },
          # Bridge interface for external access
          {
            name = "eth1",
            # mac_address  = "52:54:00:12:34:56",
            ipv4_address = "192.168.4.201"
            gateway      = "192.168.4.1",
            dns_servers  = ["8.8.8.8", "8.8.4.4"]
            network_name = "vm_bridge"
          }
        ]
      }
    }
  ]
}
