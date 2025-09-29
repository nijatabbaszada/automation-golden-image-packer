#!/bin/bash
set -eux

echo ">>> Cleanup started..."

# 1. Paketləri təmizlə
apt-get clean
apt-get autoremove -y
apt-get autoclean -y

# 2. Cloud-init cache sil
rm -rf /var/lib/cloud/*
rm -rf /var/log/cloud-init.log
rm -rf /var/log/cloud-init-output.log

# 3. SSH host key-ləri sil (yenidən generasiya ediləcək)
rm -f /etc/ssh/ssh_host_*

# 4. Machine-id sıfırla
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# 5. Logları sil
find /var/log -type f -exec truncate -s 0 {} \;

# 6. History təmizlə
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/*/.bash_history

# 7. Temporary fayllar
rm -rf /tmp/*
rm -rf /var/tmp/*

echo ">>> Cleanup completed."
