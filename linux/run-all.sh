#!/bin/bash

source ./utils.sh

DISTRO=$(lsb_release -c | awk '{print $2}')

echo -e "${YELLOW}"
echo -e "    🚀 Starting my-cfg! Sit back and relax..."
echo -e ""
echo -e "    I'm about to install your apps, packages, and"
echo -e "    shortcuts, set up the system UI, and generate"
echo -e "    an SSH key pair."
echo -e ""
echo -e "    Sit back and relax...  😎 "
echo -e "${NC}"

echo -e "${GREEN}Username:${NC} $(whoami)"
echo -e "${GREEN}Current working dir:${NC} $(pwd)"
echo -e "${GREEN}Current Date/Time:${NC} $(date)"
echo -e "${GREEN}Ubuntu codename:${NC} $DISTRO"

source ./install-apps.sh
source ./add-shortcuts.sh
source ./setup-ui.sh

echo_topic "Veryfing if SSH key pair exists..."

if [ -f "$HOME/.ssh/id_rsa" ]; then
    echo_subtopic "SSH key already exists:"
    echo ""
    cat $HOME/.ssh/id_rsa.pub
else
    echo_subtopic "SSH key not found. Generating a new one..."
    keygen_log=$(ssh-keygen -t rsa -b 4096 2>&1)

    if [ $? -eq 0 ]; then
        echo_subtopic "SSH key successfully generated."
        echo ""
        cat $HOME/.ssh/id_rsa.pub
    else
        echo $keygen_log
        echo_error "Generating SSH key."
    fi
fi
