#!/bin/bash

set -e

# This script installs Winetricks by downloading it directly from the official
# GitHub repository

# Inspired by the official guide:
# https://github.com/Winetricks/winetricks?tab=readme-ov-file#scripted-install

# Tested on Debian 12 (bookworm)

# Usage example: bash winetricks.sh 20250102

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

readonly git_tag=${1:?} script_checksum=$2

readonly script_url="https://raw.githubusercontent.com/Winetricks/winetricks/refs/tags/$git_tag/src/winetricks"
readonly script_path=/usr/bin/winetricks

if [ -e "$script_path" ]; then
    echo "File $script_path already exists. Skipping download"
    exit
fi

tmpdir=$(mktemp -d --tmpdir winetricks-XXXXXXXXXX)
trap 'rm -rf $tmpdir' EXIT

readonly tmp_script=$tmpdir/tmp-script

echo "Downloading $script_url to $tmp_script"
curl -fLo "$tmp_script" "$script_url"

if [ -n "$script_checksum" ]; then
    echo "Verifying checksum for $tmp_script"
    echo "$script_checksum $tmp_script" | sha256sum -c
fi

echo "Copying $tmp_script to $script_path"
install -DT "$tmp_script" "$script_path"
