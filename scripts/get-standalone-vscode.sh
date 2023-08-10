#!/bin/bash

set -e

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/get-standalone-vscode.sh)

VSCODE_DIR_PATH="$HOME/apps/vscode"
VSCODE_ARCHIVE_URL='https://code.visualstudio.com/sha/download?build=stable&os=linux-x64'
VSCODE_ARCHIVE_PATH="$VSCODE_DIR_PATH/archive.tar.gz"
VSCODE_LAUNCHER_PATH="$HOME/.local/share/applications/vscode.desktop"

if [ -d "$VSCODE_DIR_PATH" ]; then
    echo "Directory $VSCODE_DIR_PATH already exists. Installed app version:"
    "$VSCODE_DIR_PATH/VSCode-linux-x64/bin/code" -v

    VSCODE_OLD_DIR_PATH="$VSCODE_DIR_PATH-old-$(date +%Y-%m-%d-%H%M%S)"
    echo "Moving $VSCODE_DIR_PATH to $VSCODE_OLD_DIR_PATH"
    mv "$VSCODE_DIR_PATH" "$VSCODE_OLD_DIR_PATH"
fi

mkdir -p "$VSCODE_DIR_PATH"

echo "Downloading $VSCODE_ARCHIVE_URL to $VSCODE_ARCHIVE_PATH"
curl -SLo "$VSCODE_ARCHIVE_PATH" "$VSCODE_ARCHIVE_URL"

echo "Extracting $VSCODE_ARCHIVE_PATH to $VSCODE_DIR_PATH"
tar -xzf "$VSCODE_ARCHIVE_PATH" -C "$VSCODE_DIR_PATH"

echo 'Installed app version:'
"$VSCODE_DIR_PATH/VSCode-linux-x64/bin/code" -v

echo "Creating launcher file in $VSCODE_LAUNCHER_PATH"
cat << EOF >> "$VSCODE_LAUNCHER_PATH"
[Desktop Entry]
Name=Visual Studio Code
Exec=$VSCODE_DIR_PATH/VSCode-linux-x64/code %f
Comment=Visual Studio Code
Terminal=false
Icon=$VSCODE_DIR_PATH/VSCode-linux-x64/resources/app/resources/linux/code.png
Type=Application
EOF

echo 'Installation completed successfully'
