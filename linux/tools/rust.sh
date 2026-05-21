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

function install_rust_links() {
    local tool

    for tool in cargo rustc rustdoc rustfmt rustup; do
        if [ -x "$HOME/.cargo/bin/$tool" ]; then
            sudo ln -sf "$HOME/.cargo/bin/$tool" "/usr/local/bin/$tool"
        fi
    done
}

echo_topic "Installing Rust..."

if dpkg-query -W -f='${db:Status-Abbrev}' build-essential 2> /dev/null | grep -q '^ii ' &&
    dpkg-query -W -f='${db:Status-Abbrev}' ca-certificates 2> /dev/null | grep -q '^ii ' &&
    dpkg-query -W -f='${db:Status-Abbrev}' curl 2> /dev/null | grep -q '^ii '; then
    echo_subtopic "Rust apt dependencies are already installed."
else
    sudo apt-get install -yy -qq build-essential ca-certificates curl
fi

export PATH="$PATH:$HOME/.cargo/bin"

if command -v rustup > /dev/null 2>&1; then
    RUSTUP_CHECK="$(rustup check 2> /dev/null || true)"
    if printf "%s\n" "$RUSTUP_CHECK" | grep -qi 'update available'; then
        if confirm "Rust stable toolchain is already installed. Update it?"; then
            rustup update stable
        else
            echo_subtopic "Skipping Rust update."
        fi
    elif command -v rustc > /dev/null 2>&1 && rustup default | grep -q '^stable'; then
        echo_subtopic "Rust stable toolchain is already up to date."
    else
        rustup default stable
    fi
else
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

export PATH="$PATH:$HOME/.cargo/bin"

if [ ! -x "$HOME/.cargo/bin/cargo" ]; then
    echo_subtopic "cargo not found after rustup setup; reinstalling stable toolchain."
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
fi

install_rust_links

ensure_line "$HOME/.profile" '[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"'
ensure_line "$HOME/.bashrc" '[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"'

if ! command -v cargo > /dev/null 2>&1; then
    echo "ERROR: cargo is still not available. Check $HOME/.cargo/bin and restart your shell."
    exit 1
fi

echo_subtopic "Rust installation done."
