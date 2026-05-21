#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

echo_session "Setting up shortcuts"

echo_topic "Applying terminal shortcuts..."

if [ -f "$HOME/.bash_aliases" ] && cmp -s "$SCRIPT_DIR/.bash_aliases" "$HOME/.bash_aliases"; then
    echo "--> .bash_aliases is already up to date."
elif cp "$SCRIPT_DIR/.bash_aliases" "$HOME/.bash_aliases"; then
    echo "--> .bash_aliases file copied successfully."
else
    echo_error "copying .bash_aliases file."
fi

if grep -q '.bash_aliases' "$HOME/.bashrc"; then
    echo "--> .bashrc already uses .bash_aliases."
elif command -v python3 > /dev/null 2>&1; then
    python3 - "$HOME/.bashrc" <<'PY'
from pathlib import Path
import sys

bashrc = Path(sys.argv[1])
text = bashrc.read_text() if bashrc.exists() else ""
text = text.rstrip() + "\n\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi\n"
bashrc.write_text(text)
PY
    echo "--> .bashrc uses .bash_aliases."
else
    echo_subtopic "Skipping .bash_aliases setup: python3 not found."
fi

echo "[*] Terminal shortcuts applied."

echo_topic "Verifying if gsettings is installed..."
if ! command -v gsettings > /dev/null 2>&1; then
    echo_error "gsettings not found."
fi
echo_subtopic "Gsettings installed"

echo "[*] Applying system shortcuts ..."

function schema_exists() {
    gsettings list-schemas | grep -Fxq "$1"
}

function schema_has_key() {
    gsettings list-keys "$1" | grep -Fxq "$2"
}

function set_custom_keybinding() {
    local path="$1"
    local name="$2"
    local command="$3"
    local binding="$4"
    local custom_keybindings
    local updated_keybindings

    if ! command -v python3 > /dev/null 2>&1; then
        echo_error "python3 not found."
        return
    fi

    custom_keybindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    updated_keybindings=$(python3 - "$custom_keybindings" "$path" <<'PY'
import ast
import sys

remove_paths = {
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/",
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/",
}
new_path = sys.argv[2]

try:
    paths = ast.literal_eval(sys.argv[1])
except (SyntaxError, ValueError):
    paths = []

paths = [path for path in paths if path not in remove_paths and path != new_path]
paths.append(new_path)

print(repr(paths).replace('"', "'"))
PY
)

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$updated_keybindings"
    gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path" name "$name"
    gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path" command "$command"
    gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path" binding "$binding"
}

echo_subtopic "Open file explorer: (Windows + E)"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "[]"
set_custom_keybinding "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/" "Open Files" "nautilus" "<Super>e"

echo_subtopic "Open settings: (Windows + S)"
gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "[]"
if schema_exists "org.gnome.shell.keybindings" && schema_has_key "org.gnome.shell.keybindings" "toggle-quick-settings"; then
    gsettings set org.gnome.shell.keybindings toggle-quick-settings "[]"
fi
set_custom_keybinding "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/" "Open Settings" "gnome-control-center" "<Super>s"
