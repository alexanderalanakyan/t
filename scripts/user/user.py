import configparser, tomllib, traceback, sys, os, subprocess
from pathlib import Path
config = configparser.ConfigParser()
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "functions"))
from functions import *

config.read("../settings/settings.ini")
if config["main"]["userdone"] == "true":
    print("User already finished setup, if this is false, then change ../settings/settings.ini")
    raise SystemExit

try:
    user = open_packages("user", None)
    pac(user)
except Exception as e: 
    exit()
else:
   print("All user packages have been installed")
   
try:
    flats = open_packages("user", "flathub")
    flathub(flats)
except Exception as e: 
       exit()
else:
   print("All Flatpak packages have been installed")
   
try:
    aur = open_packages("user", "aur")
    yay(aur)
except Exception as e: 
        exit()
else:
   print("All AUR packages have been installed")

if config["dotfiles"]["enabled"] == "true":
    if os.getenv("HOME").find("/home/") == -1:
            print("Please have a set home dir...")
            raise SystemExit
    else:
            home = os.getenv("HOME")
    dirs=[]
    names=[]
    p = Path('../../.dotfiles')
    for f in p.iterdir():
        if Path(f).is_dir():
            dirs.append(str(Path(f).resolve()))
            names.append(Path(f).resolve().name)
    for i,v in enumerate(dirs):
        PathToDirs=Path(f"{home}/.config/{names[i]}").resolve()
        if PathToDirs.exists():
            try:
                inp = input(f"This section \033[31m\033[1mremoves\033[0m and \033[31m\033[1mreplaces\033[0m: \033[31m\033[1m{str(PathToDirs)} \033[0mif you do not want that to happen just type anything in. \nOtherwise press enter.")
                if len(inp) > 0:
                    raise SystemExit
            except Exception:
                raise SystemExit
            else:
                subprocess.run(["cp", "-r", str(PathToDirs), str(Path("../settings/usersave").resolve())])
                subprocess.run(["rm", "-rf", str(PathToDirs)])
            
        #subprocess.run(["ln", "-sfn", v, str(Path(f"{home}/.config/").resolve())], check=True)

try:
    result = subprocess.run(["systemctl", "--user", "enable", "--now", "hyprpolkitagent", "pipewire", "pipewire-pulse", "wireplumber", "xdg-user-dirs", "gcr-ssh-agent.socket"],
    check=True, text=True)
except Exception:
    print(traceback.format_exc())