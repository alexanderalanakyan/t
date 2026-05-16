#!/bin/sh
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USERNAME="$1"
user_home="/home/$USERNAME"

ipac() {
  if output=$(pacman -S --needed --noconfirm "$@" 2>&1); then
    echo "SUCCESS: $*"
  else
    echo "FAILED: $*"
    echo "$output"
    exit 1
  fi
}

addtonotes() {
  for i in "$@"; do
    sudo -u "$USERNAME" printf "%s\n" "$i" >> "$user_home/Notes/apps.txt"
  done
}

# -------------------------
# User Setup
# -------------------------

if ! id "$USERNAME" >/dev/null 2>&1; then
  useradd -m -G wheel "$USERNAME"
  echo "Set password for $USERNAME:"
  passwd "$USERNAME"
fi
ipac sudo xdg-user-dirs git base-devel

sudo -u "$USERNAME" mkdir -p "$user_home/Notes"
: > "$user_home/Notes/apps.txt"

# -------------------------
# 1. Base Utilities & Build Tools
# -------------------------

addtonotes sudo xdg-user-dirs git base-devel

# Sudo/User Config
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel
visudo -cf /etc/sudoers.d/10-wheel
sudo -u "$USERNAME" xdg-user-dirs-update

# -------------------------
# 2. AUR Helper (yay)
# -------------------------
if [ ! -d "$user_home/yay" ]; then
    sudo -u "$USERNAME" git clone https://aur.archlinux.org/yay.git "$user_home/yay"
    (cd "$user_home/yay" && sudo -u "$USERNAME" makepkg -si)
fi
addtonotes yay

# -------------------------
# 3. Shell, Terminal & Fonts
# -------------------------
ipac fish kitty noto-fonts-extra noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono-nerd
addtonotes fish kitty "Noto Fonts" "JetBrains Nerd"

# -------------------------
# 4. Desktop Environment (Hyprland Stack)
# -------------------------
ipac hyprland libnotify dunst pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-audio pipewire-jack hyprpolkitagent qt5-wayland qt6-wayland xdg-desktop-portal-hyprland
addtonotes Hyprland Dunst Pipewire Hyprpolkitagent xdg-desktop-portal-hyprland

sudo -u "$USERNAME" yay --noconfirm -S vicinae-bin
addtonotes Vicinae

# -------------------------
# 5. Networking & Hardware
# -------------------------
ipac bluez bluez-utils flatpak scdoc xdg-utils tuned nftables upower
addtonotes bluez flatpak scdoc xdg-utils tuned nftables upower

systemctl enable bluetooth tuned nftables



# -------------------------
# Finalization
# -------------------------

echo "Installation complete. Press Enter to reboot."
read -r
systemctl reboot
