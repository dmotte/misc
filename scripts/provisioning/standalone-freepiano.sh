#!/bin/bash

set -e

# This script can be used to set up a standalone installation of FreePiano
# in a specific directory

# Tested on:
#   - Debian 12 (bookworm) + Wine 10.0 + "winetricks fonts allfonts"
#   - Git Bash on Windows 10

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/provisioning/standalone-freepiano.sh) -lauto 2.2.2.1

# You can also add a custom keymap with a command like the following one:
# curl -fLo ~/apps/freepiano/freepiano/keymap/dmotte-intuitive.map https://raw.githubusercontent.com/dmotte/misc/main/configs/freepiano-keymaps/dmotte-intuitive.map

options=$(getopt -o +o:c:d:l: -l os: -l checksum: -l install-dir: \
    -l launcher: -- "$@")
eval "set -- $options"

os=''
checksum=''
install_dir="$HOME/apps/freepiano"
launcher=''

while :; do
    case $1 in
        -o|--os) shift; os=$1;;
        -c|--checksum) shift; checksum=$1;;
        -d|--install-dir) shift; install_dir=$1;;
        -l|--launcher) shift; launcher=$1;;
        --) shift; break;;
    esac
    shift
done

readonly version=${1:?}

if [ -z "$os" ]; then
    if [[ "$(uname)" = MINGW* ]]
        then os=windows
        else os=linux
    fi
fi

if [ "$launcher" = auto ]; then
    if [ "$os" = windows ]
        then launcher=~/Desktop/FreePiano.lnk
        else launcher=~/.local/share/applications/freepiano.desktop
    fi
fi

################################################################################

readonly app_dir="$install_dir/freepiano"

if [ -d "$install_dir" ]; then
    echo "Directory $install_dir already exists" >&2; exit 1
fi

mkdir -pv "$install_dir"

readonly archive_url="https://sourceforge.net/projects/freepiano/files/freepiano_${version}_win64.zip"
readonly archive_path=$install_dir/archive.zip

echo "Downloading $archive_url to $archive_path"
curl -fLo "$archive_path" "$archive_url"

if [ -n "$checksum" ]; then
    echo "$checksum $archive_path" | sha256sum -c
fi

echo "Extracting $archive_path to $install_dir"
unzip -q "$archive_path" -d "$install_dir"

if [ -n "$launcher" ]; then
    echo "Creating launcher file $launcher"
    if [ "$os" = windows ]; then
        create-shortcut "$app_dir/freepiano.exe" "$launcher"
    else
        install -Tm644 /dev/stdin "$launcher" << EOF
[Desktop Entry]
Type=Application
Name=FreePiano
# Icon=$app_dir/freepiano.exe
Exec=wine $app_dir/freepiano.exe %f
Terminal=false
EOF
    fi
fi
