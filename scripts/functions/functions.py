import configparser, subprocess, shutil, getpass, traceback, tomllib
config = configparser.ConfigParser()
config.read("../settings/settings.ini")



def run(cmd):
    try:
        subprocess.run(cmd, check=True, text=True)
    except subprocess.CalledProcessError as e:
        print(f"An error has occured! Please report this:\n{traceback.format_exc()}\n with settings:")
        print("\n-Errors-\n")
        print(traceback.format_exc)
        print("\n-Stdout/err-\n")
        print(f"\n{e.stderr}")
        print(f"\n{e.stdout}")
        print("\n-Settings-\n")
        printSettings()
        raise SystemExit
    else:
        print(f"Ran command, {" ".join(cmd)} with user {getpass.getuser()}")
def printSettings():
 for section in config:
    print(f"[{section}]")
    for k,v in config.items(section):
        print(f"{k} = {v}")
def pac(package_names):
    if getpass.getuser() == "root":
        command = ["pacman", "-S", "--needed", "--noconfirm",] + package_names
    elif shutil.which("sudo").find("sudo") != -1:
        command = ["sudo", "pacman", "-S", "--needed", "--noconfirm",] + package_names
    else:
        print("You dont have sudo manually install via pacman to continue (somehow)")
        raise SystemExit
    run(command)
def flathub(package_names):
    command = ["flatpak", "install", "--noninteractive", "-y",] + package_names
    run(command)
def yay(package_names):
    if shutil.which("yay").find("yay") == -1:
        if getpass.getuser() == "root":
            print("Please run as an actual user...")
            raise SystemError
        else:
            pac(["base-devel", "git"])
            run(["git", "clone", "https://aur.archlinux.org/yay.git"])
            run(["cd yay", "&&", "makepkg -si"])
    command=["yay", "-S", "--needed", "--noconfirm", "--cleanafter",] + package_names 
    run(command)

def open_packages(dir_name, other: str | None):
    packages=f"../settings/packages/{dir_name}"
    if other == None:
        packages+=f"/{dir_name}-packages.toml"
    else:
        packages+=f"/{other}-packages.toml"
    try:
        with open(packages, "rb") as file:
            data=tomllib.load(file)
    except PermissionError as e:
        print(f"You seemingly dont have permission to access {e.filename}... \n")
        print(traceback.format_exc)
        raise SystemError
    except Exception as e:
        exit()
    l=[]
    def walk(d: dict, li: list):
        for k,v in d.items():
            if k == "notes":
                continue
            if isinstance(v, list) and k=="packages":
                for i in v:
                   
                   li.append(i)
            elif isinstance(v, dict):
                walk(v, li)
            else:
                continue
    walk(data, l)
    return l
def exit():
    print(f"An error has occured! Please report this:\n{traceback.format_exc()}\n with settings:")
    printSettings()
    raise SystemExit