#!/bin/bash

# Define variables
BLACK="#000000"

# Set wallpaper to plain black
gsettings set org.gnome.desktop.background primary-color "$BLACK"
gsettings set org.gnome.desktop.background secondary-color "$BLACK"
gsettings set org.gnome.desktop.background color-shading-type "solid"
echo "Wallpaper image changed successfully."

# Set theme to dark
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"

# Update package list and upgrade installed packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install general tools
sudo apt-get -y install curl wget ca-certificates gnupg lsb-release

sudo apt-get -y install libreoffice thunderbird firefox

# Install development tools
sudo apt-get -y install git python3 python3-pip golang-go virtualbox

# Check if goland is already installed before installing it
if ! command -v goland &> /dev/null
then
    sudo snap install goland --classic
fi

# Check if pycharm-professional is already installed before installing it
if ! command -v pycharm-professional &> /dev/null
then
    sudo snap install pycharm-professional --classic
fi

# Install security tools
sudo apt-get -y install nmap wireshark exiftool

# Install communication tools
# Check if slack is already installed before installing it
if ! snap list slack &> /dev/null
then
    sudo snap install slack --classic
fi

# Check if discord is already installed before installing it
if ! snap list discord &> /dev/null
then
    sudo snap install discord
fi

# Set up the terminal style
echo "PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[0;36m\]\w\[\e[m\] \[\e[0;32m\]\$ \[\e[m\]'" >> ~/.bashrc

# Set up the tools bar with some of these apps
gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Nautilus.desktop', 'mattermost-desktop_mattermost.desktop', 'discord_discord.desktop', 'org.gnome.Terminal.desktop', 'code.desktop', 'jetbrains-goland.desktop', 'jetbrains-pycharm-professional.desktop']"
