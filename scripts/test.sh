#!/bin/sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Must be run as root"
  exit 1
fi

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USERNAME="$1"

ipac() {
  if output=$(pacman -S --needed --noconfirm "$@" 2>&1); then
    echo "SUCCESS: $*"
  else
    echo "FAILED: $*"
    echo "$output"
    exit 1
  fi
}

# -------------------------
# Create user FIRST
# -------------------------
if ! id "$USERNAME" >/dev/null 2>&1; then
  useradd -m -G wheel "$USERNAME"
  passwd "$USERNAME"
fi

# -------------------------
# Now safe to initialize user_home
# -------------------------
user_home="/home/$USERNAME"

mkdir -p "$user_home/Notes"
: > "$user_home/Notes/apps.txt"

chown -R "$USERNAME:$USERNAME" "$user_home/Notes"
      
addtonotes() {
  
}

mkdir -p "$user_home/Notes"
touch "$user_home/Notes/apps.txt"

echo "$user_home"

timedatectl set-timezone America/New_York
hwclock --systohc
timedatectl set-ntp true

ipac base
ipac sudo
addtonotes sudo
ipac xdg-user-dirs
sudo -u "$USERNAME" xdg-user-dirs-update

echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >/etc/sudoers.d/10-wheel
visudo -cf /etc/sudoers.d/10-wheel

ipac git base-devel

sudo -u $USERNAME git clone https://aur.archlinux.org/yay.git "$user_home/yay"

cd "$user_home/yay" || exit 1
sudo -u "$USERNAME" makepkg -si --noconfirm

addtonotes "yay"

ipac fish
addtonotes fish

chsh -s /usr/bin/fish "$USERNAME"

ipac zoxide
addtonotes zoxide

mkdir -p "$user_home/.config/fish"

grep -qxF 'zoxide init fish | source' \
  "$user_home/.config/fish/config.fish" 2>/dev/null ||
  echo 'zoxide init fish | source' >>"$user_home/.config/fish/config.fish"

ipac xfce4-terminal
addtonotes XFCE4-terminal

sudo -u "$USERNAME" yay --noconfirm -S vicinae-bin
addtonotes Vicinae

ipac noto-fonts-extra noto-fonts-emoji noto-fonts-cjk
addtonotes "Noto Fonts"

ipac ttf-jetbrains-mono-nerd
addtonotes "JetBrains Nerd"

ipac hyprland
addtonotes Hyprland

mkdir -p "$user_home/.config/hypr"

curl -fsSL \
  "https://raw.githubusercontent.com/alexanderalanakyan/t/refs/heads/master/hyprland.lua" \
  -o "$user_home/.config/hypr/hyprland.lua"

ipac libnotify dunst pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-jack hyprpolkitagent qt5-wayland qt6-wayland xdg-desktop-portal-hyprland upower

addtonotes Dunst
addtonotes Pipewire
addtonotes Hyprpolkitagent
addtonotes xdg-desktop-portal-hyprland
addtonotes upower


ipac bluez bluez-utils

systemctl enable bluetooth

ipac flatpak
addtonotes Flatpak

ipac scdoc xdg-utils
addtonotes scdoc
addtonotes xdg-utils

# -------------------------
# Final ownership fix
# -------------------------
chown -R "$USERNAME:$USERNAME" "$user_home"

sleep 5s

echo Restarting after input
read -r

systemctl reboot
