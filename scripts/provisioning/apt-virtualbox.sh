#!/bin/bash

set -e

# This scripts installs Oracle VirtualBox via the official APT repository.
# Note that a reboot is required before being able to use VirtualBox

# Inspired by the official guide:
# https://www.virtualbox.org/wiki/Linux_Downloads
# See also the official Debian instructions to connect to a third-party
# repository: https://wiki.debian.org/DebianRepository/UseThirdParty

# Tested on Debian 12 (bookworm)

# Usage example: sudo ./apt-virtualbox.sh 7.0

# Note: to upgrade the package you just need to run the script with a newer
# version, and the old package will be removed automatically. This works
# because each "virtualbox-*" APT package declares "Provides: virtualbox" and
# "Conflicts: virtualbox", which basically make them mutually exclusive

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

readonly version=${1:?}

################################################################################

codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)

for i in curl gnupg linux-headers-generic; do
    dpkg -s "$i" >/dev/null 2>&1 ||
        { apt_update_if_old; apt-get install -y "$i"; }
done

cert=$(fetch_and_check \
    https://www.virtualbox.org/download/oracle_vbox_2016.asc \
    49e6801d45f6536232c11be6cdb43fa8e0198538d29d1075a7e10165e1fbafe2)
echo "$cert" |
    gpg --dearmor --yes -o /usr/share/keyrings/oracle-virtualbox-2016.gpg

[ -e /etc/apt/sources.list.d/virtualbox.sources ] || changing=y

tee /etc/apt/sources.list.d/virtualbox.sources << EOF
Types: deb
URIs: https://download.virtualbox.org/virtualbox/debian
Suites: $codename
Components: contrib
Architectures: amd64
Signed-By: /usr/share/keyrings/oracle-virtualbox-2016.gpg
EOF

if [ "$changing" = y ]; then apt-get update; fi

dpkg -s "virtualbox-$version" >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y "virtualbox-$version"; }
