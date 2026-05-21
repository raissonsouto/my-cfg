#!/bin/bash

set -euo pipefail

function echo_topic() {
    echo "[*] $1"
}

function echo_subtopic() {
    echo " |_ $1"
}

function confirm() {
    local prompt="$1"
    local response

    if ! read -r -p "$prompt [y/N] " response; then
        return 1
    fi

    case "$response" in
        [yY] | [yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

DISTRO="${DISTRO:-$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")}"

echo_topic "Installing Docker..."

function configure_docker_access() {
    if ! getent group docker > /dev/null; then
        sudo groupadd --system docker
    fi

    sudo usermod -aG docker "$USER"

    if command -v systemctl > /dev/null 2>&1 && [ -d /run/systemd/system ]; then
        sudo mkdir -p /etc/systemd/system/docker.socket.d
        cat <<'EOF' | sudo tee /etc/systemd/system/docker.socket.d/override.conf > /dev/null
[Socket]
SocketGroup=docker
SocketMode=0660
EOF
        sudo systemctl daemon-reload
        sudo systemctl enable --now docker.socket docker.service > /dev/null 2>&1 || true
    fi

    if [ -S /var/run/docker.sock ]; then
        sudo chown root:docker /var/run/docker.sock
        sudo chmod 660 /var/run/docker.sock
    fi

    if id -nG | tr ' ' '\n' | grep -Fxq docker; then
        echo_subtopic "Docker group is active in this shell."
    else
        echo_subtopic "Docker group is not active in this shell. Run: newgrp docker"
    fi
}

DOCKER_PACKAGES=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
DOCKER_INSTALLED=true
for package in "${DOCKER_PACKAGES[@]}"; do
    if ! dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2> /dev/null | grep -q '^ii '; then
        DOCKER_INSTALLED=false
        break
    fi
done

if [ "$DOCKER_INSTALLED" = true ]; then
    configure_docker_access
    sudo apt-get update -qq
    if apt-get --simulate install "${DOCKER_PACKAGES[@]}" | grep -q '^Inst '; then
        if confirm "Docker is already installed. Update Docker packages?"; then
            sudo apt-get install -yy -qq "${DOCKER_PACKAGES[@]}"
            configure_docker_access
            echo_subtopic "Docker packages updated."
        else
            echo_subtopic "Skipping Docker update."
        fi
    else
        echo_subtopic "Docker packages are already up to date."
    fi
    return 0 2> /dev/null || exit 0
fi

sudo apt-get update -qq
sudo apt-get install -yy -qq ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $DISTRO
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo rm -f /etc/apt/sources.list.d/docker.list

sudo apt-get update -qq
sudo apt-get install -yy -qq "${DOCKER_PACKAGES[@]}"

configure_docker_access
echo_subtopic "Docker installation done."
