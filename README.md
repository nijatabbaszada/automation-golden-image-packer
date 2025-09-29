# Terraform-Packer Golden Images

## 📌 Introduction
This repository contains **HashiCorp Packer HCL configurations** for building golden images of different operating systems.  
Golden images are used to ensure **consistency, security, and faster provisioning** across infrastructure environments.  

The goals of this project are to:  
- Build images for multiple operating systems using a **standardised workflow**  
- Provide a **modular and reusable** structure  
- Enable seamless integration with **Terraform, Ansible, and CI/CD pipelines**  

---

## 📂 Repository Structure

```bash
terraform-packer/
├── draft/                  # Experimental and test files
├── packer-debian11-test/   # Golden image for Debian 11
├── packer-rhel9/           # Golden image for RHEL 9
└── packer-ubuntu22/        # Golden image for Ubuntu 22
    ├── http/               # Kickstart/Preseed/User-Data files
    ├── scripts/            # Customisation scripts
    ├── locals.pkr.hcl      # Local variables
    ├── ubuntu.auto.pkvars.hcl
    ├── ubuntu.pkr.hcl
    └── variables.pkr.hcl

```

## 📄 File Descriptions

- **locals.pkr.hcl** – Defines local variables and helper expressions used during the build.  
- **variables.pkr.hcl** – Contains input variables (CPU, RAM, disk size, VM name, etc.).  
- **ubuntu.auto.pkvars.hcl** – Default values for variables; automatically loaded by Packer.  
- **ubuntu.pkr.hcl** – Main Packer configuration file for building the Ubuntu 22 golden image.  
- **http/user-data.pkrtpl.hcl** – Cloud-init or preseed template used for initial OS setup.  
- **scripts/** – Contains provisioning scripts for customisation (packages, updates, security hardening).  



---

## 🛠 Tools & Technologies
- **HashiCorp Packer** – image creation  
- **VMware vSphere** – target hypervisor (vCenter + ESXi)  
- **Terraform** – to consume the golden images in infrastructure workflows  



---

## ⚙️ Usage

### 1. Clone the repository
```bash
git clone https://github.com/<org>/<repo>.git
cd terraform-packer/packer-ubuntu22
```

### 2. Validate the configuration
```bash
packer validate .
```
### 3.Build the image
```bash
packer build .
```


## Variables

Variables are defined in variables.pkr.hcl and can be overridden using CLI parameters.

Example:

```bash
variable "vm_name" {
  type    = string
  default = "ubuntu22-golden"
}

variable "cpu" {
  type    = number
  default = 2
}
```
Override during build:
```bash
packer build -var "vm_name=test-ubuntu22" .
```

---

## 🔌 VMware Plugin for Packer

This project uses the **Packer VMware plugin** to build golden images for VMware vSphere.

### Installation
To install the VMware plugin, add the following block to your Packer configuration and run `packer init`:

```hcl
packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

Alternatively, you can install it manually with:

```bash
packer plugins install github.com/hashicorp/vmware
```
Builders

The VMware plugin provides two builders:

vmware-iso
Creates a VM from an ISO, installs the operating system, provisions software, and exports the VM as an image.
✅ Best for creating new golden images from scratch.

vmware-vmx
Starts from an existing .vmx virtual machine file, runs provisioners, and exports a new image.
✅ Best for iterating on existing VMs.
