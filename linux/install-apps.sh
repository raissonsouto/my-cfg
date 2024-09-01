#!/bin/bash

echo_session "Installing apps"

function apt_install() {
    tools=("$@")

    for tool in "${tools[@]}"; do
        echo_subtopic "Installing $tool..."
        if sudo apt-get -yy install "$tool"; then
            echo_subtopic "$tool installation done."
        else
            echo_error "Installing $tool."
        fi
    done
}

mkdir -p /etc/apt/keyrings

APT_PACKAGES=("apt-transport-https" "ca-certificates" "curl" "gpg" "gnupg" "lsb-release" "wget" "unzip")
apt_install "${APT_PACKAGES[@]}"

echo_topic "Adding apt repositories..."
echo_subtopic "Adding brave repository"

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
    https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee \
    /etc/apt/sources.list.d/brave-browser-release.list

echo_subtopic "Adding mattermost repository"
curl -fsS -o- https://deb.packages.mattermost.com/setup-repo.sh | sudo bash

echo_subtopic "Adding obs-studio repository"
sudo add-apt-repository ppa:obsproject/obs-studio

echo_subtopic "Adding openvpn3 repository"

curl -sSfL https://packages.openvpn.net/packages-repo.gpg >/etc/apt/keyrings/openvpn.asc

echo "deb [signed-by=/etc/apt/keyrings/openvpn.asc] \
    https://packages.openvpn.net/openvpn3/ubuntu $DISTRO main" | sudo \
    tee /etc/apt/sources.list.d/openvpn-packages.list

echo_subtopic "Adding spotify repository"

curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo \
    gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg

echo "deb http://repository.spotify.com stable non-free" | sudo \
    tee /etc/apt/sources.list.d/spotify.list

echo_subtopic "Adding vscode repository"

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg

sudo install -D -o root -g root -m 644 packages.microsoft.gpg \
    /etc/apt/keyrings/packages.microsoft.gpg

echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
    https://packages.microsoft.com/repos/code stable main" |sudo tee \
    /etc/apt/sources.list.d/vscode.list > /dev/null

rm -f packages.microsoft.gpg

echo_topic "Apt repositories added"

echo_topic "Starting initial apt update/upgrade..."
sudo apt-get update
sudo apt-get upgrade
echo_topic "Initial apt update/upgrade done"

echo_topic "Installing packages and apps..."
APT_APPS=(
    "brave-browser"
    "code"
    "dconf-editor"
    "exiftool"
    "gnome-shell-extension-manager"
    "gnome-shell-extension-prefs"
    "mattermost-desktop"
    "nmap"
    "obs-studio"
    "openvpn3"
    "python3.11"
    "python3.11-venv"
    "python3-pip"
    "qbittorrent"
    "slack"
    "spotify-client"
    "tmux"
    "torbrowser-launcher"
    "ttf-mscorefonts-installer"
    "vim"
    "vlc"
    "wireshark"
)

apt_install "${APT_APPS[@]}"

# curl -o /tmp/goland-2024.2.1.tar.gz "https://download-cdn.jetbrains.com/go/goland-2024.2.1.tar.gz"
# tar -zxvf /tmp/goland-2024.2.1.tar.gz -C /tmp
# cd /tmp/goland-2024.2.1
# ./install.sh 
# rm /tmp/goland-2024.2.1.tar.gz

#sudo /usr/lib/msttcorefonts/update-ms-fonts.sh

source ./tools/golang.sh
# source ./tools/docker.sh

echo_topic "Enabling groups access..."
sudo usermod -aG wireshark $USER
