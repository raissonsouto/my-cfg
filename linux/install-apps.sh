#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

DISTRO="${DISTRO:-$(lsb_release -cs)}"
export DEBIAN_FRONTEND="noninteractive"

echo_session "Installing apps"

function apt_install() {
    local tools=("$@")
    local missing=()

    for tool in "${tools[@]}"; do
        if dpkg-query -W -f='${db:Status-Abbrev}' "$tool" 2> /dev/null | grep -q '^ii '; then
            continue
        fi

        missing+=("$tool")
    done

    if [ ${#missing[@]} -eq 0 ]; then
        echo_subtopic "Apt packages already installed."
        return
    fi

    echo_subtopic "Installing ${#missing[@]} apt package(s)..."
    if sudo apt-get install -yy -qq "${missing[@]}"; then
        echo_subtopic "Apt package installation done."
    else
        echo_error "Installing apt packages: ${missing[*]}"
    fi
}

function write_apt_source() {
    local path="$1"
    local content="$2"

    if [ -f "$path" ] && [ "$(cat "$path")" = "$content" ]; then
        echo_subtopic "$path is already configured."
        return
    fi

    printf "%s\n" "$content" | sudo tee "$path" > /dev/null
}

function configure_wireshark_capture() {
    local dumpcap_path

    echo_topic "Configuring Wireshark packet capture permissions..."

    if ! getent group wireshark > /dev/null; then
        sudo groupadd --system wireshark
    fi

    sudo usermod -aG wireshark "$USER"

    if ! dumpcap_path="$(command -v dumpcap)"; then
        echo_subtopic "dumpcap not found; install Wireshark first, then rerun."
        return
    fi

    sudo chgrp wireshark "$dumpcap_path"
    sudo chmod 750 "$dumpcap_path"

    if command -v setcap > /dev/null 2>&1; then
        sudo setcap cap_net_raw,cap_net_admin=eip "$dumpcap_path"
        echo_subtopic "dumpcap capabilities configured."
    else
        echo_subtopic "setcap not found; install libcap2-bin, then rerun."
    fi

    echo_subtopic "Log out and back in for wireshark group access."
}

sudo mkdir -p /etc/apt/keyrings

echo_topic "Cleaning stale apt repository files..."
sudo rm -f \
    /etc/apt/sources.list.d/mattermost_stable.list \
    /etc/apt/sources.list.d/openvpn-packages.list \
    /etc/apt/sources.list.d/openvpn-packages.sources \
    /etc/apt/sources.list.d/spotify.list \
    /etc/apt/sources.list.d/spotify.sources \
    /etc/apt/trusted.gpg.d/spotify.gpg

APT_PACKAGES=("apt-transport-https" "ca-certificates" "curl" "gpg" "gnupg" "jq" "libcap2-bin" "lsb-release" "software-properties-common" "wget" "unzip")
apt_install "${APT_PACKAGES[@]}"

echo_topic "Accepting package licenses..."
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections

echo_topic "Adding apt repositories..."
echo_subtopic "Adding brave repository"

if [ -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ]; then
    echo_subtopic "Brave keyring already exists."
else
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
fi

write_apt_source "/etc/apt/sources.list.d/brave-browser-release.sources" "Types: deb
URIs: https://brave-browser-apt-release.s3.brave.com/
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/brave-browser-archive-keyring.gpg"
sudo rm -f /etc/apt/sources.list.d/brave-browser-release.list

echo_subtopic "Adding mattermost repository"
curl -fsSL https://deb.packages.mattermost.com/pubkey.gpg | sudo \
    gpg --dearmor --yes -o /usr/share/keyrings/mattermost-archive-keyring.gpg
write_apt_source "/etc/apt/sources.list.d/mattermost_stable.sources" "Types: deb
URIs: https://deb.packages.mattermost.com
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/mattermost-archive-keyring.gpg"

echo_subtopic "Adding obs-studio repository"
sudo add-apt-repository -y ppa:obsproject/obs-studio

OPENVPN_PACKAGE="openvpn3"
if [ "$DISTRO" = "resolute" ] || apt-cache show openvpn3-client > /dev/null 2>&1; then
    echo_subtopic "Using Ubuntu archive package openvpn3-client"
    OPENVPN_PACKAGE="openvpn3-client"
    sudo rm -f /etc/apt/sources.list.d/openvpn-packages.list /etc/apt/sources.list.d/openvpn-packages.sources
else
    echo_subtopic "Adding openvpn3 repository"
    curl -fsSL https://packages.openvpn.net/packages-repo.gpg | sudo tee /etc/apt/keyrings/openvpn.asc > /dev/null
    write_apt_source "/etc/apt/sources.list.d/openvpn-packages.sources" "Types: deb
URIs: https://packages.openvpn.net/openvpn3/ubuntu
Suites: $DISTRO
Components: main
Signed-By: /etc/apt/keyrings/openvpn.asc"
    sudo rm -f /etc/apt/sources.list.d/openvpn-packages.list
fi

echo_subtopic "Adding spotify repository"

curl -fsS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo \
    gpg --dearmor --yes -o /etc/apt/keyrings/spotify.gpg

write_apt_source "/etc/apt/sources.list.d/spotify.sources" "Types: deb
URIs: https://repository.spotify.com
Suites: stable
Components: non-free
Signed-By: /etc/apt/keyrings/spotify.gpg"

echo_subtopic "Adding vscode repository"

if [ -f /etc/apt/keyrings/packages.microsoft.gpg ]; then
    echo_subtopic "Microsoft keyring already exists."
else
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg

    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg \
        /etc/apt/keyrings/packages.microsoft.gpg
fi

write_apt_source "/etc/apt/sources.list.d/vscode.sources" "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64 arm64 armhf
Signed-By: /etc/apt/keyrings/packages.microsoft.gpg"
sudo rm -f /etc/apt/sources.list.d/vscode.list

rm -f /tmp/packages.microsoft.gpg

echo_topic "Apt repositories added"

echo_topic "Starting initial apt update/upgrade..."
sudo apt-get update -qq
sudo apt-get upgrade -yy -qq
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
    "$OPENVPN_PACKAGE"
    "python3"
    "python3-venv"
    "python3-pip"
    "qbittorrent"
    "spotify-client"
    "tmux"
    "torbrowser-launcher"
    "tree"
    "ttf-mscorefonts-installer"
    "vim"
    "vlc"
    "wireshark"
)

apt_install "${APT_APPS[@]}"

#sudo /usr/lib/msttcorefonts/update-ms-fonts.sh

source "$SCRIPT_DIR/tools/golang.sh"
source "$SCRIPT_DIR/tools/rust.sh"
source "$SCRIPT_DIR/tools/docker.sh"
source "$SCRIPT_DIR/tools/kubectl.sh"
source "$SCRIPT_DIR/tools/slack.sh"

echo_topic "Enabling groups access..."
configure_wireshark_capture
