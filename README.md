# Terraform KVM Provisioner

A flexible Terraform project to provision virtual machines on a KVM host using the `libvirt` provider. This project supports multiple Linux distributions, custom storage pools, network configurations, and cloud-init for automated provisioning.

## Features

- **Multi-OS Support**: Easily provision Ubuntu, Debian, Fedora, CentOS, and Rocky Linux VMs.
- **Flexible Configuration**: Customize CPU, memory, disk size, and network interfaces (supports **Static IP** and **DHCP**) for each VM.
- **Cloud-Init Integration**: Automates hostname setting, user creation, package installation, and SSH key injection.
- **Custom Infrastructure**: Manages KVM storage pools and networks (Supports both **NAT** and **Bridge** network modes).
- **Data Disks**: Support for attaching multiple data disks with automatic formatting and mounting.

## Prerequisites

- **Terraform**: v1.0+
- **Libvirt/KVM**: A Linux host with KVM and libvirt installed.
- **Terraform Provider Libvirt**: Will be automatically installed by Terraform.
- **QEMU Guest Agent**: Recommended for better integration (installed by default in VMs).

## Usage

1.  **Clone the repository:**

    ```bash
    git clone <repository-url>
    cd terraform-kvm-provisioner
    ```

2.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

3.  **Configure Variables:**

    Create a `terraform.custom.tfvars` file to customize your deployment. You can use the provided [`terraform.tfvars`](terraform.tfvars) file in this repository as a reference.

    **Example `terraform.k8s.tfvars`:**

    Please refer to the [`terraform.k8s.tfvars`](terraform.k8s.tfvars) file in this repository for a complete and verified example configuration.

4.  **Plan and Apply:**

    ```bash
    terraform plan -var-file=terraform.custom.tfvars
    terraform apply -var-file=terraform.custom.tfvars
    ```

## Configuration Reference

For a complete list of available variables and their descriptions, please refer to the [`variables.tf`](variables.tf) file.

## License

[MIT License](LICENSE)
