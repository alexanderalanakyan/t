#!/usr/bin/env bash
source "../functions/functions.sh"

packages=$(python3 <<'EOF'
import tomllib
from pathlib import Path

toml_path = Path("../settings/packages.toml")
with toml_path.open("rb") as f:
    cfg = tomllib.load(f)

special_sections = {"aur", "notes", "flathubs", "user"}  # flathub is the one we want

pkgs = []

def walk(d):
    for k, v in d.items():
        key_lower = k.lower()
        if key_lower in special_sections:
            continue
        if isinstance(v, dict):
            walk(v)
        elif k == "packages" and isinstance(v, list):
            pkgs.extend(v)

walk(cfg)

for pkg in pkgs:
    print(pkg)
EOF
)

pac "$packages"
notes "$packages"

