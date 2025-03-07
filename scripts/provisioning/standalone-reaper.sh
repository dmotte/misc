#!/bin/bash

set -e

# This script can be used to set up a standalone installation of Cockos REAPER
# in a specific directory

# Note: by default the configuration is stored in ~/.config/REAPER. See the
# readme-linux.txt file in the downloaded tarball for more details

# Tested on Debian 12 (bookworm)

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/provisioning/standalone-reaper.sh) -ulauto 7.34

options=$(getopt -o +a:c:d:ul: -l arch: -l checksum: -l install-dir: \
    -l update -l launcher: -- "$@")
eval "set -- $options"

arch=x86_64
checksum=''
install_dir="$HOME/apps/reaper"
update=n
launcher=''

while :; do
    case $1 in
        -a|--arch) shift; arch=$1;;
        -c|--checksum) shift; checksum=$1;;
        -d|--install-dir) shift; install_dir=$1;;
        -u|--update) update=y;;
        -l|--launcher) shift; launcher=$1;;
        --) shift; break;;
    esac
    shift
done

readonly version=${1:?}

[ "$launcher" != auto ] || launcher=~/.local/share/applications/reaper.desktop

################################################################################

major=$(echo "$version" | cut -d. -f1)
minor=$(echo "$version" | cut -d. -f2-)

# TODO implement update (you need to understand where data is saved)

readonly app_dir="$install_dir/reaper"

if [ "$update" = y ]; then
    if [ -d "$install_dir" ]; then
        echo "Directory $install_dir already exists. Installed app version:"
        "$app_dir/bin/TODO" -v

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

readonly archive_url="https://www.reaper.fm/files/$major.x/reaper$major${minor}_linux_$arch.tar.xz"
readonly archive_path=$install_dir/archive.tar.xz

echo "Downloading $archive_url to $archive_path"
curl -fLo "$archive_path" "$archive_url"

if [ -n "$checksum" ]; then
    echo "$checksum $archive_path" | sha256sum -c
fi

echo "Extracting $archive_path to $app_dir"
tar -xJf "$archive_path" -C "$install_dir"
mv -T "$install_dir/reaper_linux_$arch" "$app_dir"

echo 'Installed app version:'
"$app_dir/bin/TODO" -v

readonly data_dir=$app_dir/data

if [ "$update" = y ] && [ -n "$install_dir_old" ]; then
    readonly data_old=$install_dir_old/reaper/data

    if [ -d "$data_old" ]; then
        echo "Moving data dir from $data_old to $data_dir"
        mv -T "$data_old" "$data_dir"
    else
        echo 'Not moving data dir from the old installation because it does' \
            'not exist'
    fi
fi

# TODO check why this subdirectory $app_dir/REAPER; maybe it's better to move out of it

if [ -n "$launcher" ]; then
    echo "Creating launcher file $launcher"
    install -m644 /dev/stdin "$launcher" << EOF
[Desktop Entry]
Name=REAPER standalone
Exec=$app_dir/REAPER/reaper %f
Comment=REAPER standalone
Terminal=false
Icon=$app_dir/REAPER/Resources/main.png
Type=Application
EOF
fi
