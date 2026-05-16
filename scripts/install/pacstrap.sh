#!/bin/env bash
set -euo pipefail

PACKAGES=$(python3 <<'EOF'
import tomllib
from pathlib import Path

cfg = tomllib.load(Path("../settings/packages.toml").open("rb"))

pkgs = []
pkgs.extend(cfg["base"]["packages"])
for cpu in cfg.get("base", {}).get("cpu", {}).values():
    pkgs.extend(cpu.get("packages", []))
for gpu in cfg.get("base", {}).get("gpu", {}).values():
    pkgs.extend(gpu.get("packages", []))
pkgs.extend(cfg.get("base", {}).get("extra", {}).get("packages", []))
print(" ".join(pkgs))
EOF
)

echo "Installing base packages: $PACKAGES"
pacstrap -K /mnt $PACKAGES