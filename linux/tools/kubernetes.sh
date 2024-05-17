#!/bin/bash
# Raisson Souto, 2023

# The goal of this script is to automate the installation
# of kubernetes (1.27) at Ubuntu (22.04)

# Log file
LOG_FILE="logs.log"

# Disable swap
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
sudo swapoff -a

# Kernel modules installation
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configuration of sysctl parameters
cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply configurations on sysctl
sudo sysctl --system &> /dev/null 2>> $LOG_FILE

# Installing prerequisites 
sudo apt-get update -y &> /dev/null 2>> $LOG_FILE
sudo apt-get install ca-certificates curl gnupg lsb-release apt-transport-https -yy &> /dev/null 2>> $LOG_FILE

# Getting Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installing containerd
sudo apt update
sudo apt install containerd.io -yy

# Configuring containerd
sudo mkdir -p /etc/containerd && containerd config default | sudo tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Getting K8S GPG key
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Installing K8S
apt-get update -y &> /dev/null 2>> $LOG_FILE
apt-get install -yy kubeadm=1.27.0-00 kubelet=1.27.0-00 kubectl=1.27.0-00 &> /dev/null 2>> $LOG_FILE
apt-mark hold kubelet kubeadm kubectl &> /dev/null 2>> $LOG_FILE