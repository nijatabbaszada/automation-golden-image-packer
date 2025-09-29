# vCenter connection details
variable "vcenter_server"    { 
    type = string 
    sensitive = true
}
variable "vcenter_username"  { 
    type = string 
    sensitive = true
}
variable "vcenter_password"  { 
    type = string 
    default = " "
    sensitive = true
}
variable "datacenter"        { 
    type = string 
}
variable "cluster"           { 
    type = string 
}
variable "datastore"         { 
    type = string 
}
variable "folder"            { 
    type = string 
    default = "Temps_Free"
}
variable "vcenter_insecure_connection" {
  type        = bool
  description = "Do not validate vCenter Server TLS certificate."
}

# Network configuration
variable "vm_network"           { 
    type = string 
    default = "VLAN123-Private"
}
variable "vm_network_adapter" {
  type        = string
  default     = "vmxnet3"
}
variable "vm_network_interface" {
  type        = string
  default     = "ens192"
}
variable "ipv4_address" {
    type = string
    default = "10.10.10.10"
}
variable "ipv4_netmask" {
    type = string
    default = "255.255.255.0"
}
variable "ipv4_gateway" {
    type = string
    default = "10.10.10.1"
}

# DNS configuration
variable "dns_server_list" {
    type = list(string) #if you use many DNS servers, add them in the list format: ["x.x.x.x", "y.y.y.y"]
}
variable "dns_suffix_list" {
    type = list(string)
}

# VM configuration
variable "vm_hostname" {
    type = string
}
variable "vm_name"           { 
    type = string 
}
variable "vm_guest_os_family" {
  type        = string
  default     = "linux"
}
variable "vm_guest_os_type"  { 
    type = string 
}
variable "vm_cpu"            {
    type = number 
}
variable "vm_cpu_cores"      {
    type = number 
}
variable "vm_ram_mb"         { 
    type = number
}
variable "vm_disk_gb"        { 
    type = number 
}
variable "vm_disk_controller_type" {
  type        = list(string)
  default     = ["pvscsi"]
}
variable "vm_firmware"          { 
    type = string  
}

# ISO file path
variable "iso_datastore_path" { 
    type = string 
}
variable "cdrom_type" {
  type        = string
  description = "The type of virtual CD/DVD drive."
}

# SSH credentials
variable "communicator"      { 
    type = string 
    default = "ssh"
}
variable "ssh_username"      { 
    type = string 
    sensitive = true
}
variable "ssh_password"      { 
    type = string 
    sensitive = true
}
variable "ssh_timeout"       { 
    type = string 
    default = "30m" 
}
variable "ip_wait_timeout"   { 
    type = string 
    default = "20m" 
}

# Common source content
variable "common_source_content" {
    type = string
    default = "internal_http_srv"
}
variable "external_http_srv_url" {
    type = string
}