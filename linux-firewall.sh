#!/bin/bash

# firstly made for UBUNTU 20.04

##### Install some software

# Update package list and upgrade installed packages
echo "~ Starting script~"
echo ""
echo "[*] Initial update ..."

cd ~
sudo apt-get update -qq
sudo apt-get upgrade &> /dev/null

echo "[*] Initial update done!"

# Installing Firewall
sudo apt-get install iptables &> /dev/null