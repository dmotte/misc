#!/bin/bash

set -e

# This script can be used to set up a standalone installation of Visual Studio
# Code in a specific directory

# Tested on Debian 12 (bookworm) and Windows 10 with Git Bash

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/provisioning/standalone-vscode.sh) -ulauto

options=$(getopt -o +b:o:a:c:d:uDl: -l build: -l os: -l arch: -l checksum: \
    -l install-dir: -l update -l create-data -l launcher: -- "$@")
eval "set -- $options"

build=stable
os=''
arch=x64
checksum=''
install_dir="$HOME/apps/vscode"
update=n
create_data=n
launcher=''

while :; do
    case $1 in
        -b|--build) shift; build=$1;;
        -o|--os) shift; os=$1;;
        -a|--arch) shift; arch=$1;;
        -c|--checksum) shift; checksum=$1;;
        -d|--install-dir) shift; install_dir=$1;;
        -u|--update) update=y;;
        -D|--create-data) create_data=y;;
        -l|--launcher) shift; launcher=$1;;
        --) shift; break;;
    esac
    shift
done

if [ -z "$os" ]; then
    if [[ "$(uname)" = MINGW* ]]
        then os=win32
        else os=linux
    fi
fi

if [ "$launcher" = auto ]; then
    if [ "$os" = win32 ]
        then launcher=~/Desktop/'Visual Studio Code.lnk'
        else launcher=~/.local/share/applications/vscode.desktop
    fi
fi

################################################################################

readonly app_dir="$install_dir/vscode"

if [ "$update" = y ]; then
    if [ -d "$install_dir" ]; then
        echo "Directory $install_dir already exists. Installed app version:"
        "$app_dir/bin/code" -v

        install_dir_old=$install_dir-old-$(date -u +%Y-%m-%d-%H%M%S)
        echo "Moving $install_dir to $install_dir_old"
        mv -T "$install_dir" "$install_dir_old"
    else
        echo "Directory $install_dir doesn't already exists. Installing from" \
            'scratch'
    fi
elif [ -d "$install_dir" ]; then
    echo "Directory $install_dir already exists" >&2; exit 1
fi

mkdir -p "$install_dir"

if [ "$os" = win32 ]; then
    readonly archive_url="https://code.visualstudio.com/sha/download?build=$build&os=$os-$arch-archive"
    readonly archive_path=$install_dir/archive.zip
else
    readonly archive_url="https://code.visualstudio.com/sha/download?build=$build&os=$os-$arch"
    readonly archive_path=$install_dir/archive.tar.gz
fi

echo "Downloading $archive_url to $archive_path"
curl -fLo "$archive_path" "$archive_url"

if [ -n "$checksum" ]; then
    echo "$checksum $archive_path" | sha256sum -c
fi

echo "Extracting $archive_path to $app_dir"
if [ "$os" = win32 ]; then
    unzip -q "$archive_path" -d "$app_dir"
else
    tar -xzf "$archive_path" -C "$install_dir"
    mv -T "$install_dir/VSCode-$os-$arch" "$app_dir"
fi

echo 'Installed app version:'
"$app_dir/bin/code" -v

readonly data_dir=$app_dir/data

if [ "$update" = y ] && [ -n "$install_dir_old" ]; then
    readonly data_old=$install_dir_old/vscode/data

    if [ -d "$data_old" ]; then
        echo "Moving data dir from $data_old to $data_dir"
        mv -T "$data_old" "$data_dir"
    else
        echo 'Not moving data dir from the old installation because it does' \
            'not exist'
    fi
fi

# The data directory enables Visual Studio Code's Portable mode. See
# https://code.visualstudio.com/docs/editor/portable
if [ "$create_data" = y ] && [ ! -d "$data_dir" ]; then
    echo "Creating data dir $data_dir"
    mkdir "$data_dir"
fi

if [ -n "$launcher" ]; then
    echo "Creating launcher file $launcher"
    if [ "$os" = win32 ]; then
        create-shortcut "$app_dir/Code.exe" "$launcher"
    else
        install -m644 /dev/stdin "$launcher" << EOF
[Desktop Entry]
Name=Visual Studio Code
Exec=$app_dir/code %f
Comment=Visual Studio Code
Terminal=false
Icon=$app_dir/resources/app/resources/linux/code.png
Type=Application
EOF
    fi
fi
