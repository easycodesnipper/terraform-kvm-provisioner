vm_count     = 3
vcpu_counts  = [1, 2, 2]
memory_in_mb = [1024, 2048, 2048]
vm_os        = ["ubuntu", "debian", "fedora"]

vm_base_images = {
  ubuntu = {
    uri    = "/tmp/jammy-server-cloudimg-amd64.img"
    format = "qcow2"
  }
  debian = {
    uri    = "/tmp/debian-12-genericcloud-amd64.qcow2"
    format = "qcow2"
  }
  fedora = {
    uri    = "/tmp/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2"
    format = "qcow2"
  }
}
