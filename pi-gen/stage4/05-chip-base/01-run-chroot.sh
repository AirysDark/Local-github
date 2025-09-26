#!/bin/bash
set -e

# 0) APT minimal
install -d /etc/apt/apt.conf.d
cp /files/apt-minimal.conf /etc/apt/apt.conf.d/99-localgithub-minimal

# 1) Create 'chip', enable root, set passwords
if ! id chip >/dev/null 2>&1; then
  useradd -m -s /bin/bash chip
fi
echo "chip:raspberry" | chpasswd
usermod -aG sudo chip
echo "root:root" | chpasswd

# 2) Install SSH custom config fragment
install -D /files/etc/ssh/sshd_config.d/local-github.conf /etc/ssh/sshd_config.d/local-github.conf

# 3) Autologin to console for 'chip'
install -D /files/etc/systemd/system/getty@tty1.service.d/override.conf /etc/systemd/system/getty@tty1.service.d/override.conf

# 4) Install menu + service
install -D /files/usr/local/bin/chip-menu /usr/local/bin/chip-menu
chmod +x /usr/local/bin/chip-menu
install -D /files/etc/systemd/system/chip-menu.service /etc/systemd/system/chip-menu.service
systemctl enable chip-menu.service

# 5) Copy boot presets (Imager-style)
install -d /boot/firmware
cp -a /files/boot/firmware/* /boot/firmware/ || true

# 6) NetworkManager static LAN profile
install -d /etc/NetworkManager/system-connections
cp -a /files/etc/NetworkManager/system-connections/lan.nmconnection /etc/NetworkManager/system-connections/lan.nmconnection || true
chmod 600 /etc/NetworkManager/system-connections/lan.nmconnection || true

# 7) Journal small/volatile
mkdir -p /etc/systemd/journald.conf.d
cat >/etc/systemd/journald.conf.d/volatile.conf <<'EOF'
[Journal]
Storage=volatile
SystemMaxUse=16M
RuntimeMaxUse=16M
EOF

# 8) Size trims
apt-get purge -y man-db manpages info install-info groff-base || true
apt-get autoremove -y --purge
apt-get clean
rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# 9) Console polish
echo "consoleblank=0" >> /boot/firmware/cmdline.txt || true
