#!/usr/bin/env bash
mkfs.ext4 -F /dev/nvme0n1p3
mkfs.ext4 -F /dev/nvme0n1p2
mkfs.ext4 -F /dev/sda1

# 3. Mounting
mount /dev/nvme0n1p2 /mnt
mount --mkdir /dev/nvme0n1p3 /mnt/home
mount --mkdir /dev/nvme0n1p1 /mnt/boot
mount --mkdir /dev/sda1 /mnt/data
fallocate -l 4G /mnt/swapfile
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile