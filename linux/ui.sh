#!/bin/bash

# Raisson Souto, 11/2023

# To run it, you have pass the flag -i (iteractive)
# example: $ sh ./ui.sh -i

echo "[*] Enhancing system style"

#
echo "  [*] Installing extension manager"
sudo apt install gnome-shell-extension-manager -yy

# Set wallpaper to plain black
echo "  [*] Setting wallpaper to solid black"
gsettings set org.gnome.desktop.background picture-options 'none'
gsettings set org.gnome.desktop.background primary-color '#111111'
gsettings set org.gnome.desktop.background color-shading-type "solid"

# Set theme to dark
echo "  [*] Setting dark theme"
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'

# Set dash-dock style
echo "  [*] Setting dash-dock style"
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size '16'
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false

# Set desktop icons style
echo "  [*] Setting desktop icons style"
gsettings set org.gnome.shell.extensions.ding icon-size 'small'
gsettings set org.gnome.shell.extensions.ding show-home false

# gnome extensions

gnome-extensions install 4356 # Setting top bar
gnome-extensions install 1007 # ready notification remover
gnome-extensions install 4269 # alphabetical app grid
gnome-extensions install 517 # disable screen saver
gnome-extensions install 4485 # Favourites in AppGrid
gnome-extensions install 744 # Hide Activities Button
gnome-extensions install 3906 # Remove App Menu
gnome-extensions install 3933 # Toggle Night Light

# Removing multiple workspaces
echo "  [*] Removing multiple workspaces"
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
