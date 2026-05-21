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

function ensure_line() {
    local file="$1"
    local line="$2"

    touch "$file"
    if ! grep -Fxq "$line" "$file"; then
        printf "%s\n" "$line" >> "$file"
    fi
}

function install_go_links() {
    sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go
    sudo ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
}

sudo apt-get install -yy -qq ca-certificates curl

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
    amd64) GO_ARCH="amd64" ;;
    arm64) GO_ARCH="arm64" ;;
    armhf) GO_ARCH="armv6l" ;;
    *) echo "Unsupported Go architecture: $ARCH"; exit 1 ;;
esac

VERSION="$(curl -fsSL https://go.dev/VERSION?m=text | head -n 1)"
ARCHIVE="/tmp/${VERSION}.linux-${GO_ARCH}.tar.gz"

if [ -x /usr/local/go/bin/go ]; then
    CURRENT_VERSION="$(/usr/local/go/bin/go env GOVERSION)"
    if [ "$CURRENT_VERSION" = "$VERSION" ]; then
        echo_subtopic "Go $VERSION is already installed."
        install_go_links
        ensure_line "$HOME/.profile" 'export PATH="$PATH:/usr/local/go/bin"'
        ensure_line "$HOME/.bashrc" 'export PATH="$PATH:/usr/local/go/bin"'
        export PATH="$PATH:/usr/local/go/bin"
        return 0 2> /dev/null || exit 0
    fi

    if ! confirm "Go $CURRENT_VERSION is installed. Update to $VERSION?"; then
        echo_subtopic "Skipping Go update."
        return 0 2> /dev/null || exit 0
    fi
fi

echo_topic "Installing Go $VERSION..."
curl -fsSL "https://go.dev/dl/${VERSION}.linux-${GO_ARCH}.tar.gz" -o "$ARCHIVE"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$ARCHIVE"
rm -f "$ARCHIVE"
install_go_links

ensure_line "$HOME/.profile" 'export PATH="$PATH:/usr/local/go/bin"'
ensure_line "$HOME/.bashrc" 'export PATH="$PATH:/usr/local/go/bin"'

export PATH="$PATH:/usr/local/go/bin"
if ! command -v go > /dev/null 2>&1; then
    echo "ERROR: go is still not available on PATH. Check /usr/local/go/bin and restart your shell."
    exit 1
fi

echo_subtopic "Go installation done."
