packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "1.4.2"
    }
  }
  required_version = ">= 1.11.1"
}

source "vsphere-iso" "ubuntu22" {
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_username
  password            = var.vcenter_password
  insecure_connection = var.vcenter_insecure_connection
  datacenter          = var.datacenter
  cluster             = var.cluster
  datastore           = var.datastore
  folder              = var.folder

  network_adapters {
    network      = var.vm_network
    network_card = var.vm_network_adapter
  }

  vm_name               = local.vm_name
  guest_os_type         = var.vm_guest_os_type
  firmware              = var.vm_firmware
  CPUs                  = var.vm_cpu
  cpu_cores             = var.vm_cpu_cores
  RAM                   = var.vm_ram_mb
  disk_controller_type  = var.vm_disk_controller_type
  convert_to_template   = true

  storage {
    disk_size             = var.vm_disk_gb * 1024
    disk_thin_provisioned = true
  }

  iso_paths   = [var.iso_datastore_path]
  cdrom_type  = var.cdrom_type

  communicator = var.communicator
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
  ip_wait_timeout = var.ip_wait_timeout

  # Autoinstall məzmunu – seçilən mənbəyə uyğun yerləşdirilir
  http_content = var.common_source_content == "internal_http_srv" ? {
    "/user-data" = local.autoinstall_source_content["/user-data"]
    "/meta-data" = local.autoinstall_source_content["/meta-data"]
  } : null

  cd_content = var.common_source_content == "cd" ? {
    "/nocloud/user-data" = local.autoinstall_source_content["/nocloud/user-data"]
    "/nocloud/meta-data" = local.autoinstall_source_content["/nocloud/meta-data"]
  } : null

  # GRUB konsolunda kernel/ initrd yolu ilə Autoinstall
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- ${local.data_source_command} ",
    "${local.network_boot_cmd}",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]

  boot_wait         = "10s"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
}


build {
  name    = "ubuntu22-template"
  sources = ["source.vsphere-iso.ubuntu22"]

  provisioner "shell" {
  script = "scripts/cleanup.sh"
}
}