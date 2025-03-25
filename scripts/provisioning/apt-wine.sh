#!/bin/bash

set -e

# This scripts installs Wine (Wine Is Not an Emulator) via the official WineHQ
# APT repository

# Inspired by the official guide:
# https://gitlab.winehq.org/wine/wine/-/wikis/Debian-Ubuntu
# See also the official Debian instructions to connect to a third-party
# repository: https://wiki.debian.org/DebianRepository/UseThirdParty

# Tested on Debian 12 (bookworm)

# Note: if you encounter "unmet dependencies" issues with APT, you can try to
# run "rm -rf /var/lib/apt/lists/*" and then retry

# If you want to enable the "Show dot files" Wine option:
#   wine reg add 'HKCU\Software\Wine' /v ShowDotFiles /t REG_SZ /d Y /f

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

fetch_and_check() { # Src: https://github.com/dmotte/misc
    local c s; c=$(curl -fsSL "$1"; echo x) &&
    s=$(echo -n "${c%x}" | sha256sum | cut -d' ' -f1) &&
    if [ "$s" = "$2" ]; then echo -n "${c%x}"
    else echo "Checksum verification failed for $1: got $s, expected $2" >&2
    return 1; fi
}

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

cert=$(fetch_and_check \
    https://dl.winehq.org/wine-builds/winehq.key \
    d965d646defe94b3dfba6d5b4406900ac6c81065428bf9d9303ad7a72ee8d1b8)
echo "$cert" | gpg --dearmor --yes -o /etc/apt/keyrings/winehq-archive.key

dpkg --add-architecture i386

[ -e "/etc/apt/sources.list.d/winehq-$codename.sources" ] || changing=y

tee "/etc/apt/sources.list.d/winehq-$codename.sources" << EOF
Types: deb
URIs: https://dl.winehq.org/wine-builds/debian
Suites: $codename
Components: main
Architectures: amd64 i386
Signed-By: /etc/apt/keyrings/winehq-archive.key
EOF

if [ "$changing" = y ]; then apt-get update; fi

dpkg -s winehq-stable >/dev/null 2>&1 || {
    apt_update_if_old; apt-get install -y --install-recommends winehq-stable
}
