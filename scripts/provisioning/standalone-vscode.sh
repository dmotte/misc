#!/bin/bash

set -e

# TODO make this similar to the other provisioning scripts
# TODO add support for data directory
# TODO option --launcher=default or --launcher=/path/to/vscode.desktop or --launcher= (default, no launcher is created)

# This script can be used to set up a standalone installation of Visual Studio
# Code in a specific directory

# Tested on Debian 12 (bookworm)

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/provisioning/standalone-vscode.sh) linux-x64

# Ensure that some variables are defined
: "${1:?}"

readonly main_dir=${STANDALONE_VSCODE_MAIN_DIR:-$HOME/apps/vscode}
readonly archive_url="https://code.visualstudio.com/sha/download?build=stable&os=$1"
readonly archive_path=$main_dir/archive.tar.gz

readonly launcher_default=~/.local/share/applications/vscode.desktop
if [ -n "$STANDALONE_VSCODE_LAUNCHER" ]; then
    launcher=$STANDALONE_VSCODE_LAUNCHER
elif [ -d "$(dirname "$launcher_default")" ]; then
    launcher=$launcher_default
fi

################################################################################

if [ -d "$main_dir" ]; then
    echo "Directory $main_dir already exists. Installed app version:"
    "$main_dir/VSCode-$1/bin/code" -v

    main_dir_old=$main_dir-old-$(date -u +%Y-%m-%d-%H%M%S)
    echo "Moving $main_dir to $main_dir_old"
    mv -T "$main_dir" "$main_dir_old"
fi

mkdir -p "$main_dir"

echo "Downloading $archive_url to $archive_path"
curl -fLo "$archive_path" "$archive_url"

echo "Extracting $archive_path to $main_dir"
tar -xzf "$archive_path" -C "$main_dir"

readonly data_old=$main_dir_old/VSCode-$1/data
readonly data_new=$main_dir/VSCode-$1/data
if [ -n "$main_dir_old" ] && [ -d "$data_old" ]; then
    echo "Moving data dir from $data_old to $data_new"
    mv -T "$data_old" "$data_new"
fi

echo 'Installed app version:'
"$main_dir/VSCode-$1/bin/code" -v

################################################################################

if [ -n "$launcher" ]; then
    echo "Creating launcher file in $launcher"
    install -m644 /dev/stdin "$launcher" << EOF
[Desktop Entry]
Name=Visual Studio Code
Exec=$main_dir/VSCode-$1/code %f
Comment=Visual Studio Code
Terminal=false
Icon=$main_dir/VSCode-$1/resources/app/resources/linux/code.png
Type=Application
EOF
fi

echo 'Installation completed successfully'
