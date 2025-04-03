# By default, the libvirt_uri = "qemu:///system" used to provision locally
# If remote provision needed, follow below guideline
# For more uri format, refer to libvirt_uri defined in variables.tf
# Libvirt connection URI. Examples:
# - Local: "qemu:///system"
# - Remote SSH: "qemu+ssh://user@host.example.com/system"
# - Remote TCP: "qemu+tcp://host.example.com/system"
# - Remote TLS: "qemu+tls://host.example.com/system"
libvirt_uri = "qemu+ssh://dylan@192.168.4.200/system" # replace with yours in real scenario
