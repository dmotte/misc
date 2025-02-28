#!/bin/bash

set -e

# TODO make this similar to the other provisioning scripts

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/provisioning/standalone-go.sh) amd64 1.20.7

# To change Go environment via the ~/go symlink (if you have multiple Go environments installed):
# rm ~/go && ln -s ~/apps/go1.20.7/go ~/go

# Ensure that some variables are defined
: "${1:?}" "${2:?}"

readonly main_dir=${STANDALONE_GO_MAIN_DIR:-$HOME/apps/go$2}
readonly archive_url=https://go.dev/dl/go$2.linux-$1.tar.gz
readonly archive_path=$main_dir/archive.tar.gz

################################################################################

if [ -d "$main_dir" ]; then
    main_dir_old=$main_dir-old-$(date -u +%Y-%m-%d-%H%M%S)
    echo "Directory $main_dir already exists. Moving to $main_dir_old"
    mv -T "$main_dir" "$main_dir_old"
fi

mkdir -p "$main_dir"

echo "Downloading $archive_url to $archive_path"
curl -fLo "$archive_path" "$archive_url"

echo "Extracting $archive_path to $main_dir"
tar -xzf "$archive_path" -C "$main_dir"

echo -n 'Installed app version: '
"$main_dir/go/bin/go" version

################################################################################

if [ -e ~/go ]; then
    echo 'Skipping symlink creation as ~/go already exists'
else
    echo 'Creating ~/go symlink'
    ln -s "$main_dir/go" ~/go
fi

# shellcheck disable=SC2016
readonly line='export PATH="$PATH:$HOME/go/bin"'
if grep -Fx "$line" ~/.profile >/dev/null 2>&1; then
    echo 'Skipping PATH addition in ~/.profile as it seems already present'
else
    echo "Adding $line to ~/.profile"
    echo "$line" >> ~/.profile
    echo 'You may have to log out and back in for it to take effect'
fi

echo 'Installation completed successfully'
