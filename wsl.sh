#!/bin/bash

sudo apt-get update && sudo apt-get upgrade -y

# Install programming languages and general tools

sudo apt-get install -y git python3 python3-pip golang-go

sudo apt-get install -y ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install security tools
sudo apt-get install -y netcat wireshark libimage-exiftool-perl # metasploit-framework

# Add current user to the docker group and restart the shell
sudo groupadd docker
sudo usermod -aG docker ${USER}
newgrp docker
sudo chmod 666 /var/run/docker.sock
