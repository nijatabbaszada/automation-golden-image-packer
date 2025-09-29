# RHEL 9 minimal Kickstart configuration

# Installation source: first attached CD/DVD
cdrom
# repo --name="appstream" --baseurl=cdrom:/AppStream

# Run the installer in text mode
text

# Accept the End User License Agreement
eula --agreed

# Language and keyboard
lang en_US.UTF-8
keyboard us

# Network configuration (DHCP by default)
network --device=${vm_network_interface} --bootproto=static --ip=${ipv4_address} --netmask=${ipv4_netmask} --gateway=${ipv4_gateway} --nameserver=${dns_servers_ks} --hostname=${vm_hostname} --noipv6
#network --device=${vm_network_interface} --bootproto=dhcp --activate --onboot=yes

# Lock the root account for security
rootpw --lock

# Create a regular user (packer) with sudo privileges
user --name=${ssh_username} --password=${ssh_password} --groups=wheel

# Enable firewall and allow SSH (port 22)
firewall --disabled

# Enforce SELinux
selinux --disabled

# Timezone
timezone UTC --utc

# Disk partitioning - wipe and use entire disk with LVM
clearpart --all --initlabel
zerombr
part /boot/efi --fstype=efi --size=600
part /boot     --fstype=xfs --size=1024
part pv.01 --size=1 --grow
volgroup rhel pv.01
logvol swap  --vgname=rhel --name=swap --size=8192
logvol /     --vgname=rhel --name=root --fstype=xfs --size=1 --grow

# Enable essential services (NetworkManager and SSHD)
services --enabled="NetworkManager,sshd,vmtoolsd"

# Do not configure X11
skipx

# Package selection
%packages
@^minimal-environment
open-vm-tools
open-vm-tools-deploypkg
bash-completion
perl
curl
sudo
%end

# Post-installation commands
%post

# Xidmətləri aktivləşdir
systemctl enable --now NetworkManager sshd vmtoolsd vgauthd || true

echo "${ssh_username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${ssh_username}
chmod 0440 /etc/sudoers.d/${ssh_username}

%end

# Reboot after installation and eject media
reboot --eject