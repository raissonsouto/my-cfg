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

function installed_deb_version() {
    dpkg-query -W -f='${Version}' slack-desktop 2> /dev/null || true
}

echo_topic "Installing Slack..."

if [ "$(dpkg --print-architecture)" != "amd64" ]; then
    echo_subtopic "Skipping Slack: official Linux desktop .deb is only available for amd64."
    return 0 2> /dev/null || exit 0
fi

echo_subtopic "Checking Slack dependencies..."
sudo apt-get install -yy -qq ca-certificates curl

echo_subtopic "Finding Slack .deb download URL..."
DOWNLOAD_PAGE="$(curl -fsSL https://slack.com/downloads/linux || true)"
DEB_URL="$(printf "%s\n" "$DOWNLOAD_PAGE" | grep -oE 'https://downloads\.slack-edge\.com/desktop-releases/linux/x64/[0-9.]+/slack-desktop-[0-9.]+-amd64\.deb' || true)"
DEB_URL="$(printf "%s\n" "$DEB_URL" | sort -V | tail -n 1)"

if [ -z "$DEB_URL" ]; then
    DEB_URL="$(curl -fsIL https://slack.com/downloads/instructions/ubuntu 2> /dev/null | awk -F': ' 'tolower($1) == "location" {print $2}' | tr -d '\r' | tail -n 1 || true)"
fi

if [ -z "$DEB_URL" ]; then
    RELEASE_NOTES="$(curl -fsSL https://slack.com/release-notes/linux || true)"
    LATEST_VERSION="$(printf "%s\n" "$RELEASE_NOTES" | grep -oE 'Slack [0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | awk '{print $2}')"
    if [ -n "$LATEST_VERSION" ]; then
        DEB_URL="https://downloads.slack-edge.com/desktop-releases/linux/x64/${LATEST_VERSION}/slack-desktop-${LATEST_VERSION}-amd64.deb"
    fi
fi

if [ -z "$DEB_URL" ] || ! printf "%s\n" "$DEB_URL" | grep -qE 'slack-desktop-[0-9.]+-amd64\.deb$'; then
    echo "ERROR: Could not find Slack .deb download URL from Slack."
    echo "       Visit https://slack.com/downloads/linux and download the .deb manually."
    exit 1
fi

LATEST_VERSION="$(basename "$DEB_URL" | sed -E 's/^slack-desktop-([0-9.]+)-amd64\.deb$/\1/')"
CURRENT_VERSION="$(installed_deb_version)"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo_subtopic "Slack $LATEST_VERSION is already installed."
    return 0 2> /dev/null || exit 0
fi

if [ -n "$CURRENT_VERSION" ] && ! confirm "Slack $CURRENT_VERSION is installed. Update to $LATEST_VERSION?"; then
    echo_subtopic "Skipping Slack update."
    return 0 2> /dev/null || exit 0
fi

DEB_PATH="/tmp/slack-desktop-${LATEST_VERSION}-amd64.deb"
echo_subtopic "Downloading Slack $LATEST_VERSION..."
curl -fsSL "$DEB_URL" -o "$DEB_PATH"
echo_subtopic "Installing Slack $LATEST_VERSION..."
sudo apt-get install -yy -qq "$DEB_PATH"
rm -f "$DEB_PATH"

if ! command -v slack > /dev/null 2>&1; then
    echo "ERROR: Slack package installation finished, but 'slack' is not on PATH."
    exit 1
fi

echo_subtopic "Slack $LATEST_VERSION installation done."
