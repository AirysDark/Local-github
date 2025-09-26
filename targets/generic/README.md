# Generic targets (arm64/armhf/riscv64/i386)

This folder builds a **generic ext4 rootfs image** using `debootstrap` (and `qemu-debootstrap` when cross-building).
It **does not** include a bootloader. Use it as:
- A chroot image for testing
- A base rootfs to combine with your board's boot partition (U-Boot, DTBs, kernel)

Usage:
```bash
./targets/generic/build-generic.sh arm64   # or armhf, riscv64, i386
```
Artifacts: `local-github-<arch>.img` (single ext4 partition).
