#!/bin/bash
set -e
# APT minimal
install -d /etc/apt/apt.conf.d
cp /files/apt/apt-minimal.conf /etc/apt/apt.conf.d/99-localgithub-minimal

# Users
id __USERNAME__ >/dev/null 2>&1 || useradd -m -s /bin/bash __USERNAME__
echo "__USERNAME____COLON____USERPASS__" | chpasswd
usermod -aG sudo __USERNAME__
echo "root:__ROOTPASS__" | chpasswd
hostnamectl set-hostname __HOSTNAME__ || true

# SSH config
install -D /files/ssh/sshd_config.d/local-github.conf /etc/ssh/sshd_config.d/local-github.conf

# Autologin + menu
install -D /files/menu/usr/local/bin/chip-menu /usr/local/bin/chip-menu
chmod +x /usr/local/bin/chip-menu
install -D /files/menu/etc/systemd/system/chip-menu.service /etc/systemd/system/chip-menu.service
install -D /files/menu/etc/systemd/system/getty@tty1.service.d/override.conf /etc/systemd/system/getty@tty1.service.d/override.conf
systemctl enable chip-menu.service

# Boot presets
install -d /boot/firmware
cp -a /files/boot/firmware/* /boot/firmware/ || true

# NetworkManager
install -D /files/network/NetworkManager/system-connections/lan.nmconnection /etc/NetworkManager/system-connections/lan.nmconnection
chmod 600 /etc/NetworkManager/system-connections/lan.nmconnection

# Journald small
mkdir -p /etc/systemd/journald.conf.d
cat >/etc/systemd/journald.conf.d/volatile.conf <<'EOF'
[Journal]
Storage=volatile
SystemMaxUse=16M
RuntimeMaxUse=16M
EOF

# Trim
apt-get purge -y man-db manpages info install-info groff-base || true
apt-get autoremove -y --purge
apt-get clean
rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

echo "consoleblank=0" >> /boot/firmware/cmdline.txt || true
