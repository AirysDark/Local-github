#!/usr/bin/env bash
set -euo pipefail

ARCH="${1:-arm64}"  # options: arm64, armhf, riscv64, i386
SUITE="${2:-bookworm}"
IMG="${3:-local-github-${ARCH}.img}"
SIZE_MB="${4:-1024}"

echo "[*] Installing deps..."
sudo apt-get update
sudo apt-get install -y qemu-user-static binfmt-support debootstrap qemu-user-static dosfstools   parted e2fsprogs rsync systemd-container

WORK="$(pwd)/work-${ARCH}"
ROOTFS="${WORK}/rootfs"
BOOT="${WORK}/boot"
mkdir -p "$ROOTFS" "$BOOT"

QEMU=""
case "$ARCH" in
  arm64)   DEBARCH=arm64; QEMU=/usr/bin/qemu-aarch64-static ;;
  armhf)   DEBARCH=armhf; QEMU=/usr/bin/qemu-arm-static      ;;
  riscv64) DEBARCH=riscv64; QEMU=/usr/bin/qemu-riscv64-static ;;
  i386)    DEBARCH=i386; QEMU=""                              ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

echo "[*] debootstrap stage1..."
sudo debootstrap --foreign --arch="${DEBARCH}" "${SUITE}" "${ROOTFS}" http://deb.debian.org/debian
if [[ -n "$QEMU" ]]; then sudo cp "$QEMU" "${ROOTFS}/usr/bin/"; fi
sudo chroot "${ROOTFS}" /debootstrap/debootstrap --second-stage

echo "[*] Basic packages..."
sudo chroot "${ROOTFS}" apt-get update
sudo chroot "${ROOTFS}" apt-get install -y --no-install-recommends   systemd-sysv sudo netbase net-tools ifupdown openssh-server network-manager dialog whiptail vim-tiny

echo "[*] Users & menu..."
echo "root:root" | sudo chroot "${ROOTFS}" chpasswd
sudo chroot "${ROOTFS}" bash -c "id chip || useradd -m -s /bin/bash chip"
echo "chip:raspberry" | sudo chroot "${ROOTFS}" chpasswd
sudo chroot "${ROOTFS}" usermod -aG sudo chip

sudo rsync -a shared/menu/ "${ROOTFS}/"
sudo rsync -a shared/ssh/ "${ROOTFS}/etc/ssh/"
sudo rsync -a shared/network/ "${ROOTFS}/etc/"
sudo chroot "${ROOTFS}" systemctl enable chip-menu.service || true

# Journald small
sudo chroot "${ROOTFS}" bash -c 'mkdir -p /etc/systemd/journald.conf.d && cat >/etc/systemd/journald.conf.d/volatile.conf <<EOF
[Journal]
Storage=volatile
SystemMaxUse=16M
RuntimeMaxUse=16M
EOF'

echo "[*] Create raw image ${IMG} (${SIZE_MB}MB) with single ext4 root partition"
dd if=/dev/zero of="${IMG}" bs=1M count="${SIZE_MB}"
parted -s "${IMG}" mklabel msdos
parted -s "${IMG}" mkpart primary ext4 1MiB 100%
LOOP=$(sudo losetup --find --show "${IMG}")
sudo partprobe "${LOOP}"
P="${LOOP}p1"
[[ -e "$P" ]] || P="${LOOP}"  # for older losetup without p suffix
sudo mkfs.ext4 -F "$P"
mkdir -p "${WORK}/mnt"
sudo mount "$P" "${WORK}/mnt"
sudo rsync -a "${ROOTFS}/" "${WORK}/mnt/"
sudo umount "${WORK}/mnt"
sudo losetup -d "${LOOP}"

echo ""
echo "NOTE: This is a generic rootfs image WITHOUT a bootloader."
echo "For PCs, write a bootloader (grub/syslinux). For ARM boards, install U-Boot and board-specific boot files."
echo "You can still chroot or mount this image for testing."
