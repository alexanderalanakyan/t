#!/usr/bin/env bash
set -e

trap 'echo "Error on line $LINENO"; read -p "Press enter to exit"' ERR
source "../functions/functions.sh"
OUTPUT=$(python3 << 'EOF'

import tomllib
with open("../settings/packages.toml", "rb") as f:
    data = tomllib.load(f)
flat_pkgs=[]
def walk(d, in_flat=False):
    for k,v in d.items():
        is_flat = in_flat or k.lower() =="flathub"
        if in_flat:
            flat_pkgs.extend(v)
        elif isinstance(v, dict):
            walk(v, is_flat)
walk(data["user"])

print("\n".join(flat_pkgs).strip(" "))
EOF
)
for i in "$OUTPUT"; do 
flathub install "$i"
done
