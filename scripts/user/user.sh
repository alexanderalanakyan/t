#!/usr/bin/env bash
set -euo pipefail
./install_flathub_packages.sh
./install_user_packages.sh

systemctl --user enable --now hyprpolkitagent pipewire pipewire-pulse wireplumber xdg-user-dirs gcr-ssh-agent.socket


dots_enabled=$(python3 <<'EOF'
import configparser

config = configparser.ConfigParser()
config.read("../settings/settings.ini")

# Corrected quotes and indentation
print(config["dotfiles"]["enabled"])
EOF
)

if [ "$dots_enabled" = "true" ]; then
echo "DOTS ENABLED, Installing"
./symlinks.sh
fi

NOTES_FILE="/data/Notes/apps.txt"
SETTINGS_FILE="../settings/settings.ini"
PACKAGES_FILE="../settings/packages.toml"

# Append separator line
echo "# ============================ CURRENT SETTINGS ============================" >> "$NOTES_FILE"

# Append the actual settings
cat "$SETTINGS_FILE" >> "$NOTES_FILE"

echo "# ============================ CURRENT PACKAGES ============================" >> "$NOTES_FILE"

cat "$PACKAGES_FILE" >> "$NOTES_FILE"

echo 'Setup complete! Please reboot to finalize driver installation. Run "fish_add_path ~/.local/bin".'
