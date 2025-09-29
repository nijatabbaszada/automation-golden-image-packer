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
automation-golden-image-packer/
├── packer-rhel9/ # Golden image for RHEL 9
│ ├── http/ # Kickstart/Preseed templates
│ │ └── kickstart.pkrtpl.hcl
│ ├── locals.pkr.hcl # Local variables
│ ├── rhel9.auto.pkvars.hcl # Auto-loaded variables
│ ├── rhel9.pkr.hcl # Main Packer configuration
│ └── variables.pkr.hcl # Input variables
│
├── packer-ubuntu22/ # Golden image for Ubuntu 22
│ ├── http/ # Cloud-init / user-data templates
│ │ └── user-data.pkrtpl.hcl
│ ├── scripts/ # Provisioning scripts
│ │ └── cleanup.sh
│ ├── locals.pkr.hcl # Local variables
│ ├── ubuntu.auto.pkvars.hcl # Auto-loaded variables
│ ├── ubuntu.pkr.hcl # Main Packer configuration
│ └── variables.pkr.hcl # Input variables
│
└── README.md # Documentation
```

##  File Descriptions

- **locals.pkr.hcl** – Defines local variables and helper expressions used during the build.  
- **variables.pkr.hcl** – Contains input variables (CPU, RAM, disk size, VM name, etc.).  
- **ubuntu.auto.pkvars.hcl** – Default values for variables; automatically loaded by Packer.  
- **ubuntu.pkr.hcl** – Main Packer configuration file for building the Ubuntu 22 golden image.  
- **http/user-data.pkrtpl.hcl** – Cloud-init or preseed template used for initial OS setup.  
- **scripts/** – Contains provisioning scripts for customisation (packages, updates, security hardening).  



---

##  Tools & Technologies
- **HashiCorp Packer** – image creation  
- **VMware vSphere** – target hypervisor (vCenter + ESXi)  
- **Terraform** – to consume the golden images in infrastructure workflows  



---


---

##  VMware Plugin for Packer

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
```

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

##  ISO File

*To build a golden image, you need to provide the operating system ISO file.  
You have two options:*

1. **Upload ISO to vCenter Datastore**  
   - Download the desired ISO (e.g., Ubuntu 22.04.5 LTS).  
   - Upload it to your vCenter datastore.  
   - Update the `iso_datastore_path` variable in your Packer configuration:  

   ```hcl
   # Example: ISO file path on vCenter datastore
   iso_datastore_path = "[datastore2] datastore-folder-name/rhel-baseos-9.0-x86_64-dvd.iso"

2. Use an External URL

   Instead of uploading to vCenter, you can directly reference a download URL:
```bash
iso_url = "https://releases.ubuntu.com/22.04.5/ubuntu-22.04.5-live-server-amd64.iso"
iso_checksum = "sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

⚠️ Important Notes:
    - If using a datastore ISO, make sure the path matches exactly as shown in the vCenter UI.
    - If using a URL, always include the iso_checksum for image integrity verification.


##  Usage

### 1. Clone the repository
```bash
git clone https://github.com/nijatabbaszada/automation-golden-image-packer.git
cd automation-golden-image-packer/packer-ubuntu22 # you can choose build for rhel9 or ubuntu
```

### 2. Validate the configuration
###  Validate Configuration

The `packer validate` command is used to **check the syntax and configuration** of your Packer templates before starting a build.  
It ensures that all required variables, plugins, and configuration blocks are correct.

```bash
packer validate .
```

### 3.Build the image
The `packer build` command is used to **create the golden image** based on the configuration.  
It runs through all the steps defined in your `.pkr.hcl` files – including ISO boot, installation, provisioning scripts, and exporting the VM template.

```bash
packer build .
```

##  Variables

Packer uses variables to parameterise the build.  
They are managed in two ways:

1. **`variables.pkr.hcl`** – declares variables (name, type, and optional default value).  
   - Example:
     ```hcl
     variable "vm_name" {
       type    = string
       default = "ubuntu22-golden"
     }
     variable "cpu" {
       type = number
     }
     ```

2. **`*.auto.pkvars.hcl`** – provides actual values for the variables.  
   - Example:
     ```hcl
     vm_name   = "ubuntu22-template"
     cpu       = 2
     memory    = 4096
     datastore = "Datastore1"
     network   = "VM Network"
     ```

3. **Command-line override** (optional):  
   ```bash
   packer build -var "vm_name=ubuntu22-test" .

⚠️ Important: Every variable declared in variables.pkr.hcl must be provided either with a default value or via an auto.pkvars.hcl file / CLI override. Otherwise, the build will fail.

##  Conclusion

After running `packer build`, the process will:

1. Create a new **virtual machine** in vCenter using the specified ISO and configuration.  
2. Run provisioning scripts (e.g., updates, cleanup, security hardening).  
3. Convert the VM into a **template** stored in your selected datastore/cluster.  
4. This template can then be reused to quickly deploy new VMs with consistent configuration.  

✅ The result is a **golden image** – a standardised, reusable VM template that ensures faster, repeatable, and more secure deployments across your environment.


##  Useful Links

- [Packer install](https://developer.hashicorp.com/packer/install)
- [Packer Documentation](https://developer.hashicorp.com/packer/docs/hcp)
- [VMware ISO Config](https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso)