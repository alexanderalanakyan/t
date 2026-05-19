import re, getpass, os
from pathlib import Path

username = input("\n\x1b[38;5;166mInput your username!\x1b[0m\n")

while not re.fullmatch("[a-z_][a-z0-9_-]*[$]?", username) or len(username) > 32:
    print("\n\x1b[38;5;01mInvalid username! Must be 32 chars or less and follow standard Linux naming rules.\x1b[0m")
    username = input("\n\x1b[38;5;166mInput your user's username!\x1b[0m\n")
while True:
    yon = input(f"Is \x1b[01;04m{username}\x1b[0m your desired username?\n(Input n for retype or anything else to continue)\n")
    if yon.lower().strip() == "n":
        while not re.fullmatch("[a-z_][a-z0-9_-]*[$]?", username) or len(username) > 32:
            print("\n\x1b[38;5;01mInvalid username! Must be 32 chars or less and follow standard Linux naming rules.\x1b[0m")
            username = input("\n\x1b[38;5;166mInput your user's username!\x1b[0m\n")
    else: break

os.system("clear")

print(f"Your name is {username}\n")

yon = input("Would you like to create a default home for this user? (Input n to set home dir to a specific dir)\n")
homedir=Path("/home") / getpass.getuser()
if yon.strip().lower() == "n":
    while not Path.exists(Path(homedir)):
        homedir=input("What is your home dir enter as absolute path:\n")
elif not Path.exists("/home"):
    print("/home does not exist. creating...\n")
    
    
print(homedir)