os_images = {
  ubuntu2204 = {
    uri     = "/home/dylan/Downloads/jammy-server-cloudimg-amd64.img"
    format  = "qcow2"
    os_type = "linux"
  }
  debian12 = {
    uri     = "/home/dylan/Downloads/debian-12-backports-genericcloud-amd64.qcow2"
    format  = "qcow2"
    os_type = "linux"
  }
  fedora43 = {
    uri     = "/home/dylan/Downloads/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
    format  = "qcow2"
    os_type = "linux"
  }
}

kvm_host = {
  uri = "qemu:///system"
  pool = {
    name = "tf-pool"
    type = "dir"
    path = "/tmp/tf-pool"
  }
  networks = [
    {
      name   = "tf-nat"
      mode   = "nat"
      cidr   = ["10.17.3.0/24"]
      domain = "k8s.local"
    },
    {
      name             = "tf-bridge"
      mode             = "bridge"
      bridge_interface = "br0"
    }
  ]
}

vm_instances = {
  k8s-master = {
    count = 1
    profile = {
      domain = "k8s.local"
      compute_spec = {
        cpu_cores = 1
        memory_gb = 1
      }
      storage_spec = {
        os_disk = {
          os_image = "ubuntu2204"
          size_gb  = 20
        }
      }
      network_spec = {
        interfaces = [
          {
            network_name = "tf-nat"
            name         = "eth0"
          },
          {
            network_name = "tf-bridge"
            name         = "eth1"
          }
        ]
      }
    }
  }

  k8s-workers = {
    count = 2
    profile = {
      domain = "k8s.local"
      compute_spec = {
        cpu_cores = 1
        memory_gb = 1
      }
      storage_spec = {
        os_disk = {
          os_image = "ubuntu2204"
          size_gb  = 20
        }
        data_disks = [
          {
            size_gb     = 30
            mount_point = "/mnt/data"
            filesystem  = "ext4"
          }
        ]
      }
      network_spec = {
        interfaces = [
          {
            network_name = "tf-nat"
            name         = "eth0"
          },
          {
            network_name = "tf-bridge"
            name         = "eth1"
          }
        ]
      }
    }
  }
}
