#!/usr/bin/sh
flatpak install app.zen_browser.zen

ipac() {
  if output=$(sudo pacman -S --needed --noconfirm "$@" 2>&1); then
    echo "SUCCESS: $*"
  else
    echo "FAILED: $*"
    echo "$output"
    exit 1
  fi
}

ipac spotify-launcher udiskie wl-clipboard quickshell awww grim slurp
printf "Spotify\nUdiskie\nwl-clipboard\nquickshell\nawww\ngrim\nslurp" >>/home/"$1"/Notes/apps.txt

ipac pacman-contrib ripgrep strace rsync
printf "\npacman-contrib\nripgrep\nstrace\nrsync\n" >>"/home/$1/Notes/apps.txt"

systemctl enable pacman-filesdb-refresh.timer
sudo echo "PACCACHE_ARGS='-k2'" >/etc/conf.d/pacman-contrib
systemctl enable paccache.timer
systemctl --user enable hyprpolkitagent pipewire pipewire-pulse wireplumber

ipac gnome-keyring
printf "Gnome Keyring" >>"/home/$1/Notes/apps.txt"
systemctl enable --user --now gcr-ssh-agent.socket
