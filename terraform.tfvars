# terraform.tfvars

# Libvirt connection URI (can be updated for remote hosts)
libvirt_uri = "qemu:///system"
# libvirt_uri = "qemu+ssh://user@localhost:22/system"

# KVM host infrastructure configuration
kvm_host = {
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
    # Bridge network (update bridge_interface to match your host)
    {
      name             = "vm_bridge"
      mode             = "bridge"
      cidr             = ["192.168.4.0/24"]
      bridge_interface = "br0" # Replace with your host's bridge interface
    }
  ]
}

os_images = {
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

# Virtual machine instances
vm_instances = [
  {
    name     = "vm-ubuntu"
    hostname = "ubuntu-server"
    domain   = "local.lan"
    username = "ubuntu"

    compute_spec = {
      cpu_cores    = 2
      memory_gb    = 2
      cpu_mode     = "host-passthrough"
      architecture = "x86_64"
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
        }
      ]
    }

    network_spec = {
      interfaces = [
        # Management interface (NAT)
        {
          name         = "eth0"
          network_name = "vm_nat"
        },
        # External interface (Bridge)
        {
          name         = "eth1"
          ipv4_address = "192.168.4.201" # Ensure this IP is available
          gateway      = "192.168.4.1"
          dns_servers  = ["8.8.8.8", "1.1.1.1"]
          network_name = "vm_bridge"
        }
      ]
    }

    qemu_agent = true
    autostart  = true # Enable auto-start with host
  },
  {
    name     = "vm-debian"
    hostname = "debian-server"
    domain   = "local.lan"
    username = "debian"

    compute_spec = {
      cpu_cores    = 2
      memory_gb    = 2 # Increased from default 2GB
      cpu_mode     = "host-passthrough"
      architecture = "x86_64"
    }

    storage_spec = {
      os_disk = {
        os_image = "debian12"
        size_gb  = 20
        type     = "ssd"
      }
      data_disks = [
        {
          size_gb     = 10
          mount_point = "/mnt/disk0"
          filesystem  = "ext4"
        }
      ]
    }

    network_spec = {
      interfaces = [
        # Management interface (NAT)
        {
          name         = "ens0"
          network_name = "vm_nat"
        },
        # External interface (Bridge)
        {
          name         = "ens1"
          ipv4_address = "192.168.4.203" # Ensure this IP is available
          gateway      = "192.168.4.1"
          dns_servers  = ["8.8.8.8", "1.1.1.1"]
          network_name = "vm_bridge"
        }
      ]
    }

    qemu_agent = true
    autostart  = true # Enable auto-start with host
  },
  {
    name     = "vm-fedora"
    hostname = "fedora-server"
    domain   = "local.lan"
    username = "fedora"

    compute_spec = {
      cpu_cores    = 2
      memory_gb    = 2 # Increased from default 2GB
      cpu_mode     = "host-passthrough"
      architecture = "x86_64"
    }

    storage_spec = {
      os_disk = {
        os_image = "fedora41"
        size_gb  = 20
        type     = "ssd"
      }
      data_disks = [
        {
          size_gb     = 10
          mount_point = "/mnt/disk0"
          filesystem  = "ext4"
        }
      ]
    }

    network_spec = {
      interfaces = [
        # Management interface (NAT)
        {
          name         = "enp0s1"
          network_name = "vm_nat"
        },
        # External interface (Bridge)
        {
          name         = "enp0s2"
          ipv4_address = "192.168.4.202" # Ensure this IP is available
          gateway      = "192.168.4.1"
          dns_servers  = ["8.8.8.8", "1.1.1.1"]
          network_name = "vm_bridge"
        }
      ]
    }

    qemu_agent = true
    autostart  = true # Enable auto-start with host
  }
]
