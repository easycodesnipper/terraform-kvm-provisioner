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

vm_instances = {
  k8s-master = {
    count = 1
    profile = {
      domain = "k8s.local"
      compute_spec = {
        cpu_cores    = 1
        memory_gb    = 1
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
      }
      network_spec = {
        interfaces = [
          {
            network_name = "nat-network"
            name         = "eth0"
          }
        ]
      }
      qemu_agent = true
      autostart  = true
    }
  }

  k8s-workers = {
    count = 3
    profile = {
      domain = "k8s.local"
      compute_spec = {
        cpu_cores    = 2
        memory_gb    = 1
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
            size_gb     = 30
            mount_point = "/mnt/data"
            filesystem  = "ext4"
          }
        ]
      }
      network_spec = {
        interfaces = [
          {
            network_name = "nat-network"
            name         = "eth0"
          },
          {
            network_name = "bridge-network"
            name         = "eth1"
          }
        ]
      }
    }
  }
}
