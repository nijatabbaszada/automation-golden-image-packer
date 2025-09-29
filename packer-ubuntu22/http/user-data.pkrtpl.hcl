#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ${vm_hostname}
    username: ${ssh_username}
    password: "${ssh_password}"
  locale: en_US.UTF-8
  keyboard:
    layout: us

  network:
    version: 2
    ethernets:
      nic0:
        match:
          driver: vmxnet3
        set-name: ${vm_network_interface}
%{ if ipv4_address != "" ~}
        dhcp4: no
        addresses:
          - ${ipv4_address}/${ipv4_prefix}
        gateway4: ${ipv4_gateway}
        nameservers:
          addresses: [${join(", ", dns_servers)}]
          search:    [${join(", ", dns_suffix_list)}]
%{ else ~}
        dhcp4: true
        nameservers:
          addresses: [${join(", ", dns_servers)}]
          search:    [${join(", ", dns_suffix_list)}]
%{ endif ~}

  storage:
    layout:
      name: lvm

  packages:
    - openssh-server
    - curl
    - wget

  ssh:
    install-server: true
    allow-pw: true

  late-commands:
    - curtin in-target --target=/target systemctl enable ssh
    - curtin in-target --target=/target apt-get clean
    - curtin in-target --target=/target rm -f /etc/ssh/ssh_host_*
    - curtin in-target --target=/target truncate -s 0 /etc/machine-id
