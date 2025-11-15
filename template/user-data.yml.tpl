#cloud-config
hostname: ${instance.hostname}
fqdn: ${instance.hostname}.${instance.domain}
manage_etc_hosts: true
users:
  - name: ${instance.username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_public_key}
%{ if instance.debug_enabled ~}
    lock_passwd: false # allow password authtication
#openssl passwd -6 -salt $(openssl rand -base64 12) <your-text-plain-passwd>
    hashed_passwd: "$6$tlQKwxyh+3n4gnp7$RUjySOHf84uW2TPrknqKJBmDAHgM1dRpQZW9GlaLe3L2NQaJKStq0kbpkYxFIipOYMY64TqpilHnxMhnAPlLJ1"
%{ endif ~}

%{ if instance.os_family == "debian" && use_apt_mirror ~}
apt:
  primary:
    - arches: [default]
      uri: https://${apt_mirror}/debian
  security:
    - arches: [default]
      uri: https://${apt_mirror}/debian-security
%{ else ~}
%{ if instance.os_family == "ubuntu" && use_apt_mirror ~}
apt:
  primary:
    - arches: [default]
      uri: https://${apt_mirror}/ubuntu
  security:
    - arches: [default]
      uri: https://${apt_mirror}/ubuntu
%{ endif ~}
%{ endif ~}

package_update: ${package_update}
package_upgrade: ${package_upgrade}
packages:
%{ for package in instance.packages ~}
  - ${package}
%{ endfor ~}
timezone: ${instance.timezone}
%{ if length(instance.data_disk_fstab) > 0 }
mounts:
%{ for disk in instance.data_disk_fstab ~}
  - [ "/dev/disk/by-label/data${disk.disk_index + 1}", "${disk.mount_point}", "${disk.filesystem}", "defaults", "0", "0" ]
%{ endfor ~}
%{ endif }
runcmd:
  - systemctl enable --now qemu-guest-agent
%{ if instance.debug_enabled }
output: { all: '| tee -a /var/log/cloud-init-output.log' }
%{ endif }