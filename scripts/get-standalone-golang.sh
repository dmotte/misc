#!/bin/bash

set -e

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/get-standalone-golang.sh) amd64 1.20.7

# To change Go environment via the ~/go symlink (if you have multiple Go environments installed):
# rm ~/go && ln -s ~/apps/go1.20.7/go ~/go

golang_dir_path="$HOME/apps/go$2"
golang_archive_url="https://go.dev/dl/go$2.linux-$1.tar.gz"
golang_archive_path="$golang_dir_path/archive.tar.gz"

if [ -d "$golang_dir_path" ]; then
    golang_old_dir_path="$golang_dir_path-old-$(date -u +%Y-%m-%d-%H%M%S)"
    echo "Directory $golang_dir_path already exists. Moving to $golang_old_dir_path"
    mv "$golang_dir_path" "$golang_old_dir_path"
fi

mkdir -p "$golang_dir_path"

echo "Downloading $golang_archive_url to $golang_archive_path"
curl -fLo "$golang_archive_path" "$golang_archive_url"

echo "Extracting $golang_archive_path to $golang_dir_path"
tar -xzf "$golang_archive_path" -C "$golang_dir_path"

echo -n 'Installed app version: '
"$golang_dir_path/go/bin/go" version

if [ -e ~/go ]; then
    echo 'Skipping symlink creation as ~/go already exists'
else
    echo 'Creating ~/go symlink'
    ln -s "$golang_dir_path/go" ~/go
fi

# shellcheck disable=SC2016
line='export PATH="$PATH:$HOME/go/bin"'
if grep "$line" ~/.profile >/dev/null 2>&1; then
    echo 'Skipping PATH addition in ~/.profile as it seems already present'
else
    echo "Adding $line to ~/.profile"
    echo "$line" >> ~/.profile
    echo 'You may have to log out and back in for it to take effect'
fi

echo 'Installation completed successfully'
