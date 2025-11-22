os_images = {
  ubuntu2204 = {
    uri     = "/home/dylan/Downloads/jammy-server-cloudimg-amd64.img"
    format  = "qcow2"
    os_type = "linux"
  }
  debian12 = {
    uri     = "/home/dylan/Downloads/debian-12-genericcloud-amd64.qcow2"
    format  = "qcow2"
    os_type = "linux"
  }
  fedora43 = {
    uri     = "/home/dylan/Downloads/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
    format  = "qcow2"
    os_type = "linux"
  }
  centosstream9 = {
    uri     = "/home/dylan/Downloads/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
    format  = "qcow2"
    os_type = "linux"
  }
  rockylinux9 = {
    uri     = "/home/dylan/Downloads/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
    format  = "qcow2"
    os_type = "linux"
  }
}

kvm_host = {
  uri = "qemu:///system"
  pool = {
    name = "k8s-pool"
    type = "dir"
    path = "/mnt/data/k8s-pool"
  }
  networks = [
    {
      name      = "k8s-nat"
      mode      = "nat"
      cidr      = ["10.17.3.0/24"]
      domain    = "k8s.local"
      autostart = true
    },
    {
      name             = "k8s-bridge"
      mode             = "bridge"
      bridge_interface = "br0"
      autostart        = true
    }
  ]
}

use_apt_mirror = true
debug_enabled  = true

vm_instances = {
  k8s-controller-1 = {
    count = 1
    profile = {
      domain = "k8s.local"
      compute_spec = {
        cpu_cores = 2
        memory_gb = 1
      }
      storage_spec = {
        os_disk = {
          os_image = "debian12"
          size_gb  = 20
        }
      }
      network_spec = {
        interfaces = [
          {
            network_name = "k8s-nat"
            name         = "eth0"
            ipv4_address = "10.17.3.2/24"
            gateway      = "10.17.3.1"
          }
          # ,
          # {
          #   network_name = "k8s-bridge"
          #   name         = "eth1"
          # }
        ]
      }
    }
  }

  k8s-worker-1 = {
    count = 1
    profile = {
      domain = "k8s.local"
      compute_spec = {
        cpu_cores = 2
        memory_gb = 1
      }
      storage_spec = {
        os_disk = {
          os_image = "ubuntu2204"
          size_gb  = 20
        }
        data_disks = [
          {
            size_gb     = 10
            mount_point = "/mnt/data1"
            filesystem  = "ext4"
          }
        ]
      }
      network_spec = {
        interfaces = [
          {
            network_name = "k8s-nat"
            name         = "eth0"
            ipv4_address = "10.17.3.3/24"
            gateway      = "10.17.3.1"
          }
          # ,
          # {
          #   network_name = "k8s-bridge"
          #   name         = "eth1"
          # }
        ]
      }
    }
  }

  k8s-worker-2 = {
    count = 1
    profile = {
      domain = "k8s.local"
      compute_spec = {
        cpu_cores = 2
        memory_gb = 1
      }
      storage_spec = {
        os_disk = {
          os_image = "centosstream9"
          size_gb  = 20
        }
        data_disks = [
          {
            size_gb     = 10
            mount_point = "/mnt/data1"
            filesystem  = "ext4"
          }
        ]
      }
      network_spec = {
        interfaces = [
          {
            network_name = "k8s-nat"
            name         = "eth0"
            ipv4_address = "10.17.3.4/24"
            gateway      = "10.17.3.1"
          }
          # ,
          # {
          #   network_name = "k8s-bridge"
          #   name         = "eth1"
          # }
        ]
      }
    }
  }
}
