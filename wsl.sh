sudo apt-get update -y &> ~/update.log
sudo apt-get upgrade -y &> ~/update.log

# Install programming languages and general tools
sudo apt-get install -yy git python3 python3-pip golang-go &> /dev/null
sudo apt-get install -yy ca-certificates curl gnupg lsb-release &> /dev/null

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list &> /dev/null

sudo apt-get update -y &> /dev/null
sudo apt-get install -yy docker-ce docker-ce-cli containerd.io &> /dev/null

# Install security tools
sudo apt-get install -yy netcat wireshark libimage-exiftool-perl &> /dev/null

# Add current user to the docker group and restart the shell
sudo groupadd docker &> /dev/null
sudo usermod -aG docker "${USER}" &> /dev/null
newgrp docker &> /dev/null
sudo chmod 666 /var/run/docker.sock &> /dev/null

echo "WSL 2 setup complete!"
