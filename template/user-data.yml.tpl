#cloud-config
hostname: ${instance.hostname}
fqdn: ${instance.hostname}.${instance.domain}
manage_etc_hosts: ${manage_etc_hosts}
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

# Setup apt mirror
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

runcmd:
  # Set hostname
  - hostnamectl set-hostname ${instance.hostname}
  
  # Ensure qemu-guest-agent started
  - |
    systemctl enable --now qemu-guest-agent
    # Verify service started successfully with timeout protection
    max_attempts=30
    attempt=0
    until [ "$(systemctl is-active qemu-guest-agent)" = "active" ]; do
      attempt=$((attempt + 1))
      if [ $attempt -gt $max_attempts ]; then
        echo "ERROR: Failed to start qemu-guest-agent after $max_attempts attempts" >&2
        exit 1
      fi
      sleep 2
      systemctl start qemu-guest-agent
    done

%{ if length(instance.data_disk_fstab) > 0 }
  # Add data disks
%{ for i, disk in instance.data_disk_fstab ~}
  - |
    DISK="/dev/vd${substr("bcdefghijklmnopqrstuvwxyz", disk.disk_index, 1)}"
    PARTITION="$${DISK}1"
    LABEL="data${disk.disk_index + 1}"
    MOUNT_POINT="${disk.mount_point}"
    
    # Create partition table and partition
    parted -s "$${DISK}" mklabel gpt mkpart primary 0% 100%
    
    # Wait for partition
    udevadm settle
    
    # Verify partition exists before proceeding
    max_attempts=30
    attempt=0
    until [ -b "$${PARTITION}" ]; do
      attempt=$((attempt + 1))
      if [ $${attempt} -gt $${max_attempts} ]; then
        echo "ERROR: Failed to get partition $${PARTITION}" >&2
        exit 1
      fi
      sleep 2
    done
    
    # Create filesystem
    mkfs.${disk.filesystem} -L "$${LABEL}" "$${PARTITION}"
    
    # Create mount point
    mkdir -p "$${MOUNT_POINT}"
    
    # Mount filesystem using the partition device (not by-label)
    mount "$${PARTITION}" "$${MOUNT_POINT}"
    
    # Add to fstab
    echo "LABEL=$${LABEL} $${MOUNT_POINT} ${disk.filesystem} defaults 0 0" >> /etc/fstab
%{ endfor ~}
%{ endif }

%{ if instance.debug_enabled }
output: { all: '| tee -a /var/log/cloud-init-output.log' }
%{ endif }