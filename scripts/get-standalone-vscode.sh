#!/bin/bash

set -e

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/get-standalone-vscode.sh) linux-x64

# Ensure that some variables are defined
: "${1:?}"

main_dir=${STANDALONE_VSCODE_MAIN_DIR:-$HOME/apps/vscode}
archive_url="https://code.visualstudio.com/sha/download?build=stable&os=$1"
archive_path=$main_dir/archive.tar.gz

launcher_default=~/.local/share/applications/vscode.desktop
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
    mv "$main_dir" "$main_dir_old"
fi

mkdir -p "$main_dir"

echo "Downloading $archive_url to $archive_path"
curl -fLo "$archive_path" "$archive_url"

echo "Extracting $archive_path to $main_dir"
tar -xzf "$archive_path" -C "$main_dir"

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
