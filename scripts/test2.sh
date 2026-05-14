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
ipac spotify-launcher udiskie wl-clipboard quickshell grim slurp
printf "Spotify\nUdiskie\nwl-clipboard\nquickshell\ngrim\nslurp\n" >> "$NOTES_FILE"

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
    yay --noconfirm -S brother-hl2270dw
fi

if ! pacman -Qi timg > /dev/null 2>&1; then
	yay --noconfirm -S timg
fi

# 9. Wallpapers!
ipac hyprpaper
# 10. More Utils
ipac fd tldr nnn tar gzip bzip2 xz zip unzip p7zip curl bat eza mcfly
printf "fd\ntldr\nnnn\nbat\neza\nmcfly\n" >> "$NOTES_FILE"

# Oh My Posh
sudo chown -R "$name":"$name" "/home/$name/.config/fish"

# Setup Fish config (only if not already present)
mkdir -p ~/.config/fish/functions
# Check if oh-my-posh binary exists
if [ ! -f "$HOME/.local/bin/oh-my-posh" ]; then
    echo "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
else
    echo "Oh My Posh already installed, skipping download."
fi


# Functions
# Function: b (View with bat + copy to clipboard)
printf 'function b
    if set -q argv[1]
        bat $argv; and cat $argv | wl-copy
    end
end' > ~/.config/fish/functions/b.fish

# Function: bc (Binary Copy: copies content silently using bat's plain mode)
printf 'function bc
    if set -q argv[1]
        bat -p $argv | wl-copy
    end
end' > ~/.config/fish/functions/bc.fish

# Function: e (eza wrapper for directory listing)
printf 'function e
	eza "$argv"
end' > ~/.config/fish/functions/e.fish

printf '\noh-my-posh init fish --config 'tokyonight_storm' | source' >> ~/.config/fish/config.fish
printf '\nmcfly init fish | source' >> ~/.config/fish/config.fish
mkdir -p ~/.config/eza
printf $(curl https://raw.githubusercontent.com/eza-community/eza-themes/refs/heads/main/themes/tokyonight.yml) >> ~/.config/eza/theme.yml
sudo chown -R "$name":"$name" "/home/$name/.config/eza"
sudo chown -R "$name":"$name" "/home/$name/.config/hypr"


echo 'Setup complete! Please reboot to finalize driver installation. Run "fish_add_path ~/.local/bin".'
