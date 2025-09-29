locals {
  # DNS kernel-cmdline (yalnız HTTP ssenarisi üçün istifadə olunur)
  dns_servers_boot = join(" ", formatlist("nameserver=%s", var.dns_server_list))

  autoinstall_source_content = {
    # HTTP kökü üçün user-data/meta-data
    "/user-data" = templatefile("${abspath(path.root)}/http/user-data.pkrtpl.hcl", {
      # Şəbəkə
      ipv4_address         = var.ipv4_address
      ipv4_prefix          = var.ipv4_prefix       # <-- CIDR prefix (məs: 24)
      ipv4_gateway         = var.ipv4_gateway
      vm_network_interface = var.vm_network_interface
      dns_servers          = var.dns_server_list
      dns_suffix_list      = var.dns_suffix_list   # <-- əlavə olundu

      # Identity
      vm_hostname  = var.vm_hostname
      ssh_username = var.ssh_username
      ssh_password = var.ssh_password
    })

    "/meta-data" = <<-EOT
      instance-id: iid-ubuntu-autoinstall
      local-hostname: ${var.vm_hostname}
    EOT

    # CDROM üçün NoCloud strukturu (ISO-da /nocloud/ altında)
    "/nocloud/user-data" = templatefile("${abspath(path.root)}/http/user-data.pkrtpl.hcl", {
      ipv4_address         = var.ipv4_address
      ipv4_prefix          = var.ipv4_prefix
      ipv4_gateway         = var.ipv4_gateway
      vm_network_interface = var.vm_network_interface
      dns_servers          = var.dns_server_list
      dns_suffix_list      = var.dns_suffix_list
      vm_hostname          = var.vm_hostname
      ssh_username         = var.ssh_username
      ssh_password         = var.ssh_password
    })

    "/nocloud/meta-data" = <<-EOT
      instance-id: iid-ubuntu-autoinstall
      local-hostname: ${var.vm_hostname}
    EOT
  }

  # Autoinstall datasource
  data_source_command = (
    var.common_source_content == "internal_http_srv"
      ? "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/"
    : var.common_source_content == "external_http_srv"
      ? "autoinstall ds=nocloud-net;s=${var.external_http_srv_url}/"
    : "autoinstall ds=nocloud;s=/cdrom/nocloud/"
  )

  # HTTP ssenarisində (NoCloud-Net) kernel səviyyəsində IP verilməsi üçün
  ip_static = (
    length(trimspace(coalesce(var.ipv4_address, "")))  > 0 &&
    length(trimspace(coalesce(var.ipv4_gateway, "")))  > 0 &&
    length(trimspace(coalesce(var.ipv4_prefix, "")))   > 0
  )

  network_boot_cmd = (
    contains(["internal_http_srv","external_http_srv"], var.common_source_content)
    ? (
        local.ip_static
        ? "ip=${var.ipv4_address}::${var.ipv4_gateway}:${var.ipv4_prefix}:${var.vm_hostname}:${var.vm_network_interface}:none ${local.dns_servers_boot}"
        : "ip=dhcp ${local.dns_servers_boot}"
      )
    : ""   # CD ssenarisində şəbəkə user-data ilə gəlir, kernelə ehtiyac yoxdur
  )

  vm_name = "${var.vm_name}-${var.vm_guest_os_family}-${var.common_source_content}"
}
