#!/bin/bash

set -e

# This script installs Waydroid via the official APT repository

# Inspired by the official guide:
# https://docs.waydro.id/usage/install-on-desktops#ubuntu-debian-and-derivatives
# See also the official Debian instructions to connect to a third-party
# repository: https://wiki.debian.org/DebianRepository/UseThirdParty

# Tested on Debian 13 (trixie)

# Note: if you want to use Waydroid with a non-supported GPU, or inside a VM,
# you can enable software-rendering by running the following command:
#     printf '%s\n' ro.hardware.gralloc=default ro.hardware.egl=swiftshader |
#         sudo tee -a /var/lib/waydroid/waydroid.cfg
# Make sure the lines were added to the "[properties]" section of the
# configuration file.
# Then restart Waydroid to make the changes effective.
# Source: https://docs.waydro.id/faq/get-waydroid-to-work-through-a-vm

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

################################################################################

codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)

for i in curl gnupg; do
    dpkg -s "$i" >/dev/null 2>&1 ||
        { apt_update_if_old; apt-get install -y "$i"; }
done

readonly waydroid_gpg_url='https://repo.waydro.id/waydroid.gpg'
readonly waydroid_gpg_checksum='71fe05d735c812e15fe229bf10106b02b62561be8aa5280d63a58e25a5c0c5e2'
readonly waydroid_gpg_path='/usr/share/keyrings/waydroid.gpg'

tmpdir=$(mktemp -d --tmpdir install-waydroid-XXXXXXXXXX)
trap 'rm -rf "$tmpdir"' EXIT

readonly tmp_waydroid_gpg=$tmpdir/waydroid.gpg

echo "Downloading $waydroid_gpg_url to $tmp_waydroid_gpg"
curl -fLo "$tmp_waydroid_gpg" "$waydroid_gpg_url"

echo "Verifying checksum for $tmp_waydroid_gpg"
echo "$waydroid_gpg_checksum $tmp_waydroid_gpg" | sha256sum -c

echo "Copying $tmp_waydroid_gpg to $waydroid_gpg_path"
install -Tm644 "$tmp_waydroid_gpg" "$waydroid_gpg_path"

[ -e /etc/apt/sources.list.d/waydroid.sources ] || changing=y

tee /etc/apt/sources.list.d/waydroid.sources << EOF
Types: deb
URIs: https://repo.waydro.id/
Suites: $codename
Components: main
Signed-By: /usr/share/keyrings/waydroid.gpg
EOF

if [ "$changing" = y ]; then apt-get update; fi

dpkg -s waydroid >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y waydroid; }
