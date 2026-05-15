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

sudo -u "$USERNAME" mkdir -p "$user_home/Notes"
: > "$user_home/Notes/apps.txt"

# -------------------------
# 1. Base Utilities & Build Tools
# -------------------------
ipac base sudo xdg-user-dirs git base-devel
addtonotes sudo xdg-user-dirs git base-devel

# Sudo/User Config
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/10-wheel
visudo -cf /etc/sudoers.d/10-wheel
sudo -u "$USERNAME" xdg-user-dirs-update

# -------------------------
# 2. AUR Helper (yay)
# -------------------------
if [ ! -d "$user_home/yay" ]; then
    sudo -u "$USERNAME" git clone https://aur.archlinux.org/yay.git "$user_home/yay"
    (cd "$user_home/yay" && sudo -u "$USERNAME" makepkg -si --noconfirm)
fi
addtonotes yay

# -------------------------
# 3. Shell, Terminal & Fonts
# -------------------------
ipac fish zoxide kitty noto-fonts-extra noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono-nerd
addtonotes fish zoxide kitty "Noto Fonts" "JetBrains Nerd"


sudo -u "$USERNAME" mkdir -p "$user_home/.config/fish"
echo 'zoxide init fish | source' >> "$user_home/.config/fish/config.fish"
sudo -u "$USERNAME" curl -fsSL "https://raw.githubusercontent.com/alexanderalanakyan/t/refs/heads/master/fish/config.fish" -o "$user_home/.config/fish/config.fish"
sudo -u "$USERNAME" curl -fsSL "https://raw.githubusercontent.com/alexanderalanakyan/t/refs/heads/master/fish/functions" -o "$user_home/.config/fish/functions"
sudo -u "$USERNAME" curl -fsSL "https://raw.githubusercontent.com/alexanderalanakyan/t/refs/heads/master/kitty" -o "$user_home/.config/kitty"


# -------------------------
# 4. Desktop Environment (Hyprland Stack)
# -------------------------
ipac hyprland libnotify dunst pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-audio pipewire-jack hyprpolkitagent qt5-wayland qt6-wayland xdg-desktop-portal-hyprland upower
addtonotes Hyprland Dunst Pipewire Hyprpolkitagent xdg-desktop-portal-hyprland upower

sudo -u "$USERNAME" mkdir -p "$user_home/.config/hypr"
sudo -u "$USERNAME" curl -fsSL "https://raw.githubusercontent.com/alexanderalanakyan/t/refs/heads/master/hyprland/hyprland.lua" -o "$user_home/.config/hypr/hyprland.lua"

sudo -u "$USERNAME" yay --noconfirm -S vicinae-bin
addtonotes Vicinae

# -------------------------
# 5. Networking & Hardware
# -------------------------
ipac bluez bluez-utils flatpak scdoc xdg-utils tuned nftables dnsmasq dhcpcd
addtonotes bluez flatpak scdoc xdg-utils tuned nftables dnsmasq dhcpcd

systemctl enable bluetooth tuned nftables

# Hardware & Power Tweaks
mkdir -p /etc/modprobe.d
printf "blacklist uvcvideo\n" > /etc/modprobe.d/uvcvideo.conf

mkdir -p /etc/NetworkManager/conf.d
printf "[connection]\nwifi.powersave=2\n" > /etc/NetworkManager/conf.d/powersave.conf
printf "\nnoarp\n" >> /etc/dhcpcd.conf
printf "[main]\ndhcp=dhcpcd\n" > /etc/NetworkManager/conf.d/dhcp-client.conf
printf "[main]\ndns=dnsmasq\n" > /etc/NetworkManager/conf.d/dns.conf

# -------------------------
# 6. GPU Early KMS (Intel B580)
# -------------------------
sudo sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
sudo pacman -Sy

# Install Intel B580 specific stack
ipac mesa vulkan-intel intel-media-driver vpl-gpu-rt lib32-mesa lib32-vulkan-intel linux-firmware-intel libva-utils
addtonotes "Intel Graphics"
sed -i 's/^MODULES=(/MODULES=(xe /' /etc/mkinitcpio.conf

# -------------------------
# Finalization
# -------------------------
chown -R "$USERNAME:$USERNAME" "$user_home"
mkinitcpio -P

echo "Installation complete. Press Enter to reboot."
read -r
systemctl reboot
