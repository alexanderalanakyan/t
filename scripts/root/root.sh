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

# 2. Set ownership to root:wheel
sudo chown -R root:wheel /data

# 3. Set permissions for directories and files
#    Directories: rwx for owner & group (770)
#    Files: rw for owner & group (660)
sudo find /data -type d -exec chmod 770 {} \;
sudo find /data -type f -exec chmod 660 {} \;

# 4. Optional: make new files inherit group 'wheel'
sudo chmod g+s /data

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
