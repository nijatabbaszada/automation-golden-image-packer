# vCenter connection details
vcenter_server    = "example-vcenter.local"
vcenter_username  = "user@vsphere.local"
vcenter_password  = "password"
datacenter        = "DataCenter2" # vSphere datacenter (contains clusters and hosts)
cluster           = "Cluster2" # vSphere cluster (contains ESXi hosts and their VMs)
datastore         = "datastore2" # vSphere datastore for VM files
folder            = "Temps_Free" # vSphere folder for the VM template
vcenter_insecure_connection = true

# Network configuration
vm_network           = "VLAN123-Private" # vSphere network name
vm_network_adapter   = "vmxnet3" # Network adapter type
vm_network_interface  = "ens192" # Network interface name inside the VM
ipv4_address      = "10.10.10.10"
ipv4_netmask      = "255.255.255.0"
ipv4_gateway      = "10.10.10.1"

# DNS configuration
dns_server_list   = ["10.10.10.2", "10.10.10.3"]
dns_suffix_list   = ["example.local"]

# VM configuration
vm_hostname = "tpl-rhel9"
vm_name    = "tpl-rhel9"
vm_guest_os_family = "linux"
vm_guest_os_type   = "rhel9_64Guest"
vm_cpu     = 2
vm_cpu_cores = 1
vm_ram_mb  = 2048
vm_disk_gb = 20
vm_disk_controller_type = ["pvscsi"]
vm_firmware  = "efi"

# ISO file path
iso_datastore_path = "[datastore2] datastore-folder-name/rhel-baseos-9.0-x86_64-dvd.iso" # Path to the ISO file in the datastore
cdrom_type = "sata"

# SSH user and password (must match preseed)
communicator = "ssh"
ssh_username = "packer"
ssh_password = "packer"
ssh_timeout  = "30m"

# Common source content
common_source_content = "cd" # Options: cd, internal_http_srv, external_http_srv
external_http_srv_url = "http://10.20.20.20:8080"
