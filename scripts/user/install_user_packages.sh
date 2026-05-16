#!/usr/bin/env bash
set -e

trap 'echo "Error on line $LINENO"; read -p "Press enter to exit"' ERR
source "../functions/functions.sh"
OUTPUT=$(python3 << 'EOF'

import tomllib
with open("../settings/packages.toml", "rb") as f:
    data = tomllib.load(f)
excluded_keys=["flathub", "notes"]
aur_pkgs=[]
user_pkgs=[]
def walk(d, in_aur=False):
    for k,v in d.items():
        is_aur = in_aur or k.lower() =="aur"
        if k in excluded_keys:
                continue
        if k == "packages" and isinstance(v,list):
            if in_aur:
                aur_pkgs.extend(v)
            else:
                user_pkgs.extend(v)
        elif isinstance(v, dict):
            walk(v, is_aur)
walk(data["user"])

print("\n".join(user_pkgs).strip(" "))
print(":::AUR:::")
print("\n".join(aur_pkgs).strip(" "))
EOF
)
u_pkgs=""
a_pkgs=""
in_aur=0

while IFS= read -r line; do
        if [ "$line" = ":::AUR:::" ]; then
                in_aur=1
        elif [ "$in_aur" -eq 1 ]; then
                a_pkgs="$a_pkgs $line"
        else
                u_pkgs="$u_pkgs $line"
        fi
done <<< "$OUTPUT"

yay_install $a_pkgs
pac $u_pkgs
