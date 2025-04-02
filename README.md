<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="./images/logo.jpeg" alt="TKP"></a>
</p>

<h3 align="center">Terraform KVM Provisioner (TKP)</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/kylelobo/The-Documentation-Compendium.svg)](https://github.com/kylelobo/The-Documentation-Compendium/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/kylelobo/The-Documentation-Compendium.svg)](https://github.com/kylelobo/The-Documentation-Compendium/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> Terraform to provison KVM virtual machines.
    <br> 
</p>

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
- **Multi-VM Provisioning**  
  Deploy multiple virtual machines simultaneously with customized resources (CPU, RAM, disk).
- **Cross-OS Support**  
  Provision Ubuntu, Debian, Fedora, Rocky Linux, and other distributions in the same environment.
- **Dual Networking Modes**  
  - **NAT**: For isolated VMs with outbound internet access
  - **Bridge**: Direct LAN integration for production-like environments
- **Infrastructure as Code**  
  Version-controlled VM configurations with Terraform's declarative syntax.
- **Cloud-Init Integration**  
  Automate initial setup including user accounts, SSH keys, network and package installation.

## 🏁 Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [usage](#usage) for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them.

```
Give examples
```

## 🎈 Usage <a name="usage"></a>

```
terraform init
terraform apply
```

## ✍️ Authors <a name = "authors"></a>

- [@easycodesnipper](https://github.com/easycodesnipper) - Idea & Initial work

See also the list of [contributors](https://github.com/easycodesnipper/terraform-kvm-provisioner/contributors) who participated in this project.

## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- Hat tip to anyone whose code was used
- Inspiration
- References
