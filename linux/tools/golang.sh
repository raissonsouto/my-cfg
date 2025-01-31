#!/bin/bash

VERSION=$(curl -sL https://golang.org/VERSION?m=text | head -n 1 | awk '{print $1}')
wget https://go.dev/dl/$VERSION.linux-amd64.tar.gz -O ~/$VERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf ~/$VERSION.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile
source $HOME/.profile
rm ~/$VERSION.linux-amd64.tar.gz
