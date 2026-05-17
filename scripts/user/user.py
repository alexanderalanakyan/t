import configparser, tomllib, traceback, sys, os
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
    print("hi")
    flats = open_packages("user", "flathub")
    flathub(flats)
except Exception as e: 
       exit()
else:
   print("All Flatpak packages have been installed")
   
try:
    print("hi")
    aur = open_packages("user", "aur")
    yay(aur)
except Exception as e: 
        exit()
else:
   print("All AUR packages have been installed")
   
