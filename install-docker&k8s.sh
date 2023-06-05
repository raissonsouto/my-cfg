#!/bin/bash
# Raisson Souto, 2023
# The goal of this script is to automate the installation of docker and kubernetes in debian distributions

apt-get update -y
apt-get install ca-certificates curl gnupg lsb-release apt-transport-https -yy

distribution=(cat /etc/os-release | grep -oP '(?<=^ID=).+' | tr -d '"')
version=(cat /etc/os-release | grep -oP '(?<=^VERSION_CODENAME=).+' | tr -d '"')

curl -fsSL https://download.docker.com/linux/$distribution/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$distribution $version stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -yy docker-ce docker-ce-cli containerd.io

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -yy kubeadm kubelet kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable docker
systemctl daemon-reload
systemctl restart docker