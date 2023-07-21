#!/bin/bash

# Raisson Souto, 2023

# The goal of this script is to automate the
# configuration of my Ubuntu environment

##### Install some software

# Log file
LOG_FILE="linux.log"

# Update package list and upgrade installed packages
echo "~ Starting script~"
echo ""
echo "[*] Initial update ..."

cd ~
sudo apt-get update -qq
sudo apt-get upgrade &> /dev/null 2>> $LOG_FILE

echo "[*] Initial update done!"

# Install general tools
echo "[*] Installing packages and programs ..."

sudo apt-get -yy install curl wget ca-certificates gnupg lsb-release &> /dev/null 2>> $LOG_FILE
sudo apt-get -yy install libreoffice thunderbird firefox &> /dev/null 2>> $LOG_FILE

# Install development tools

sudo apt-get -yy install git python3 python3-pip golang-go virtualbox &> /dev/null 2>> $LOG_FILE

# Check if goland is already installed before installing it
if ! command -v goland &> /dev/null 2>> $LOG_FILE
then
    sudo snap install goland --classic &> /dev/null 2>> $LOG_FILE
fi

# Check if pycharm-professional is already installed before installing it
if ! command -v pycharm-professional &> /dev/null 2>> $LOG_FILE
then
    sudo snap install pycharm-professional --classic &> /dev/null 2>> $LOG_FILE
fi

echo "[*] Installation done!"

## Install docker

# Add Docker's official GPG key and Docker repository to APT sources
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>> $LOG_FILE

sudo apt-get update -qq

# Install Docker CE, CLI, and containerd
sudo apt-get install -yy docker-ce docker-ce-cli containerd.io

# Install security tools
sudo add-apt-repository ppa:openvpn-apt-beta/openvpn-beta
sudo apt-get update -qq
sudo apt-get -yy install nmap wireshark exiftool openvpn3

## Install communication tools

# Check if slack is already installed before installing it
if ! snap list slack &> /dev/null 2>> $LOG_FILE
then
    sudo snap install slack --classic
fi

# Check if discord is already installed before installing it
if ! snap list discord &> /dev/null 2>> $LOG_FILE
then
    sudo snap install discord
fi

# Mattermost
curl -L -o mattermost-desktop.deb https://releases.mattermost.com/desktop/4.7.0/mattermost-desktop-4.7.0-linux-amd64.deb
sudo dpkg -i mattermost-desktop.deb

##### Setting Visual Style

# Define variables
BLACK="#000000"

# Set wallpaper to plain black
gsettings set org.gnome.desktop.background primary-color "$BLACK"
gsettings set org.gnome.desktop.background secondary-color "$BLACK"
gsettings set org.gnome.desktop.background color-shading-type "solid"
echo "Wallpaper image changed successfully."

# Set theme to dark
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"

# Install Microsoft fonts
sudo apt-get install -yy ttf-mscorefonts-installer
sudo /usr/lib/msttcorefonts/update-ms-fonts.sh

# Set up the terminal style
PS1='\[\e[38;2;25;116;210m\]\u\[\e[m\]@\[\e[38;2;179;179;179m\]\h\[\e[m\]:\[\e[0;36m\]\w\[\e[m\] \[\e[0;32m\]\$ \[\e[m\]'

# Set up the tools bar with some of these apps
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'discord_discord.desktop', 'slack_slack.desktop', 'mattermost-desktop_mattermost-desktop.desktop', 'firefox.desktop', 'code_code.desktop', 'pycharm-professional_pycharm-professional.desktop', 'goland_goland.desktop', 'org.gnome.Terminal.desktop']"

##### Setting system teaks
echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.conf
