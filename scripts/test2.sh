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
ipac udiskie wl-clipboard quickshell grim slurp
printf "Udiskie\nwl-clipboard\nquickshell\ngrim\nslurp\n" >> "$NOTES_FILE"

ipac pacman-contrib ripgrep strace rsync
printf "pacman-contrib\nripgrep\nstrace\nrsync\n" >> "$NOTES_FILE"

# 5. Systemd Services
sudo systemctl enable pacman-filesdb-refresh.timer
echo "PACCACHE_ARGS='-k2'" | sudo tee /etc/conf.d/pacman-contrib > /dev/null
sudo systemctl enable paccache.timer

systemctl --user enable --now hyprpolkitagent pipewire pipewire-pulse wireplumber

# 6. Auth & Keys
ipac gnome-keyring libsecret seahorse
printf "Gnome Keyring\nSeahore\n" >> "$NOTES_FILE"
systemctl enable --user --now gcr-ssh-agent.socket

# 7. Printing & Network 
ipac cups avahi nss-mdns
printf "CUPS\navahi\n" >> "$NOTES_FILE"


# 8. AUR Packages

if ! pacman -Qi brother-hl2270dw > /dev/null 2>&1; then
    yay --needed --noconfirm -S brother-hl2270dw
fi

if ! pacman -Qi journalctl-desktop-notification > /dev/null 2>&1; then
    yay --needed --noconfirm -S journalctl-desktop-notification
fi

# 9. Wallpapers
# ipac hyprpaper

# 10. More Utils
ipac fd tldr nnn tar gzip bzip2 xz zip unzip p7zip curl bat eza mcfly zoxide ripgrep-all broot uutils-coreutils
printf "fd\ntldr\nnnn\nbat\neza\nmcfly\nzoide\nripgrep-all\nbroot\nuutils\n" >> "$NOTES_FILE"


# Check if oh-my-posh binary exists
if [ ! -f "$HOME/.local/bin/oh-my-posh" ]; then
    echo "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
else
    echo "Oh My Posh already installed, skipping download."
fi


echo 'Setup complete! Please reboot to finalize driver installation. Run "fish_add_path ~/.local/bin".'
