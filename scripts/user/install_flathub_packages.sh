#!/usr/bin/env bash

flathubs=$(python3 <<'EOF'
import tomllib
from pathlib import Path

toml_path = Path("../settings/packages.toml")
with toml_path.open("rb") as f:
    cfg = tomllib.load(f)

special_sections = {"aur", "notes", "base", "system"}  # flathub is the one we want

flathub_pkgs = []

def walk(d):
    for k, v in d.items():
        key_lower = k.lower()
        if key_lower in special_sections:
            continue
        if "flathub" in key_lower:
            if isinstance(v, dict):
                # collect packages inside flathub section
                for subk, subv in v.items():
                    if subk == "packages" and isinstance(subv, list):
                        flathub_pkgs.extend(subv)
            continue
        if isinstance(v, dict):
            walk(v)
        elif k == "packages" and isinstance(v, list):
            pass  # ignore other packages

walk(cfg)

for pkg in flathub_pkgs:
    print(pkg)
EOF
)

for i in $flathubs; do
    flatpak -y --noninteractive install flathub "$i"
done

notes "$flathubs"