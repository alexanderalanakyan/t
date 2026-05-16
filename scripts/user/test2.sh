#!/usr/bin/sh
set -euo pipefail

# 1. Define variables FIRST
name=$(whoami)
NOTES_FILE="/home/$name/Notes/apps.txt"

# Ensure the directory exists
mkdir -p "/home/$name/Notes"

# 2. Systemd Services


systemctl --user enable --now hyprpolkitagent pipewire pipewire-pulse wireplumber

# 3. Auth & Keys
systemctl enable --user --now gcr-ssh-agent.socket

# 4. Wallpapers
# hyprpaper setup placeholder

# 5. Check if oh-my-posh binary exists
if [ ! -f "$HOME/.local/bin/oh-my-posh" ]; then
    echo "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
else
    echo "Oh My Posh already installed, skipping download."
fi

echo 'Setup complete! Please reboot to finalize driver installation. Run "fish_add_path ~/.local/bin".'