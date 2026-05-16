#!/usr/bin/env bash

source "../functions/functions.sh"

readarray -t USER_PACKAGES < <(
python3 <<'EOF'
import tomllib
from pathlib import Path

toml_path = Path("../settings/packages.toml")
with toml_path.open("rb") as f:
    cfg = tomllib.load(f)

special_sections = {"aur", "flathub", "notes", "base", "system"}

user_pkgs = []
aur_pkgs = []

def walk(d):
    for k, v in d.items():
        key_lower = k.lower()
        if key_lower in special_sections:
            if "aur" in key_lower:
                def collect_packages(x):
                    pkgs = []
                    for kk, vv in x.items():
                        if kk == "packages" and isinstance(vv, list):
                            pkgs.extend(vv)
                        elif isinstance(vv, dict):
                            pkgs.extend(collect_packages(vv))
                    return pkgs
                aur_pkgs.extend(collect_packages(v))
            continue
        if isinstance(v, dict):
            walk(v)
        elif k == "packages" and isinstance(v, list):
            user_pkgs.extend(v)

walk(cfg)

for pkg in user_pkgs:
    print(pkg)
print(":::AUR:::")
for pkg in aur_pkgs:
    print(pkg)
EOF
)

# Split USER and AUR packages
AUR_START=$(printf "%s\n" "${USER_PACKAGES[@]}" | grep -n ':::AUR:::' | cut -d: -f1)
if [[ -n "$AUR_START" ]]; then
    AUR_PACKAGES=("${USER_PACKAGES[@]:$AUR_START}")
    USER_PACKAGES=("${USER_PACKAGES[@]:0:$(($AUR_START-1))}")
else
    AUR_PACKAGES=()
fi

yay_install "$AUR_PACKAGES"
pac "$USER_PACKAGES"
notes "$USER_PACKAGES" "$AUR_PACKAGES"