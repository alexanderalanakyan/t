import configparser, subprocess, shutil, getpass, traceback, tomllib
config = configparser.ConfigParser()
config.read("../settings/settings.ini")
def printSettings():
 for section in config:
    print(f"[{section}]")
    for k,v in config.items(section):
        print(f"{k} = {v}")

def pac(package_names):
    print(getpass.getuser())
    if getpass.getuser() == "root":
        command = ["pacman", "-S", "--needed", "--noconfirm",] + package_names
    elif shutil.which("sudo").find("sudo") != -1:
        command = ["sudo", "pacman", "-S", "--needed", "--noconfirm",] + package_names
    else:
        print("You dont have sudo manually install via pacman to continue (somehow)")
        raise SystemExit
    subprocess.run(command, check=True)
def flathub(package_names):
    for i in package_names:
            subprocess.run(["flatpak", "install", "--noninteractive", "-y", i], check=True)
def yay(package_names):
    if shutil.which("yay").find("yay") == -1:
        if getpass.getuser() == "root":
            print("Please run as an actual user...")
            raise SystemError
        else:
            pac(["base-devel", "git"])
            subprocess.run(["git", "clone", "https://aur.archlinux.org/yay.git"], check=True)
            subprocess.run(["cd yay", "&&", "makepkg -si"], check=True)
    command=["yay", "-S", "--needed", "--noconfirm", "--cleanafter",] + package_names
    subprocess.run(command, check=True)

def open_packages(dir_name, other: str | None):
    packages=f"../settings/packages/{dir_name}"
    if other == None:
        packages+=f"/{dir_name}-packages.toml"
    else:
        packages+=f"/{other}-packages.toml"
    with open(packages, "rb") as file:
        data=tomllib.load(file)
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
    print(f"An error has occured! Please report this: {traceback.format_exc()} \n with settings:")
    printSettings()
    raise SystemExit