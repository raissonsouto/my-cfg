sudo apt-get update -y &> /dev/null
sudo apt-get upgrade -y &> /dev/null

# Install programming languages and general tools
sudo apt-get install -yy ca-certificates curl gnupg lsb-release &> /dev/null
sudo apt-get install -yy git python3 python3-pip &> /dev/null

# Install security tools
sudo apt-get install -yy netcat libimage-exiftool-perl &> /dev/null

echo "WSL 2 setup complete!"
