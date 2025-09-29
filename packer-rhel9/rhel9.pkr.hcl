packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "1.4.2"
    }
  }
  required_version = ">= 1.11.1"
}

source "vsphere-iso" "rhel9" {
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

  vm_name             = local.vm_name
  guest_os_type       = var.vm_guest_os_type
  firmware            = var.vm_firmware
  CPUs                = var.vm_cpu
  cpu_cores           = var.vm_cpu_cores
  RAM                 = var.vm_ram_mb
  disk_controller_type= var.vm_disk_controller_type
  convert_to_template = true

  storage {
    disk_size             = var.vm_disk_gb * 1024
    disk_thin_provisioned = true
  }

  iso_paths    = [var.iso_datastore_path]
  cdrom_type   = var.cdrom_type

  communicator = var.communicator
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
  ip_wait_timeout  = var.ip_wait_timeout

  http_content = var.common_source_content == "internal_http_srv" ? local.kickstart_source_content : null
  cd_content   = var.common_source_content == "cd"                ? local.kickstart_source_content : null

  boot_command = [
    "<up>",
    "e",
    "<down><down><end><wait>",
    " ${local.data_source_command} ",
    " ${local.network_boot_cmd} ",
    "<enter><wait>",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  
  boot_wait    = "10s"
  shutdown_command = "echo '${var.ssh_password}' | sudo -S bash -lc 'set -euo pipefail; systemctl disable --now template-net-wipe.service 2>/dev/null || true; rm -f /etc/systemd/system/template-net-wipe.service /usr/lib/systemd/system/template-net-wipe.service; systemctl reset-failed template-net-wipe.service 2>/dev/null || true; systemctl daemon-reload; nmcli -g NAME con show | grep -v \"^NAME$\" | xargs -r -n1 nmcli con delete || true; rm -f /etc/NetworkManager/system-connections/* /var/lib/NetworkManager/*lease* || true; rm -f /etc/machine-id /var/lib/dbus/machine-id; : > /etc/machine-id; rm -f /etc/udev/rules.d/70-persistent-net.rules || true; poweroff -p'"

}


build {
  name    = "rhel9-template"
  sources = ["source.vsphere-iso.rhel9"]

  # Provisioner 1 — activate services
  provisioner "shell" {
    execute_command = "sudo -n bash -lc '{{ .Vars }} {{ .Path }}'"
    inline = [
      "set -euxo pipefail",
      "dnf -y install open-vm-tools-deploypkg || true",
      "systemctl enable --now NetworkManager vmtoolsd vgauthd sshd || true"
    ]
  }

  # Provisioner 2 — network and identity cleanup at shutdown
  provisioner "shell" {
    execute_command = "sudo -n bash -lc '{{ .Vars }} {{ .Path }}'"
    inline = [
      "set -euxo pipefail",

      "install -m 0644 -D /dev/stdin /etc/systemd/system/template-net-wipe.service <<'EOF'\n[Unit]\nDescription=Template network & identity cleanup at shutdown\nDefaultDependencies=no\nBefore=shutdown.target\nConflicts=shutdown.target\n\n[Service]\nType=oneshot\nRemainAfterExit=yes\nExecStart=/usr/bin/true\n# Söndürmə zamanı təmizləmə (SSH artıq lazım deyil)\nExecStop=/usr/bin/bash -lc 'nmcli -g NAME con show | grep -v \"^NAME$\" | xargs -r -n1 nmcli con delete; rm -f /etc/NetworkManager/system-connections/* /var/lib/NetworkManager/*lease* || true; rm -f /etc/machine-id /var/lib/dbus/machine-id; : > /etc/machine-id; rm -f /etc/udev/rules.d/70-persistent-net.rules || true'\n\n[Install]\nWantedBy=multi-user.target\nEOF",
      "systemctl daemon-reload",
      "systemctl enable template-net-wipe.service",
      "journalctl --rotate --vacuum-time=1s || true",
      "fstrim -av || true"
    ]
  }
}