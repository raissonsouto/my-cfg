#!/bin/bash

echo_session "Enhancing system theme"

echo_topic "Verifying if gsettings is installed..."
if ! which gsettings > /dev/null 2>&1; then
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

echo_topic "Verifying if gnome-extensions is installed..."
if ! which gnome-extensions > /dev/null 2>&1; then
    echo_error "Gnome-extensions not found."
fi
echo_subtopic "Gnome-extensions installed"

echo_topic "Installing Gnome extensions..."
GNOME_EXTENSIONS=(
    "https://extensions.gnome.org/extension/4356/top-bar-organizer/"
    "https://extensions.gnome.org/extension/1007/window-is-ready-notification-remover/"
    "https://extensions.gnome.org/extension/4269/alphabetical-app-grid/"
    "https://extensions.gnome.org/extension/517/caffeine/"
    "https://extensions.gnome.org/extension/4485/favourites-in-appgrid/"
    "https://extensions.gnome.org/extension/744/hide-activities-button/"
    "https://extensions.gnome.org/extension/3906/remove-app-menu/"
    "https://extensions.gnome.org/extension/3933/toggle-night-light/"
    "https://extensions.gnome.org/extension/7102/language-switch-button/"
)

for i in "${GNOME_EXTENSIONS[@]}"
do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
    echo_subtopic "Extension ID: $EXTENSION_ID | Version tag: $VERSION_TAG"

    echo_subtopic "Downloading extension..."
    wget -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    gnome-extensions install --force ${EXTENSION_ID}.zip

    if ! gnome-extensions list | grep --quiet ${EXTENSION_ID}; then
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${EXTENSION_ID}
    fi
    gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
    echo_subtopic "Done"
done
