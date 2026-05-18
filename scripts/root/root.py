import re

username = input("\n\x1b[38;5;166mInput your user's username!\x1b[0m\n")

while not re.fullmatch("[a-z_][a-z0-9_-]*[$]?", username) or len(username) > 32:
    print("\n\x1b[38;5;01mInvalid username! Must be 32 chars or less and follow standard Linux naming rules.\x1b[0m")
    username = input("\n\x1b[38;5;166mInput your user's username!\x1b[0m\n")
yon = input(f"Is \x1b[01;04m{username}\x1b[0m your desired username?\n (Type n for retype or anything else to continue)")
if yon.lower().strip() == "n":
   while not re.fullmatch("[a-z_][a-z0-9_-]*[$]?", username) or len(username) > 32:
    print("\n\x1b[38;5;01mInvalid username! Must be 32 chars or less and follow standard Linux naming rules.\x1b[0m")
    username = input("\n\x1b[38;5;166mInput your user's username!\x1b[0m\n")
