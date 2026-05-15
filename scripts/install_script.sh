#!/usr/bin/sh

# 1. Verification
if [ "$(cat /sys/firmware/efi/fw_platform_size)" != "64" ]; then
    echo "Not a 64-bit EFI system. Exiting."
    exit 1
fi

# 2. Time & Filesystems
timedatectl set-timezone America/New_York
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






# 4. Mirrors & Base Install
reflector -c US -l 20 --sort score --save /etc/pacman.d/mirrorlist
pacstrap -K /mnt base linux linux-firmware amd-ucode sof-firmware man-db man-pages nvim networkmanager efibootmgr grub zram-generator mesa vulkan-intel intel-media-driver vpl-gpu-rt libva-utils
genfstab -U /mnt >> /mnt/etc/fstab


# 5. Chroot Configuration (Using EOF to automate)
arch-chroot /mnt <<EOF
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'notabene' > /etc/hostname

mkinitcpio -P

# Bootloader (Targeting /boot as defined in mount)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet zswap.enabled=0 xe.force_probe=*"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

echo '#!/bin/sh
set -e

while true; do
        lsblk --raw --scsi --paths -o name \
        | tail --lines='+2' \
        | (while read -r name; do 
                hdparm -W "$name" \
                | (grep --fixed-strings --quiet -e '1 (on)' \
                   && hdparm -W 0 "$name" \
                   || true)
        done)
        sleep 30
done' > /mnt/usr/local/sbin/write-cache-disabler

chmod +x /mnt/usr/local/sbin/write-cache-disabler

echo '[Unit]
Description=Write cache disabler daemon

[Service]
Type=simple
ExecStart=/usr/local/sbin/write-cache-disabler

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/write-cache-disabler.service
systemctl enable write-cache-disabler

echo 'ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd*", RUN+="/usr/bin/hdparm -B 254 -S 0 /dev/sda"' > /etc/udev/rules.d/69-hdparm.rules

systemctl enable fstrim
systemctl enable fstrim.timer

printf 'vm.swappiness = 180\n
vm.watermark_boost_factor = 0\n
vm.watermark_scale_factor = 125\n
vm.page-cluster = 0' > /etc/sysctl.d/99-vm-zram-parameters.conf

printf '[zram0]\n
compression-algorithm = zstd lzo-rle' > /etc/systemd/zram-generator.conf

systemctl daemon-reload

systemctl enable systemd-zram-setup@zram0

echo 'export ANV_DEBUG=video-decode,video-encode' > /data/enviroment-variables.sh

chmod +x /data/enviroment-variables.sh

EOF

arch-chroot /mnt
echo "Set password as root"
passwd && exit
# 6. Cleanup
echo "Installation complete. Rebooting is recommended. Check FSTAB at /mnt/etc/fstab."


