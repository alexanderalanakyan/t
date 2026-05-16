#!/bin/env bash
set -euo pipefail
if [ -z "${1:-}" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

DATA_DIR="/data/Notes"

# 1. Ensure the directory exists
if [ ! -d "$DATA_DIR" ]; then
    sudo mkdir -p "$DATA_DIR"
fi
chmod -R 755 /data  

./install_root_packages

USERNAME="$1"
user_home="/home/$USERNAME"

# -------------------------
# User Setup
# -------------------------

if ! id "$USERNAME" >/dev/null 2>&1; then
  useradd -m -G wheel "$USERNAME"
  echo "Set password for $USERNAME:"
  passwd "$USERNAME"
fi
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel
visudo -cf /etc/sudoers.d/10-wheel

sudo -u "$USERNAME" xdg-user-dirs-update

# -------------------------
# Services
# -------------------------
systemctl enable bluetooth tuned nftables

# -------------------------
# Finalization
# -------------------------
echo "Setup complete."
echo "Press Enter to continue."
read -r
systemctl reboot
