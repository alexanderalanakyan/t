#!/usr/bin/sh
set -euo pipefail

# 1. Define variables FIRST
name=$(whoami)
NOTES_FILE="/home/$name/Notes/apps.txt"

# Ensure the directory exists
mkdir -p "/home/$name/Notes"

# 2. Define the installer function
ipac() {
  if output=$(sudo pacman -S --needed --noconfirm "$@" 2>&1); then
    echo "SUCCESS: $*"
  else
    echo "FAILED: $*"
    echo "$output"
    exit 1
  fi
}

# 3. Flatpaks
flatpak -y --noninteractive install flathub app.zen_browser.zen
flatpak -y --noninteractive install flathub com.spotify.Client
printf "Zen (Flathub)\nSpotify (Flathub)\n" >> "$NOTES_FILE"

# 4. System Tools & Utilities
ipac spotify-launcher udiskie wl-clipboard quickshell awww grim slurp
printf "Spotify\nUdiskie\nwl-clipboard\nquickshell\nawww\ngrim\nslurp\n" >> "$NOTES_FILE"

ipac pacman-contrib ripgrep strace rsync
printf "pacman-contrib\nripgrep\nstrace\nrsync\n" >> "$NOTES_FILE"

# 5. Systemd Services
sudo systemctl enable pacman-filesdb-refresh.timer
echo "PACCACHE_ARGS='-k2'" | sudo tee /etc/conf.d/pacman-contrib > /dev/null
sudo systemctl enable paccache.timer

# Use --now to start them immediately
systemctl --user enable --now hyprpolkitagent pipewire pipewire-pulse wireplumber

# 6. Auth & Keys
ipac gnome-keyring
printf "Gnome Keyring\n" >> "$NOTES_FILE"
systemctl enable --user --now gcr-ssh-agent.socket

# 7. Printing & Network (Avahi is needed for network printers)
ipac cups avahi nss-mdns
printf "CUPS\navahi\n" >> "$NOTES_FILE"

# 8. AUR Packages (Assuming yay is installed)
yay --noconfirm -S brother-hl2270dw



echo "Setup complete! Please reboot to finalize driver installation."

