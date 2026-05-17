from pathlib import Path
import configparser, traceback, re
cfg = configparser.ConfigParser()
settings_folder = Path("settings")
cfg.read(f"{settings_folder.absolute()}/settings.ini")
cfg.set("dirs", "cfgdir", f"{settings_folder.absolute()}")

with open(f'{settings_folder}/settings.ini', 'w') as configfile:
    try:
        cfg.write(configfile)
    except Exception:
        traceback.print_exc()

for k,v in cfg.items("main"):
    if re.search("[done]", v):
        dir=re.sub("done", "", k)
        try:
            exec(open(f"{dir}/{dir}.py").read())
        except Exception:
            traceback.print_exc()
        else:
            cfg.set("main", f"{dir}done", "true")
            raise SystemExit
        
