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
- [Contributing](./CONTRIBUTING.md)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>

This project automates the provisioning of **KVM (Kernel-based Virtual Machine) virtual machines** using Terraform (Infrastructure as Code), supporting multi-OS deployments with flexible networking configurations.

### Key Features
- **✅Multi-VM Provisioning on Multi KVM host**  
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

- `j2cli` is required to install and render [main.tf.j2](main.tf.j2) template file.
```bash
sudo apt install j2cli
```

- `Terraform` is required to install.

1. **Download Terraform Binary, latest version preferred**
```bash
LATEST_VERSION=$(
curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest \
| grep tag_name \
| cut -d '"' -f 4 \
| sed 's/^v//'
)
wget https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_linux_amd64.zip
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

### General usage
```bash
git clone https://github.com/easycodesnipper/terraform-kvm-provisioner.git

cd terraform-kvm-provisioner

chmod +x terraform-init.sh

export TF_VAR_libvirt_uris='["qemu:///system", "qemu+ssh://<user>@<remote-host>/system"]' 
# replace placeholders with yours, multiple kvm hosts supported
# `qemu:///system` format for localhost
# `qemu+ssh://<kvm_user>@<kvm_host>/system` format for remote host

./terraform-init.sh 
# This custom initialization script will auto-generate main.tf and install multiple providers with local modules.

# If remote KVM host(s) found in `TF_VAR_libvirt_uris` variable, ensure SSH connection works fine.

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

terraform apply
```

### Override available variables
```bash
# Using variables
terraform apply \
-var="<key1>=<value1>" \
-var="<key2>=<value2>"

or
# Using .tfvars file
terraform apply \
-var-file=custom.tfvars

or
# Using multiple .tfvars files
terraform apply \
-var-file=<(cat custom1.tfvars custom2.tfvars)
```
- *Attention: By default `terraform.tfvars` and `*.auto.tfvars` files will be automatically loaded*

- *For more variables, refer to [variables.tf](./variables.tf) for definition and [terraform.tfvars](./terraform.tfvars) for usage*

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

- References
