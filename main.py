from pathlib import Path
import subprocess

GUM = Path(__file__).parent / "scripts" / "install" / "bin" / "gum"

result = subprocess.run(
    [str(GUM), "choose", "--limit", "2", "test", "hi", "lol"], stdout=subprocess.PIPE
)
result.stdout