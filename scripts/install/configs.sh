#!/usr/bin/env bash


cat > /mnt/etc/systemd/system/write-cache-disabler.service <<EOF
[Unit]
Description=Write cache disabler daemon

[Service]
Type=simple
ExecStart=/usr/local/sbin/write-cache-disabler

[Install]
WantedBy=multi-user.target
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

chmod +x /mnt/usr/local/sbin/write-cache-disabler

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

cat > /mnt/etc/udev/rules.d/69-hdparm.rules <<EOF
ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd*", RUN+="/usr/bin/hdparm -B 254 -S 0 /dev/sda"
EOF

cat > mnt/etc/conf.d/pacman-contrib <<EOF
 "PACCACHE_ARGS='-k2'"
EOF 

cat > /mnt/etc/modprobe.d/uvcvideo.conf <<EOF
blacklist uvcvideo
EOF

cat > /mnt/etc/NetworkManager/conf.d/powersave.conf <<EOF
[connection]
wifi.powersave=2
EOF