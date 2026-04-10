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
    git clone https://github.com/easycodesnipper/terraform-kvm-provisioner.git
    cd terraform-kvm-provisioner
    ```

2.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

    # Alternatively approach for terraform init due to network issue
    ```bash
    # Download libvirt provider
    curl -L --retry 3 -O https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.8.3/terraform-provider-libvirt_0.8.3_linux_amd64.zip

    # Download macaddress provider
    curl -L --retry 3 -O https://github.com/ivoronin/terraform-provider-macaddress/releases/download/v0.3.2/terraform-provider-macaddress_0.3.2_linux_amd64.zip

    mkdir -p terraform.d/plugins/registry.terraform.io/dmacvicar/libvirt/0.8.3/linux_amd64/
    mkdir -p terraform.d/plugins/registry.terraform.io/ivoronin/macaddress/0.3.2/linux_amd64/

    unzip terraform-provider-libvirt_0.8.3_linux_amd64.zip -d terraform.d/plugins/registry.terraform.io/dmacvicar/libvirt/0.8.3/linux_amd64/
    unzip terraform-provider-macaddress_0.3.2_linux_amd64.zip -d terraform.d/plugins/registry.terraform.io/ivoronin/macaddress/0.3.2/linux_amd64/

    # Init with local provider
    terraform init -plugin-dir=./terraform.d/plugins

    rm -rf terraform-provider-*.zip
    ```  

3.  **Configure Variables:**

    Create a `terraform.tfvars.custom` file to customize your provision.

    **Example `terraform.tfvars.k8s-example`:**

    Please refer to the [`terraform.tfvars.k8s-example`](terraform.tfvars.k8s-example) file in this repository for a complete and verified example configuration.

4.  **Plan and Apply:**

    ```bash
    terraform plan -var-file=terraform.tfvars.custom
    terraform apply -var-file=terraform.tfvars.custom
    
    # Or you can create a soft link to custom tfvars file
    ln -sf terraform.tfvars.custom terraform.tfvars
    
    terraform plan
    terraform apply
    ```

## Configuration Reference

For a complete list of available variables and their descriptions, please refer to the [`variables.tf`](variables.tf) file.

## Local Development

To verify your changes locally before pushing to GitHub, you can use the provided `run_tests.sh` script. This script mimics the checks performed by the GitHub Action workflow.

```bash
./run_tests.sh
```

## License

[MIT License](LICENSE)
