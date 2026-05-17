#!/usr/bin/env bash

# 1. Verification
if [ "$(cat /sys/firmware/efi/fw_platform_size)" != "64" ]; then
    echo "Not a 64-bit EFI system. Exiting."
    exit 1
fi

chmod +x ./*.sh

# 2. Time & Filesystems
timedatectl set-timezone America/New_York

./mounts.sh

# 4. Mirrors & Base Install
reflector --protocol HTTPS -l 20 --sort rate --save /etc/pacman.d/mirrorlist


if [ -f /mnt/boot/amd-ucode.img ]; then
rm -rf /mnt/boot/amd-ucode.img || exit 1
fi

./pacstrap_base_packages.sh

genfstab -U /mnt >> /mnt/etc/fstab


# 5. Chroot Configuration (Using EOF to automate)
arch-chroot /mnt <<EOF
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'notabene' > /etc/hostname

sed -i 's/^MODULES=(/MODULES=(xe /' /etc/mkinitcpio.conf


systemctl enable NetworkManager
systemctl enable NetworkManager-wait-online

mkinitcpio -P

# Bootloader (Targeting /boot as defined in mount)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet zswap.enabled=0 xe.force_probe=*"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


# Systemd services
systemctl daemon-reload

systemctl enable pacman-filesdb-refresh.timer
systemctl enable paccache.timer
systemctl enable fwupd fwupd-refresh.timer
systemctl enable reflector.timer
systemctl enable logrotate logrotate.timer
systemctl enable fstrim.timer
systemctl enable write-cache-disabler
systemctl start systemd-zram-setup@zram0.service

EOF


# 6. Cleanup
echo "Installation complete. Rebooting is recommended. Check FSTAB at /mnt/etc/fstab, run arch-chroot /mnt, then passwd for setting root password."


