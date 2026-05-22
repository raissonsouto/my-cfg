#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

echo_session "Enhancing system theme"

echo_topic "Verifying if gsettings is installed..."
if ! command -v gsettings > /dev/null 2>&1; then
    echo_error "gsettings not found."
fi
echo_subtopic "Gsettings installed"

echo_topic "Setting wallpaper to solid black..."
gsettings set org.gnome.desktop.background picture-options 'none'
gsettings set org.gnome.desktop.background primary-color '#111111'
gsettings set org.gnome.desktop.background color-shading-type "solid"
echo_subtopic "Done"

echo_topic "Setting dark theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
echo_subtopic "Done"

echo_topic "Setting dash-dock style..."
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size '16'
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
echo_subtopic "Done"

echo_topic "Setting desktop icons style..."
gsettings set org.gnome.shell.extensions.ding icon-size 'small'
gsettings set org.gnome.shell.extensions.ding show-home false
echo_subtopic "Done"

echo_topic "Removing multiple workspaces..."
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
echo_subtopic "Done"

echo_topic "Disabling terminal notifications..."
if gsettings list-schemas | grep -Fxq "org.gnome.Ptyxis"; then
    gsettings set org.gnome.Ptyxis visual-process-leader false
fi

if gsettings list-schemas | grep -Fxq "org.gnome.desktop.notifications.application"; then
    for APP_ID in org-gnome-ptyxis org-gnome-terminal; do
        APP_PATH="/org/gnome/desktop/notifications/application/${APP_ID}/"
        gsettings set "org.gnome.desktop.notifications.application:$APP_PATH" enable false
        gsettings set "org.gnome.desktop.notifications.application:$APP_PATH" show-banners false
        gsettings set "org.gnome.desktop.notifications.application:$APP_PATH" enable-sound-alerts false
    done
fi
echo_subtopic "Terminal notifications disabled"

echo_topic "Verifying if gnome-extensions is installed..."
if ! command -v gnome-extensions > /dev/null 2>&1; then
    echo_error "Gnome-extensions not found."
fi
echo_subtopic "Gnome-extensions installed"

echo_topic "Installing Gnome extensions..."
GNOME_EXTENSIONS=(
    "top-bar-organizer@julian.gse.jsts.xyz"
    "windowIsReady_Remover@nunofarruca@gmail.com"
    "AlphabeticalAppGrid@stuarthayhurst"
    "caffeine@patapon.info"
    "Hide_Activities@shay.shayel.org"
    "gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com"
)

GNOME_SHELL_VERSION="$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)"

