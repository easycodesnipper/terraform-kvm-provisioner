# Release Notes

## v1.0.0 (Initial Release)

We are excited to announce the initial release of the **Terraform KVM Provisioner**! This project provides a flexible and robust way to provision virtual machines on KVM hosts using Terraform.

### Key Features

-   **Multi-OS Support**: Out-of-the-box support for popular Linux distributions including:
    -   Ubuntu (22.04 LTS)
    -   Debian (12 Bookworm)
    -   Fedora (43)
    -   CentOS Stream (9)
    -   Rocky Linux (9)

-   **Flexible VM Configuration**:
    -   Customize vCPU, Memory, and Disk sizes per instance.
    -   Support for CPU passthrough and specific architectures.
    -   Optional SPICE graphics support.

-   **Advanced Networking**:
    -   **NAT Mode**: Isolated networks with DHCP.
    -   **Bridge Mode**: Direct connection to physical networks.
    -   **IP Management**: Support for both **Static IP** assignment and **DHCP**.

-   **Storage Management**:
    -   Custom KVM storage pools.
    -   **Data Disks**: Attach multiple additional disks with automatic formatting (ext4/xfs) and mounting via Cloud-Init.

-   **Cloud-Init Integration**:
    -   Automated hostname and user configuration.
    -   SSH public key injection.
    -   Package installation and updates on first boot.

-   **Remote Management**:
    -   Support for local (`qemu:///system`) and remote (`qemu+ssh://...`) Libvirt connections.

### Usage

Please refer to the [README.md](README.md) for detailed usage instructions and configuration examples.
