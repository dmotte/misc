#!/bin/bash

set -e

# This script can be used to set up a standalone installation of a specific
# version of Go in a specific directory

# Tested on Debian 12 (bookworm)

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/provisioning/standalone-go.sh) -sp 1.20.7

# Example of how to change Go environment via the ~/go symlink (if you have
# multiple Go environments installed):
# rm ~/go && ln -s ~/apps/go1.20.7/go ~/go

options=$(getopt -o +a:c:d:sp -l arch: -l checksum: -l install-dir: \
    -l symlink -l symlink-to-path -- "$@")
eval "set -- $options"

arch=amd64
checksum=''
install_dir=''
symlink=n
symlink_to_path=n

while :; do
    case $1 in
        -a|--arch) shift; arch=$1;;
        -c|--checksum) shift; checksum=$1;;
        -d|--install-dir) shift; install_dir=$1;;
        -s|--symlink) symlink=y;;
        -p|--symlink-to-path) symlink_to_path=y;;
        --) shift; break;;
    esac
    shift
done

readonly version=$1

[ -n "$version" ] || { echo 'Version cannot be empty' >&2; exit 1; }

[ -n "$install_dir" ] || install_dir=$HOME/apps/go$version

################################################################################

if [ -d "$install_dir" ]; then
    echo "Directory $install_dir already exists" >&2; exit 1
fi

mkdir -p "$install_dir"

readonly app_dir="$install_dir/go"

readonly archive_url="https://go.dev/dl/go$version.linux-$arch.tar.gz"
readonly archive_path="$install_dir/archive.tar.gz"

echo "Downloading $archive_url to $archive_path"
curl -fLo "$archive_path" "$archive_url"

if [ -n "$checksum" ]; then
    echo "$checksum $archive_path" | sha256sum -c
fi

echo "Extracting $archive_path to $install_dir"
tar -xzf "$archive_path" -C "$install_dir"

if [ "$symlink" = y ]; then
    if [ -e ~/go ]; then
        echo 'Skipping symlink creation as ~/go already exists'
    else
        echo 'Creating ~/go symlink'
        ln -s "$app_dir" ~/go
    fi
fi

if [ "$symlink_to_path" = y ]; then
    # shellcheck disable=SC2016
    readonly line='export PATH="$PATH:$HOME/go/bin"'
    if grep -Fx "$line" ~/.profile >/dev/null 2>&1; then
        echo 'Skipping PATH addition in ~/.profile as it seems already present'
    else
        echo "Adding $line to ~/.profile"
        echo "$line" >> ~/.profile
        echo 'You may have to log out and back in for it to take effect'
    fi
fi
