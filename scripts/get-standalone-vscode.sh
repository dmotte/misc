#!/bin/bash

set -e

# To run this script without downloading it:
# bash <(curl -sSL https://raw.githubusercontent.com/dmotte/utils/main/scripts/get-standalone-vscode.sh)

VSCODE_DIR_PATH="$HOME/apps/vscode"
VSCODE_ARCHIVE_URL='https://code.visualstudio.com/sha/download?build=stable&os=linux-x64'
VSCODE_ARCHIVE_PATH="$VSCODE_DIR_PATH/archive.tar.gz"

if [ -d "$VSCODE_DIR_PATH" ]; then
    echo "Directory $VSCODE_DIR_PATH already exists. Installed app version:"
    "$VSCODE_DIR_PATH/VSCode-linux-x64/bin/code" -v

    read -rp 'Overwrite? [yes/NO] '
    if [ "$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')" != 'yes' ]; then
        echo Aborting 1>&2
        exit 1
    fi
fi

mkdir -p "$VSCODE_DIR_PATH"

echo "Downloading $VSCODE_ARCHIVE_URL to $VSCODE_ARCHIVE_PATH"
curl -SLo "$VSCODE_ARCHIVE_PATH" "$VSCODE_ARCHIVE_URL"

echo "Extracting $VSCODE_ARCHIVE_PATH to $VSCODE_DIR_PATH"
tar -xzf "$VSCODE_ARCHIVE_PATH" -C "$VSCODE_DIR_PATH"

echo 'Installed app version:'
"$VSCODE_DIR_PATH/VSCode-linux-x64/bin/code" -v

echo 'Installation completed successfully'
