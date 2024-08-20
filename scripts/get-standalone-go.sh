#!/bin/bash

set -e

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/get-standalone-go.sh) amd64 1.20.7

# To change Go environment via the ~/go symlink (if you have multiple Go environments installed):
# rm ~/go && ln -s ~/apps/go1.20.7/go ~/go

go_dir_path=${STANDALONE_GO_DIR_PATH:-$HOME/apps/go$2}
go_archive_url=https://go.dev/dl/go$2.linux-$1.tar.gz
go_archive_path=$go_dir_path/archive.tar.gz

################################################################################

if [ -d "$go_dir_path" ]; then
    go_old_dir_path=$go_dir_path-old-$(date -u +%Y-%m-%d-%H%M%S)
    echo "Directory $go_dir_path already exists. Moving to $go_old_dir_path"
    mv "$go_dir_path" "$go_old_dir_path"
fi

mkdir -p "$go_dir_path"

echo "Downloading $go_archive_url to $go_archive_path"
curl -fLo "$go_archive_path" "$go_archive_url"

echo "Extracting $go_archive_path to $go_dir_path"
tar -xzf "$go_archive_path" -C "$go_dir_path"

echo -n 'Installed app version: '
"$go_dir_path/go/bin/go" version

################################################################################

if [ -e ~/go ]; then
    echo 'Skipping symlink creation as ~/go already exists'
else
    echo 'Creating ~/go symlink'
    ln -s "$go_dir_path/go" ~/go
fi

# shellcheck disable=SC2016
line='export PATH="$PATH:$HOME/go/bin"'
if grep -Fx "$line" ~/.profile >/dev/null 2>&1; then
    echo 'Skipping PATH addition in ~/.profile as it seems already present'
else
    echo "Adding $line to ~/.profile"
    echo "$line" >> ~/.profile
    echo 'You may have to log out and back in for it to take effect'
fi

echo 'Installation completed successfully'
