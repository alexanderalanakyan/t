#!/bin/env bash
set -euo pipefail

SOURCE_DIR="$(pwd)"
TARGET_DIR="$HOME/.config"

mkdir -p "$TARGET_DIR"

for folder in ../../.dotfiles/*; do
    foldername=$(basename "$folder")
    if [ -d "$folder" ]; then
        echo "Linking $foldername -> $TARGET_DIR/$foldername"
        ln -sfn "$folder" "$TARGET_DIR/$foldername"
    else
        echo "Skipping $foldername: Not a directory"
    fi
done