for EXTENSION_ID in "${GNOME_EXTENSIONS[@]}"; do
    if gnome-extensions list | grep -Fxq "$EXTENSION_ID"; then
        echo_subtopic "$EXTENSION_ID is already installed."
        gnome-extensions enable "$EXTENSION_ID" || echo_subtopic "$EXTENSION_ID installed; log out and back in before enabling if GNOME has not loaded it yet."
        continue
    fi

    if ! EXTENSION_QUERY=$(curl -G -Lfs "https://extensions.gnome.org/extension-query/" --data-urlencode "search=$EXTENSION_ID"); then
        echo_subtopic "Skipping $EXTENSION_ID: extension query failed."
        continue
    fi

    if ! VERSION_TAG=$(printf "%s\n" "$EXTENSION_QUERY" |
        jq -r --arg uuid "$EXTENSION_ID" --arg shell "$GNOME_SHELL_VERSION" '
            (.extensions // [] | map(select(.uuid == $uuid)) | first) as $extension
            | if $extension == null then empty
              else ($extension.shell_version_map // []) as $versions
              | if ($versions | type) == "array" then
                  (([$versions[] | select((.shell_version? | tostring) == $shell) | .pk] | max)
                  // ([$versions[] | .pk] | max)
                  // empty)
                elif ($versions | type) == "object" then
                  (($versions[$shell].pk // $versions[$shell])
                  // ([$versions[] | .pk? // .] | max)
                  // empty)
                else empty
                end
              end
        '); then
        echo_subtopic "Skipping $EXTENSION_ID: extension metadata could not be parsed."
        continue
    fi

    if [ -z "$VERSION_TAG" ] || [ "$VERSION_TAG" = "null" ]; then
        echo_subtopic "Skipping $EXTENSION_ID: no compatible version found."
        continue
    fi

    echo_subtopic "Extension ID: $EXTENSION_ID | Version tag: $VERSION_TAG"

    echo_subtopic "Downloading extension..."
    ZIP_PATH="/tmp/${EXTENSION_ID}.zip"
    if ! wget -q -O "$ZIP_PATH" "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"; then
        echo_subtopic "Skipping $EXTENSION_ID: download failed."
        rm -f "$ZIP_PATH"
        continue
    fi

    if ! unzip -tq "$ZIP_PATH" > /dev/null; then
        echo_subtopic "Skipping $EXTENSION_ID: downloaded file is not a valid extension archive."
        rm -f "$ZIP_PATH"
        continue
    fi

    gnome-extensions install --force "$ZIP_PATH"

    if gnome-extensions list | grep -Fxq "$EXTENSION_ID"; then
        gnome-extensions enable "$EXTENSION_ID" || echo_subtopic "Installed $EXTENSION_ID; log out and back in before enabling if GNOME has not loaded it yet."
    else
        echo_subtopic "Installed $EXTENSION_ID; log out and back in before enabling if GNOME has not loaded it yet."
    fi
    rm -f "$ZIP_PATH"
    echo_subtopic "Done"
done

echo_topic "Configuring Top Bar Organizer..."
TOP_BAR_ORGANIZER_SCHEMA_DIR="$HOME/.local/share/gnome-shell/extensions/top-bar-organizer@julian.gse.jsts.xyz/schemas"
if [ -d "$TOP_BAR_ORGANIZER_SCHEMA_DIR" ]; then
    GSETTINGS_SCHEMA_DIR="$TOP_BAR_ORGANIZER_SCHEMA_DIR" python3 - <<'PY'
import ast
import subprocess

schema = "org.gnome.shell.extensions.top-bar-organizer"

known_non_native_items = [
    "appindicator-kstatusnotifieritem-Slack_status_icon_1",
    "appindicator-kstatusnotifieritem-slack",
    "appindicator-kstatusnotifieritem-mattermost",
    "appindicator-kstatusnotifieritem-Mattermost",
    "appindicator-kstatusnotifieritem-discord",
    "appindicator-kstatusnotifieritem-Discord",
    "appindicator-kstatusnotifieritem-telegramdesktop",
    "appindicator-kstatusnotifieritem-TelegramDesktop",
    "appindicator-kstatusnotifieritem-org.telegram.desktop",
    "appindicator-kstatusnotifieritem-steam",
    "appindicator-kstatusnotifieritem-Steam",
    "appindicator-kstatusnotifieritem-spotify",
    "appindicator-kstatusnotifieritem-Spotify",
    "appindicator-kstatusnotifieritem-obs",
    "appindicator-kstatusnotifieritem-com.obsproject.Studio",
    "appindicator-kstatusnotifieritem-vlc",
    "appindicator-kstatusnotifieritem-VLC",
    "appindicator-kstatusnotifieritem-org.videolan.VLC",
    "appindicator-kstatusnotifieritem-qbittorrent",
    "appindicator-kstatusnotifieritem-qBittorrent",
    "appindicator-kstatusnotifieritem-org.qbittorrent.qBittorrent",
    "appindicator-kstatusnotifieritem-zoom",
    "appindicator-kstatusnotifieritem-Zoom",
    "appindicator-kstatusnotifieritem-us.zoom.Zoom",
    "appindicator-kstatusnotifieritem-dropbox",
    "appindicator-kstatusnotifieritem-Dropbox",
    "appindicator-kstatusnotifieritem-insync",
    "appindicator-kstatusnotifieritem-Insync",
    "appindicator-kstatusnotifieritem-nextcloud",
    "appindicator-kstatusnotifieritem-Nextcloud",
    "appindicator-kstatusnotifieritem-keepassxc",
    "appindicator-kstatusnotifieritem-KeePassXC",
    "appindicator-kstatusnotifieritem-bitwarden",
    "appindicator-kstatusnotifieritem-Bitwarden",
    "appindicator-kstatusnotifieritem-1password",
    "appindicator-kstatusnotifieritem-1Password",
    "appindicator-kstatusnotifieritem-solaar",
    "appindicator-kstatusnotifieritem-Solaar",
]

def get_order(key):
    output = subprocess.check_output(["gsettings", "get", schema, key], text=True).strip()
    try:
        value = ast.literal_eval(output)
    except (SyntaxError, ValueError):
        value = []
    return value if isinstance(value, list) else []

def set_order(key, value):
    rendered = repr(value).replace('"', "'")
    subprocess.check_call(["gsettings", "set", schema, key, rendered])

left = get_order("left-box-order")
center = get_order("center-box-order")
right = get_order("right-box-order")

non_native = []
for item in [*known_non_native_items, *left, *center, *right]:
    if item.startswith("appindicator-kstatusnotifieritem-") and item not in non_native:
        non_native.append(item)

def without_non_native(items):
    return [item for item in items if item not in non_native]

set_order("left-box-order", [*non_native, *without_non_native(left)])
set_order("center-box-order", without_non_native(center))
set_order("right-box-order", without_non_native(right))
PY
    echo_subtopic "Non-native app indicators configured for the left top bar box."
else
    echo_subtopic "Top Bar Organizer schema not found; log out and back in, then rerun setup-ui.sh."
fi

echo_topic "Configuring chat app autostart..."
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/slack.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Slack
Comment=Start Slack in the background
Exec=/usr/bin/slack --startup
Icon=slack
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

cat > "$HOME/.config/autostart/mattermost-desktop.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Mattermost
Comment=Start Mattermost in the background
Exec=/opt/Mattermost/mattermost-desktop --hidden
Icon=mattermost-desktop
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

python3 - <<'PY'
import json
from pathlib import Path

path = Path.home() / ".config/Slack/storage/root-state.json"
if path.exists():
    data = json.loads(path.read_text())
    settings = data.setdefault("settings", {})
    settings["runFromTray"] = True
    settings["hideOnStartup"] = True
    settings["launchOnStartup"] = True
    user_choices = settings.setdefault("userChoices", {})
    user_choices["launchOnStartup"] = True
    settings.setdefault("slackDefaults", {})["runFromTray"] = True
    settings.setdefault("slackDefaults", {})["hideOnStartup"] = True
    path.write_text(json.dumps(data, separators=(",", ":")))
PY
echo_subtopic "Slack and Mattermost autostart entries configured."
