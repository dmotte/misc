#!/bin/bash

set -e

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/get-standalone-golang.sh) amd64 1.20.7

# To change Go environment via the ~/go symlink (if you have multiple Go environments installed):
# rm ~/go && ln -s ~/apps/go1.20.7/go ~/go

GOLANG_DIR_PATH="$HOME/apps/go$2"
GOLANG_ARCHIVE_URL="https://go.dev/dl/go$2.linux-$1.tar.gz"
GOLANG_ARCHIVE_PATH="$GOLANG_DIR_PATH/archive.tar.gz"

if [ -d "$GOLANG_DIR_PATH" ]; then
    GOLANG_OLD_DIR_PATH="$GOLANG_DIR_PATH-old-$(date +%Y-%m-%d-%H%M%S)"
    echo "Directory $GOLANG_DIR_PATH already exists. Moving to $GOLANG_OLD_DIR_PATH"
    mv "$GOLANG_DIR_PATH" "$GOLANG_OLD_DIR_PATH"
fi

mkdir -p "$GOLANG_DIR_PATH"

echo "Downloading $GOLANG_ARCHIVE_URL to $GOLANG_ARCHIVE_PATH"
curl -SLo "$GOLANG_ARCHIVE_PATH" "$GOLANG_ARCHIVE_URL"

echo "Extracting $GOLANG_ARCHIVE_PATH to $GOLANG_DIR_PATH"
tar -xzf "$GOLANG_ARCHIVE_PATH" -C "$GOLANG_DIR_PATH"

echo -n 'Installed app version: '
"$GOLANG_DIR_PATH/go/bin/go" version

if [ -e ~/go ]; then
    echo 'Skipping symlink creation as ~/go already exists'
else
    echo 'Creating ~/go symlink'
    ln -s "$GOLANG_DIR_PATH/go" ~/go
fi

# shellcheck disable=SC2016
line='export PATH="$PATH:$HOME/go/bin"'
if grep "$line" ~/.profile >/dev/null; then
    echo 'Skipping PATH addition in ~/.profile as it seems already present'
else
    echo "Adding $line to ~/.profile"
    echo "$line" >> ~/.profile
    echo 'You may have to log out and back in for it to take effect'
fi

echo 'Installation completed successfully'
