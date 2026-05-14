#!/usr/bin/sh

# 1. Verification
if [ "$(cat /sys/firmware/efi/fw_platform_size)" != "64" ]; then
    echo "Not a 64-bit EFI system. Exiting."
    exit 1
fi

# 2. Time & Filesystems
timedatectl set-timezone America/New_York
mkfs.ext4 -F /dev/nvme0n1p3
mkfs.ext4 -F /dev/nvme0n1p4
mkswap -F /dev/nvme0n1p2
# 3. Mounting
mount /dev/nvme0n1p3 /mnt
mount --mkdir /dev/nvme0n1p4 /mnt/home
mount --mkdir /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p2

# 4. Mirrors & Base Install
reflector -c US -l 20 --sort score --save /etc/pacman.d/mirrorlist
pacstrap -K /mnt base linux linux-firmware amd-ucode sof-firmware man-db man-pages nvim networkmanager efibootmgr grub zram-generator
genfstab -U /mnt >> /mnt/etc/fstab

# 5. Chroot Configuration (Using EOF to automate)
arch-chroot /mnt <<EOF
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'notabene' > /etc/hostname

# Note: passwd will prompt for input during script execution
echo "Set your root password:"
passwd

mkinitcpio -P

# Bootloader (Targeting /boot as defined in mount)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
GPU_ID="e20b"
sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"|GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet zswap.enabled=0 xe.force_probe=$GPU_ID\"|" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
EOF

# 6. Cleanup
echo "Installation complete. Rebooting is recommended. Check FSTAB at /mnt/etc/fstab"


