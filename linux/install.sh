#!/bin/bash

# Raisson Souto, 2023

# Update package list and upgrade installed packages

echo "[*] Starting initial update"

cd ~
sudo apt-get update -qq
sudo apt-get upgrade &> /dev/null 2>> $1

echo "[*] Initial update done!"

# Install general tools
echo "[*] Installing packages and programs ..."

APT_PACKAGES=(
    "ca-certificates"
    "curl"
    "gnupg"
    "lsb-release"
    "wget"
    "unzip"
    "dconf-editor"
    "gnome-shell-extension-manager"
    "gnome-shell-extension-prefs"
    "qbittorrent"
    "torbrowser-launcher"
)

SNAP_GENERAL_APPS=(
    "discord"
    "gimp"
    ""
    "brave"
    "libreoffice"
    "mattermost-desktop"
    "obs-studio"
    "spotify"
    "telegram-desktop"
    "vlc"
)

SNAP_PROGRAMMING_APPS=(
    "code"
    "winbox"
    "goland"
    "postman"
    "pycharm-professional"
)

PROGRAMMING_TOOLS=("git" "python3" "flutter" "python3-pip" "nmap" "wireshark" "exiftool")

function apt_install() {
    tools=("$@")

    for tool in "${tools[@]}"
    do
        echo "  - installing $tool" 
        sudo apt-get -yy install "$tool" &> /dev/null 2>> $1
    done
}

function snap_install() {
    tools=("$@")

    for tool in "${tools[@]}"
    do
        echo "  - installing $tool"
        sudo snap install "$tool" &> /dev/null 2>> $1
    done
}

apt_install "${APT_PACKAGES[@]}"
apt_install "${PROGRAMMING_TOOLS[@]}"

snap_install "${SNAP_GENERAL_APPS[@]}"
snap_install "${SNAP_PROGRAMMING_APPS[@]}"

sudo usermod -aG wireshark $USER

# Install Goland

wget https://go.dev/dl/go1.22.3.src.tar.gz
tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile
source $HOME/.profile

# Install Microsoft fonts
echo "[*] Installing Microsoft fonts"
sudo apt-get install -yy ttf-mscorefonts-installer
sudo /usr/lib/msttcorefonts/update-ms-fonts.sh

# Install openvpn
sudo add-apt-repository ppa:openvpn-apt-beta/openvpn-beta
sudo apt-get update -qq
sudo apt-get -yy install openvpn