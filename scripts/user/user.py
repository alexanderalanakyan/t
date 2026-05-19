import configparser, tomllib, traceback, sys, os, subprocess
from pathlib import Path
config = configparser.ConfigParser()
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "functions"))
from functions import *

config.read("../settings/settings.ini")
if config["main"]["userdone"] == "true":
    inp = input("User already finished setup, if this is false, enter continue to continue")
    if inp != "continue":
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

def Dots(home):
        dirs=[]
        names=[]
        p = Path(__file__).parent.joinpath('../../.dotfiles').resolve()
        for f in p.iterdir():
            if Path(f).is_dir():
                dirs.append(str(Path(f).resolve()))
                names.append(Path(f).resolve().name)
        for i,v in enumerate(dirs):
            PathToDirs=Path(f"{home}/.config/{names[i]}").resolve()
            if str(PathToDirs) == v:
                inp = input("\033[31mYou already installed the dotfiles... Continuing causes werid actions, enter \033[1mcontinue\033[0m\033[31m to continue.\033[0m \033[1m\033[32mMaybe just run git fetch + git pull...\n\033[0m") 
                if(inp != "continue"):
                    return
            if PathToDirs.exists():
                try:
                    inp = input(f"This section \033[31m\033[1mremoves\033[0m and \033[31m\033[1mreplaces\033[0m: \033[31m\033[1m{str(PathToDirs)} \033[0mif you do not want that to happen just type anything in. \nOtherwise press enter, it is also automatically copied to ../settings/usersave... \n")
                    if len(inp) > 0:
                        raise SystemExit
                except Exception:
                    exit()
                else:
                    subprocess.run(["cp", "-r", str(PathToDirs), str(Path("../settings/usersave").resolve())])
                    subprocess.run(["rm", "-rf", str(PathToDirs)])
                    print(f"\033[1m\033[32mSaved {str(PathToDirs)} to {str(Path("../setings/usersave").resolve())}\033[0m \033[31mhowever deleted in ~/.config/\033[0m")

            subprocess.run(["ln", "-sfn", v, str(PathToDirs)], check=True)
if config["dotfiles"]["enabled"] == "true":
    if os.getenv("HOME").find("/home/") == -1:
            print("Please have a set home dir...")
            raise SystemExit
    else:
            home = os.getenv("HOME") 
    Dots(home)

try:
    result = subprocess.run(["systemctl", "--user", "enable", "--now", "hyprpolkitagent", "pipewire", "pipewire-pulse", "wireplumber", "xdg-user-dirs", "gcr-ssh-agent.socket"],
    check=True, text=True)
except Exception:
    exit()


try:
    with open("../settings/settings.ini", "w") as file:
        config["main"]["userdone"] = "true"
        config.write(file)
except PermissionError as e:
    print(f"You seemingly dont have permission to access {e.filename}... \n")
    print(traceback.format_exc)
    raise SystemError
except Exception as e:
    exit()
print("All done with user installation! Everything should now be installed, if there were any errors just report them.")