#!/bin/bash

set -e

# This script installs yabridge by downloading the tarball directly from the
# official GitHub repository

# Inspired by the official guide:
# https://github.com/robbert-vdh/yabridge?tab=readme-ov-file#usage

# Tested on Debian 12 (bookworm)

# Usage example:
#   ./yabridge.sh -p 5.1.1
# Then you can close and reopen your terminal, and you can run:
#   yabridgectl add "$HOME/.wine/drive_c/Program Files/Steinberg/VSTPlugins"
#   yabridgectl sync

options=$(getopt -o +c:p -l checksum: -l add-to-path -- "$@")
eval "set -- $options"

checksum=''
add_to_path=n

while :; do
    case $1 in
        -c|--checksum) shift; checksum=$1;;
        -p|--add-to-path) add_to_path=y;;
        --) shift; break;;
    esac
    shift
done

readonly version=${1:?}

################################################################################

readonly install_dir=~/.local/share
readonly app_dir="$install_dir/yabridge"
readonly app_path="$app_dir/yabridgectl"

if [ -d "$app_dir" ]; then
    echo "Directory $app_dir already exists" >&2; exit 1
fi

mkdir -p "$install_dir"

readonly archive_url="https://github.com/robbert-vdh/yabridge/releases/download/$version/yabridge-$version.tar.gz"
readonly archive_path="$install_dir/yabridge.tar.gz"

echo "Downloading $archive_url to $archive_path"
curl -fLo "$archive_path" "$archive_url"

if [ -n "$checksum" ]; then
    echo "$checksum $archive_path" | sha256sum -c
fi

echo "Extracting $archive_path to $install_dir"
tar -xzf "$archive_path" -C "$install_dir"

[ -e "$app_path" ] || { echo "File $app_path not found" >&2; exit 1; }

if [ "$add_to_path" = y ]; then
    # shellcheck disable=SC2016
    readonly line='export PATH="$PATH:$HOME/.local/share/yabridge"'
    if grep -Fx "$line" ~/.bashrc >/dev/null 2>&1; then
        echo 'Skipping PATH addition to ~/.bashrc as it seems already present'
    else
        echo "Adding $line to ~/.bashrc"
        echo "$line" >> ~/.bashrc
        echo 'You may have to close and reopen your terminal for it to take' \
            'effect'
    fi
fi
