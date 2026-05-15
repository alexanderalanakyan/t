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
reflector --protocol HTTPS -l 20 --sort rate --save /etc/pacman.d/mirrorlist


if [ -f /mnt/boot/amd-ucode.img ]; then
rm -rf /mnt/boot/amd-ucode.img || exit 1
fi

pacstrap -K /mnt base linux linux-lts linux-firmware amd-ucode sof-firmware man-db man-pages nvim networkmanager efibootmgr grub zram-generator mesa vulkan-intel intel-media-driver vpl-gpu-rt libva-utils reflector logrotate pacutils fwupd
genfstab -U /mnt >> /mnt/etc/fstab

cat > /mnt/etc/modprobe.d/uvcvideo.conf <<EOF
blacklist uvcvideo
EOF

cat > /mnt/etc/NetworkManager/conf.d/powersave.conf <<EOF
[connection]
wifi.powersave=2
EOF

cat > /mnt/etc/systemd/system/write-cache-disabler.service <<EOF
[Unit]
Description=Write cache disabler daemon

[Service]
Type=simple
ExecStart=/usr/local/sbin/write-cache-disabler

[Install]
WantedBy=multi-user.target
EOF

cat > /mnt/etc/udev/rules.d/69-hdparm.rules <<EOF
ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd*", RUN+="/usr/bin/hdparm -B 254 -S 0 /dev/sda"
EOF

cat > /mnt/usr/local/sbin/write-cache-disabler <<EOF
#!/bin/sh
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
done
EOF

cat > /mnt/etc/sysctl.d/99-vm-zram-parameters.conf <<EOF
vm.swappiness = 180

vm.watermark_boost_factor = 0

vm.watermark_scale_factor = 125

vm.page-cluster = 0
EOF

cat > /mnt/etc/systemd/zram-generator.conf <<EOF
[zram0]
compression-algorithm = zstd lzo-rle
EOF

chmod +x /mnt/usr/local/sbin/write-cache-disabler

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

systemctl enable fwupd fwupd-refresh.timer
systemctl enable reflector.timer
systemctl enable logrotate logrotate.timer
systemctl enable fstrim.timer
systemctl enable write-cache-disabler
systemctl enable systemd-zram-setup@zram0.service

echo 'export ANV_DEBUG=video-decode,video-encode' > /etc/profile.d/environment-variables.sh
chmod 644 /etc/profile.d/environment-variables.sh
EOF

# 6. Cleanup
echo "Installation complete. Rebooting is recommended. Check FSTAB at /mnt/etc/fstab, run arch-chroot /mnt, then passwd for setting root password."


