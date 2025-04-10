# terraform.tfvars
kvm_host_vm_instances = [
  {
    kvm_host = {
      pool = {
        name = "vm-pool-1"
        type = "dir"
        path = "/tmp/vm-pool-1" # adjust with yours
      }
      networks = [
        {
          name   = "vm-nat-1"
          mode   = "nat"
          cidr   = ["10.0.0.0/24"] # adjust with yours
          domain = "local.lan"
        },
        {
          name             = "vm-bridge"
          mode             = "bridge"
          cidr             = ["192.168.4.0/24"] # adjust with yours
          bridge_interface = "br0"
        }
      ]
    }
    vm_instances = [
      {
        name = "vm-ubuntu"
        compute_spec = {
          cpu_cores = 2
          memory_gb = 2
        }
        storage_spec = {
          os_disk = {
            os_image = "ubuntu2204"
            size_gb  = 20
          }
          data_disks = [
            {
              size_gb     = 10
              mount_point = "/mnt/disk0" # adjust with yours
            }
          ]
        }
        network_spec = {
          interfaces = [
            # NAT interface for management
            {
              network_name = "vm-nat-1" # aligned with kvm_host.networks.name above
              name         = "eth0",
            },
            # Bridge interface for external access
            {
              network_name = "vm-bridge"
              name         = "eth1",
              ipv4_address = "192.168.4.201" # adjust with yours
              gateway      = "192.168.4.1",  # adjust with yours
              dns_servers  = ["8.8.8.8", "8.8.4.4"]
            }
          ]
        }
        qemu_agent = true
      }
    ]
  },
  {
    kvm_host = {
      pool = {
        name = "vm-pool-2"
        path = "/tmp/vm-pool-2"
      }
      networks = [
        {
          name   = "vm-nat-2"
          mode   = "nat"
          cidr   = ["10.0.1.0/24"] # adjust with yours
          domain = "local.lan"
        }
      ]
    }
    vm_instances = [
      {
        name = "vm-debian"
        compute_spec = {
          cpu_cores = 2
          memory_gb = 2
          cpu_mode  = "host-model"
        }
        storage_spec = {
          os_disk = {
            os_image = "debian12"
            size_gb  = 20
            type     = "hdd"
          }
          data_disks = [
            {
              size_gb     = 10
              mount_point = "/mnt/disk0"
              filesystem  = "xfs"
            }
          ]
        }
        network_spec = {
          interfaces = [
            # NAT interface for management
            {
              network_name = "vm-nat-2" # aligned with kvm_host.networks.name above
              name         = "ens0",
            }
          ]
        }
        qemu_agent = false
      }
    ]
  }
]

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
