#!/bin/sh

# Set your source directory (where your files are currently)
# If you are currently inside the folder with fish/hypr/kitty, use $(pwd)
SOURCE_DIR="$(pwd)"
TARGET_DIR="$HOME/.config"

mkdir -p "$TARGET_DIR"

# Loop through the folders shown in your image
for folder in fish hypr kitty; do
    if [ -d "$SOURCE_DIR/$folder" ]; then
        echo "Linking $folder -> $TARGET_DIR/$folder"
        
        # -s: symbolic link
        # -f: remove existing destination files/folders first
        # -n: treat existing symlink to a directory as a normal file 
        #     (this prevents the link-inside-a-link bug)
        ln -sfn "$SOURCE_DIR/$folder" "$TARGET_DIR/$folder"
    else
        echo "Skipping $folder: Directory not found in $SOURCE_DIR"
    fi
done
