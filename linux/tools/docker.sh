#!/bin/bash

sudo apt update -qq
sudo apt install -qq -yy apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -qq
sudo apt install -qq -yy docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker $USER
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s \
    https://api.github.com/repos/docker/compose/releases/latest | grep -oP \
    '"tag_name": "\K(.*)(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o \
    /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
