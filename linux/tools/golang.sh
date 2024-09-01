#!/bin/bash

echo_topic "Installing Golang..."

VERSION=$(curl -sL https://golang.org/VERSION?m=text | head -n 1 | awk '{print $1}')
wget https://go.dev/dl/$VERSION.src.tar.gz
tar -C /usr/local -xzf $VERSION.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile
source $HOME/.profile
rm $VERSION.linux-amd64.tar.gz

echo_topic "Golang installed"
