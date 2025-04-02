###
### Provider Variables
###
variable "libvirt_uri" {
  description = <<-EOT
    Libvirt connection URI. Examples:
    - Local: "qemu:///system"
    - Remote SSH: "qemu+ssh://user@host.example.com/system"
    - Remote TLS: "qemu+tls://host.example.com/system"
  EOT
  type        = string
  default     = "qemu:///system" # Default to local connection
  validation {
    condition     = can(regex("^(qemu\\+?(ssh|tcp|tls))?://.*", var.libvirt_uri))
    error_message = "Invalid Libvirt URI format. Use qemu://, qemu+ssh://, qemu+tcp://, or qemu+tls://"
  }
}

###
### Storage Variables
###
variable "storage_pool_name" {
  description = "Name of the storage pool"
  type        = string
  default     = "vm-pool"
}

variable "storage_pool_path" {
  description = "Path for directory-based storage pools"
  type        = string
  default     = "/var/lib/libvirt/images/vm-pool"
}

variable "storage_pool_type" {
  description = "Type of storage pool"
  type        = string
  default     = "dir"
}

variable "boot_disk_in_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 10
}

variable "data_disk_in_gb" {
  description = "Data disk size in GB"
  type        = number
  default     = 20
}

###
### Network Variables
###
variable "network_mode" {
  description = "Network mode (bridge or nat)"
  type        = string
  default     = "nat"
  validation {
    condition     = contains(["bridge", "nat"], var.network_mode)
    error_message = "Must be either 'bridge' or 'nat'"
  }
}

variable "network_name" {
  description = "Network name"
  type        = string
  default     = "vm-net"
}

variable "bridge_interface" {
  description = "Physical host bridge interface (e.g., br0)"
  type        = string
  default     = "br0"
  validation {
    condition     = var.network_mode != "bridge" || (var.bridge_interface != "" && can(regex("^[a-z0-9]+$", var.bridge_interface)))
    error_message = "Bridge mode requires valid interface name (e.g., br0)"
  }
}

variable "bridge_network_cidr" {
  description = "Physical network CIDR (e.g., 192.168.4.0/24)"
  type        = string
  default     = "192.168.4.0/24"
  validation {
    condition     = var.network_mode != "bridge" || can(cidrhost(var.bridge_network_cidr, 0))
    error_message = "Valid CIDR required for bridge mode"
  }
}

variable "gateway_ip" {
  description = "Default gateway IP for bridge mode"
  type        = string
  default     = "192.168.4.1"
  validation {
    condition     = var.network_mode != "bridge" || (var.gateway_ip != "" && can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.gateway_ip)))
    error_message = "Valid IPv4 gateway required for bridge mode"
  }
}

variable "static_ips" {
  description = "List of static IPs to assign to VMs. If provided, must match vm_count in length."
  type        = list(string)
  default     = [] # Empty list means use calculated IPs
  validation {
    condition     = var.network_mode != "bridge" || length(var.static_ips) >= var.vm_count
    error_message = "If static_ips is provided, the number of IPs must match vm_count (${var.vm_count})."
  }
}

variable "static_ip_start" {
  description = "Starting IP offset for static assignment"
  type        = number
  default     = 100
  validation {
    condition     = var.network_mode != "bridge" || (var.static_ip_start >= 2 && var.static_ip_start <= 253)
    error_message = "Static IP must be between 2-253"
  }
}

variable "dns_servers" {
  description = "Upstream DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
  validation {
    condition     = alltrue([for ip in var.dns_servers : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))])
    error_message = "All DNS servers must be valid IPv4 addresses"
  }
}

variable "dhcp_enabled" {
  type        = bool
  default     = false
  description = "Disable DHCP (for bridge mode)"
}

## NAT Mode Variables
variable "nat_network_cidr" {
  description = "NAT network CIDR range"
  type        = string
  default     = "10.17.3.0/24"
  validation {
    condition     = var.network_mode != "nat" || can(cidrhost(var.nat_network_cidr, 0))
    error_message = "Valid CIDR required for NAT mode"
  }
}

variable "dns_enabled" {
  type        = bool
  default     = true
  description = "Enable DNS (for nat mode)"
}

variable "dns_local_only" {
  type        = bool
  default     = true
  description = "Restrict DNS to local network"
}

###
### Compute Variables
###
variable "vcpu_counts" {
  description = "Array of vCPU counts for each VM"
  type        = list(number)
  default     = [] # Empty array means "use defaults"
  validation {
    condition = alltrue([
      for c in var.vcpu_counts : c > 0 && c <= 32 # Adjust max as needed
    ])
    error_message = "Each vCPU count must be between 1 and 32."
  }
  validation {
    condition     = length(var.vcpu_counts) >= var.vm_count
    error_message = "If vcpu_counts is provided, the number must match vm_count (${var.vm_count})."
  }
}

variable "memory_in_mb" {
  description = "Array of memory allocation in MB for each VM"
  type        = list(number)
  default     = [] # Empty array means "use defaults"
  validation {
    condition = alltrue([
      for m in var.memory_in_mb : m >= 512 && m <= 65536 # 512MB min, 64GB max
    ])
    error_message = "Each memory value must be between 512 and 65536 MB."
  }
  validation {
    condition     = length(var.memory_in_mb) >= var.vm_count
    error_message = "If memory_in_mb is provided, the number must match vm_count (${var.vm_count})."
  }
}

variable "cpu_mode" {
  description = "CPU mode"
  type        = string
  default     = "host-passthrough"
}

###
### VirtualMachine Variables
###
variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 3
  validation {
    condition     = var.vm_count > 0
    error_message = "VM count must be at least 1."
  }
}

variable "vm_os" {
  description = "List of OS types for each VM (empty = use first available base image)"
  type        = list(string)
  default     = [] # Empty by default
}

variable "vm_base_images" {
  description = "Map of OS names to their base image configurations"
  type = map(object({
    uri    = string
    format = string
  }))
  default = {
    ubuntu = {
      uri    = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
      format = "qcow2"
    },
    debian = {
      uri    = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
      format = "qcow2"
    },
    fedora = {
      uri    = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"
      format = "qcow2"
    }
  }
}

variable "vm_create_timeout" {
  description = "Timeout to wait for vm creation (for lease + boot)"
  type        = string
  default     = "10m"
}

variable "vm_domain" {
  description = "Domain name of VM"
  type        = string
  default     = "vm.local"
}

variable "vm_mac_format" {
  description = "Mac address format of VM"
  type        = string
  default     = "52:54:00:%02x:%02x:%02x"
}

variable "vm_interface" {
  description = "Network interface name of VM"
  type        = string
  default     = ""
}

variable "vm_hostname_prefix" {
  description = "Prefix for VM hostnames"
  type        = string
  default     = "vm"
}

variable "vm_username" {
  description = "Default username for the VMs"
  type        = string
  default     = "user"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_packages" {
  description = "Additional packages to install"
  type        = list(string)
  default     = []
}

variable "vm_timezone" {
  description = "Timezone to configure"
  type        = string
  default     = "UTC"
}

variable "vm_custom_commands" {
  description = "Custom commands to run"
  type        = list(string)
  default     = []
}

variable "debug_enabled" {
  description = "Flag to be used to debug"
  type        = bool
  default     = false
}