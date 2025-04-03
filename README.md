<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="./images/logo.jpeg" alt="TKP"></a>
</p>

# Terraform KVM Provisioner (TKP)
**Terraform(Infrastructure as Code) to provison KVM virtual machines.**

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/easycodesnipper/terraform-kvm-provisioner.svg)](https://github.com/easycodesnipper/terraform-kvm-provisioner/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/easycodesnipper/terraform-kvm-provisioner.svg)](https://github.com/easycodesnipper/terraform-kvm-provisioner/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Contributing](../CONTRIBUTING.md)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>

This project automates the provisioning of **KVM (Kernel-based Virtual Machine) virtual machines** using Terraform (Infrastructure as Code), supporting multi-OS deployments with flexible networking configurations.

### Key Features
- **✅Multi-VM Provisioning**  
  Deploy multiple virtual machines with customized resources (CPU, RAM, disk) in a single operation
- **✅Cross-OS Support**  
  Simultaneously provision Ubuntu, Debian, Fedora, and other distributions
- **✅Dual Networking Modes**  
  🛡️ **NAT** - Isolated VMs with outbound internet access  
  🌉 **Bridge** - Direct LAN connectivity for production-like networking
- **✅Infrastructure as Code**  
  Version-controlled configurations using Terraform's declarative syntax
- **✅Cloud-Init Integration**  
  Automated instance initialization (users, SSH keys, packages)

## 🏁 Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [usage](#usage) for notes on how to deploy the project on a live system.

### Prerequisites

`Terraform` is required to install.

1. **Download the Terraform Binary**
```bash
wget https://releases.hashicorp.com/terraform/1.6.4/terraform_1.6.4_linux_amd64.zip
```

2. **Unzip and Install**
```bash
sudo unzip terraform_*.zip -d /usr/local/bin/

```

3. **Set Execute Permissions**

```bash

sudo chmod +x /usr/local/bin/terraform

```

4. **Verify Installation:**

```bash

terraform --version

```

## 🎈 Usage <a name="usage"></a>

```bash
git clone https://github.com/easycodesnipper/terraform-kvm-provisioner.git
cd terraform-kvm-provisioner
terraform init
```
### Provision virtual machines on local KVM host
- **`NAT` mode**
```bash
terraform apply
```
- **`NAT` mode apparently**
```bash
terraform apply -var-file=nat.tfvars
```
- **`Bridge` mode**
```bash
terraform apply -var-file=bridge.tfvars
```

### Provision virtual machines on remote KVM host

`Ensure SSH connection works fine between local and remote KVM host`
```bash
# Generate ssh keys
ssh-keygen

# Copy ssh public key to remote
ssh-copy-id -i ~/.ssh/id_rsa.pub <kvm_user>@<kvm_host>

# Test ssh connection
ssh <kvm_user>@<kvm_host> hostname

# Start ssh agent
eval $(ssh-agent)

# Add ssh private key
ssh-add ~/.ssh/id_rsa
```

- **`NAT` mode**
```bash
terraform apply -var='libvirt_uri="qemu+ssh://<kvm_user>@<kvm_host>/system"' -var="network_mode=nat"
or
terraform apply -var-file=nat.tfvars -var='libvirt_uri="qemu+ssh://<kvm_user>@<kvm_host>/system"'
or
terraform apply -var-file=<(cat remote.tfvars nat.tfvars) # need to edit remote.tfvars
```

- **`Bridge` mode**
```bash
terraform apply -var-file=<(cat remote.tfvars bridge.tfvars)
```

### Override available variables
```bash
terraform apply -var="vm_count=3" \
-var="vcpu_counts=[1, 2, 2]" \
-var='vm_os=["ubuntu", "debian", "fedora"]'
```

*For more available variables, refer to [variables.tf](./variables.tf) definition*

### Alternatively running in docker
```bash
# Build docker image
docker build \
--build-arg USER_ID=$(id -u) \
--build-arg GROUP_ID=$(id -g) \
-t terraform-kvm-provisioner .

# Docker run
docker run -it --rm -v $(pwd):/app \
-v ~/.ssh:/home/tfuser/.ssh \
terraform-kvm-provisioner apply
```

## ✍️ Authors <a name = "authors"></a>

- [@easycodesnipper](https://github.com/easycodesnipper) - Idea & Initial work

See also the list of [contributors](https://github.com/easycodesnipper/terraform-kvm-provisioner/contributors) who participated in this project.

## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- Hat tip to anyone whose code was used
- Inspiration
- References
