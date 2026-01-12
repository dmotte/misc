#!/bin/bash

set -e

# This script can be used to set up a standalone installation of
# Raspberry Pi Imager (rpi-imager) in a specific directory

# Tested on Debian 13 (trixie)

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/provisioning/standalone-rpi-imager.sh) -lauto

# Note: on first launch, the application will require you to set up automatic
# privilege escalation in order to be able to write to storage devices

options=$(getopt -o +c:d:l: -l checksum: -l install-dir: -l launcher: -- "$@")
eval "set -- $options"

checksum=''
install_dir="$HOME/apps/rpi-imager"
launcher=''

while :; do
    case $1 in
        -c|--checksum) shift; checksum=$1;;
        -d|--install-dir) shift; install_dir=$1;;
        -l|--launcher) shift; launcher=$1;;
        --) shift; break;;
    esac
    shift
done

readonly version=${1:-latest}

[ "$launcher" != auto ] ||
    launcher=~/.local/share/applications/rpi-imager.desktop

################################################################################

if [ -d "$install_dir" ]; then
    echo "Directory $install_dir already exists" >&2; exit 1
fi

mkdir -pv "$install_dir"

readonly imager_url="https://downloads.raspberrypi.com/imager/imager_${version}_amd64.AppImage"
readonly imager_path=$install_dir/imager.AppImage

echo "Downloading $imager_url to $imager_path"
curl -fLo "$imager_path" "$imager_url"

if [ -n "$checksum" ]; then
    echo "$checksum $imager_path" | sha256sum -c
fi

chmod -v +x "$imager_path"

if [ -n "$launcher" ]; then
    echo "Creating launcher file $launcher"
    7z e "$imager_path" usr/share/icons/hicolor/scalable/apps/rpi-imager.svg -so \
        > "$install_dir/icon.svg"
    echo 5ef45ade3239f9710ee3f4d5e0c65d03b40621898f2ff35ecfdf6025b223a753 \
        "$install_dir/icon.svg" | sha256sum -c

    install -Tm644 /dev/stdin "$launcher" << EOF
[Desktop Entry]
Type=Application
Name=Raspberry Pi Imager
Icon=$install_dir/icon.svg
Exec=$imager_path %F
Terminal=false
EOF
fi
