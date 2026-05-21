#!/bin/bash

set -euo pipefail

function echo_topic() {
    echo "[*] $1"
}

function echo_subtopic() {
    echo " |_ $1"
}

function confirm() {
    local prompt="$1"
    local response

    if ! read -r -p "$prompt [y/N] " response; then
        return 1
    fi

    case "$response" in
        [yY] | [yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

function setup_kubectl_completion() {
    sudo mkdir -p /etc/bash_completion.d
    kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
    echo_subtopic "kubectl bash completion installed."
}

echo_topic "Installing kubectl..."

if dpkg-query -W -f='${db:Status-Abbrev}' ca-certificates 2> /dev/null | grep -q '^ii ' &&
    dpkg-query -W -f='${db:Status-Abbrev}' curl 2> /dev/null | grep -q '^ii ' &&
    dpkg-query -W -f='${db:Status-Abbrev}' bash-completion 2> /dev/null | grep -q '^ii '; then
    echo_subtopic "kubectl apt dependencies are already installed."
else
    sudo apt-get install -yy -qq ca-certificates curl bash-completion
fi

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
    amd64) KUBECTL_ARCH="amd64" ;;
    arm64) KUBECTL_ARCH="arm64" ;;
    *) echo "Unsupported kubectl architecture: $ARCH"; exit 1 ;;
esac

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
if command -v kubectl > /dev/null 2>&1; then
    CURRENT_VERSION="$(kubectl version --client=true -o json 2> /dev/null | sed -n 's/.*"gitVersion": "\([^"]*\)".*/\1/p')"
    if [ "$CURRENT_VERSION" = "$VERSION" ]; then
        echo_subtopic "kubectl $VERSION is already installed."
        setup_kubectl_completion
        return 0 2> /dev/null || exit 0
    fi

    if ! confirm "kubectl $CURRENT_VERSION is installed. Update to $VERSION?"; then
        echo_subtopic "Skipping kubectl update."
        setup_kubectl_completion
        return 0 2> /dev/null || exit 0
    fi
fi

curl -fsSLo "$TMP_DIR/kubectl" "https://dl.k8s.io/release/${VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl"
curl -fsSLo "$TMP_DIR/kubectl.sha256" "https://dl.k8s.io/release/${VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl.sha256"

printf "%s  %s\n" "$(cat "$TMP_DIR/kubectl.sha256")" "$TMP_DIR/kubectl" | sha256sum --check --status

sudo install -o root -g root -m 0755 "$TMP_DIR/kubectl" /usr/local/bin/kubectl
echo_subtopic "kubectl $VERSION installation done."
setup_kubectl_completion
