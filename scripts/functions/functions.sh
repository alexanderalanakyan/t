#!/usr/bin/env bash
set -euo pipefail

pac() {
    if output=$(sudo pacman -S --needed --noconfirm "$@" 2>&1); then
        echo "SUCCESS: $*"
    else
        echo "FAILED: $*"
        echo "$output"
        exit 1
    fi
}

install_yay() {
    if ! command -v yay >/dev/null 2>&1; then
        echo "yay not found, installing..."
        pac git base-devel
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir"
        cd "$tmpdir"
        makepkg -si --noconfirm
        cd -
        rm -rf "$tmpdir"
    fi
}

yay_install() {
    install_yay
    # Fully non-interactive, answer diffs 'N' (No) to use defaults
    yay -S --needed --noconfirm --answerdiff Y "$@"
}

notes() {

 DATA_DIR="/data/Notes"
 LOG_FILE="$DATA_DIR/apps.txt"

    # 1. Ensure the directory exists
    if [ ! -d "$DATA_DIR" ]; then
        sudo mkdir -p "$DATA_DIR"
        sudo chown $(whoami):$(whoami) "$DATA_DIR"
    fi

    # 2. Create or append to log file
    touch "$LOG_FILE"

    # 3. Loop over arguments (installed apps) and write them to the log
    for pkg in "$@"; do
        echo "$pkg" >> "$LOG_FILE"
    done
}
