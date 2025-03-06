#!/bin/bash

set -e

# This script downloads the Wine Mono installer to the Wine cache of the
# current user. This can be useful because, if the installer is found in the
# cache when a wineprefix is created, Wine will skip the download prompt and
# silently install Wine Mono automatically.

# Tested on Debian 12 (bookworm)

# Usage example:
#   ./winemono.sh && wineboot --init

readonly wine_cache=~/.cache/wine

wine_version=$(wine --version)

case $wine_version in
wine-10.0)
    # Source: https://gitlab.winehq.org/wine/wine/-/blob/wine-10.0/dlls/appwiz.cpl/addons.c?ref_type=tags#L59
    readonly installer_url='http://source.winehq.org/winemono.php?arch=x86_64&v=9.4.0&winev=10.0'
    readonly installer_checksum='cf6173ae94b79e9de13d9a74cdb2560a886fc3d271f9489acb1cfdbd961cacb2'
    readonly installer_path="$wine_cache/wine-mono-9.4.0-x86.msi"
    ;;
*)
    echo "Unsupported Wine version $wine_version" >&2
    exit 1
    ;;
esac

if [ -e "$installer_path" ]; then
    echo "File $installer_path already exists. Skipping download"
    exit
fi

tmpdir=$(mktemp -d --tmpdir winemono-XXXXXXXXXX)
trap 'rm -rf $tmpdir' EXIT

readonly tmp_installer=$tmpdir/tmp-installer

echo "Downloading $installer_url to $tmp_installer"
curl -fLo "$tmp_installer" "$installer_url"

echo "Verifying checksum for $tmp_installer"
echo "$installer_checksum" "$tmp_installer" | sha256sum -c

echo "Copying $tmp_installer to $installer_path"
install -DTm644 "$tmp_installer" "$installer_path"
