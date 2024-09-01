#!/bin/bash

echo_session "Setting up shortcuts"

echo_topic "Applying terminal shortcuts..."

if cp ./.aliases $HOME/.aliases; then
    echo "--> .aliases file copied successfully."
else
    echo_error "copying .aliases file."
fi

if echo -e '\nif [ -f "$HOME/.aliases" ]; then\n    source "$HOME/.aliases"\nfi' >> $HOME/.bashrc; then
    echo "--> .bashrc updated successfully."
else
    echo_error "Error updating .bashrc."
fi

if source $HOME/.bashrc; then
    echo "--> .bashrc sourced successfully."
else
    echo_error "unable to source .bashrc."
fi

echo "[*] Terminal shortcuts applied."

echo_topic "Verifying if gsettings is installed..."
if ! which gsettings > /dev/null 2>&1; then
    echo_error "gsettings not found."
fi
echo_subtopic "Gsettings installed"

echo "[*] Applying system shortcuts ..."

keybindings_domain='org.gnome.settings-daemon.plugins.media-keys.custom-keybinding'
keybinding_path='/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings'

echo_subtopic "Switch keyboard layout: (Shift + Ctrl + Space)"
if gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift><Control>space']"; then
    echo_subtopic "Keyboard layout shortcut set successfully."
else
    echo_error "Setting keyboard layout shortcut."
fi

echo_subtopic "Open file explorer: (Windows + E)"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$keybinding_path/custom0/']" 
gsettings set $keybindings_domain:$keybinding_path/custom0/ name 'Open Nautilus'
gsettings set $keybindings_domain:$keybinding_path/custom0/ command 'nautilus'
gsettings set $keybindings_domain:$keybinding_path/custom0/ binding "<Super>e"

echo_subtopic "Open settings: (Windows + S)"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$keybinding_path/custom1/']"
gsettings set $keybindings_domain:$keybinding_path/custom1/ name 'Open Settings'
gsettings set $keybindings_domain:$keybinding_path/custom1/ command 'gnome-control-center'
gsettings set $keybindings_domain:$keybinding_path/custom1/ binding "<Super>s"

echo_subtopic "Switch to the tab on the left: (Ctrl + ←)"
if gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ move-tab-left "<Primary>Left"; then
    echo_subtopic "Shortcut for moving tab left set successfully."
else
    echo_error "Setting shortcut for moving tab left."
fi

echo_subtopic "Switch to the tab on the right: (Ctrl + →)"
if gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ move-tab-right "<Primary>Right"; then
    echo_subtopic "Shortcut for moving tab right set successfully."
else
    echo_error "Setting shortcut for moving tab right."
fi
