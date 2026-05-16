import tomllib  # for Python 3.11+, use `import toml` if using toml module
from pathlib import Path

toml_path = Path("./settings/packages.toml")

with toml_path.open("rb") as f:
    cfg = tomllib.load(f)

packages = []

# Base packages
packages.extend(cfg["base"]["packages"])

# CPU-specific packages
for cpu in cfg.get("base", {}).get("cpu", {}).values():
    packages.extend(cpu.get("packages", []))

# GPU-specific packages
for gpu in cfg.get("base", {}).get("gpu", {}).values():
    packages.extend(gpu.get("packages", []))

# Extra base packages
packages.extend(cfg.get("base", {}).get("extra", {}).get("packages", []))

print(" ".join(packages))