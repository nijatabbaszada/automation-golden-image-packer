locals {
  # DNS (For boot command: nameserver=x nameserver=y)
  dns_servers_boot = join(" ", formatlist("nameserver=%s", var.dns_server_list))

  # DNS (For Kickstart: x,y)
  dns_servers_ks   = join(",", var.dns_server_list)

  # Kickstart content for internal HTTP server or CDROM
  kickstart_source_content = {
    "/ks.cfg" = templatefile("${abspath(path.root)}/http/kickstart.pkrtpl.hcl", {
      ipv4_address       = var.ipv4_address
      ipv4_netmask       = var.ipv4_netmask
      ipv4_gateway       = var.ipv4_gateway
      vm_hostname        = var.vm_hostname
      vm_network_interface  = var.vm_network_interface
      dns_servers_ks     = local.dns_servers_ks  
      ssh_username       = var.ssh_username
      ssh_password       = var.ssh_password
      ssh_timeout        = var.ssh_timeout
    })
  }

  # Boot command parameters
  data_source_command = (
    var.common_source_content == "internal_http_srv"
      ? "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg inst.stage2=hd:sr0 inst.nompath rd.multipath=off rd.lvm.conf=1"
    : var.common_source_content == "external_http_srv"
      ? "inst.ks=${var.external_http_srv_url}/ks.cfg inst.stage2=hd:sr0 inst.nompath rd.multipath=off rd.lvm.conf=1"
    : # default → CDROM
      "inst.ks=cdrom:/ks.cfg inst.repo=cdrom"
  )

  # Network configuration for boot command (if using HTTP source)
  ip_static = (
    length(trimspace(coalesce(var.ipv4_address, "")))  > 0 &&
    length(trimspace(coalesce(var.ipv4_gateway, "")))  > 0 &&
    length(trimspace(coalesce(var.ipv4_netmask, "")))  > 0
  )

  network_boot_cmd = (
    contains(["internal_http_srv","external_http_srv"], var.common_source_content)
    ? (
        local.ip_static
        ? "ip=${var.ipv4_address}::${var.ipv4_gateway}:${var.ipv4_netmask}:${var.vm_hostname}:${var.vm_network_interface}:none ${local.dns_servers_boot}"
        : "ip=dhcp ${local.dns_servers_boot}"
      )
    : ""
  )

  vm_name = "${var.vm_name}-${var.vm_guest_os_family}-${var.common_source_content}"
}
