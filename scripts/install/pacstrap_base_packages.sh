#!/bin/env bash
set -euo pipefail

source "../functions/functions.sh"
PACKAGES=$(python3 <<'EOF'
import tomllib
from pathlib import Path

# Path to your TOML
toml_path = Path("../settings/packages.toml")

with toml_path.open("rb") as f:
    cfg = tomllib.load(f)

special_packages = ["flathub", "notes", "aur", "user", "system"]  # lowercase for matching

def gather_packages(cfg, skip_keys=None):
    skip_keys = skip_keys or []
    all_pkgs = []

    def walk(d, parent_key=""):
        for k, v in d.items():
            key_lower = k.lower()
            if key_lower in skip_keys:
                continue  # skip special sections
            if isinstance(v, dict):
                walk(v, parent_key=f"{parent_key}.{k}" if parent_key else k)
            elif k == "packages" and isinstance(v, list):
                all_pkgs.extend(v)

    walk(cfg)
    return all_pkgs

# Get a flat list of packages excluding special sections
pkgs = gather_packages(cfg, skip_keys=special_packages)
print(" ".join(pkgs))
EOF
)

echo "Installing base packages: $PACKAGES"
pacstrap -K /mnt $PACKAGES
