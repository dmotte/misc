#!/bin/bash

set -e

# This scripts installs HashiCorp Vagrant via the official APT repository

# Inspired by the official guide:
# https://developer.hashicorp.com/vagrant/install#linux
# See also the official Debian instructions to connect to a third-party
# repository: https://wiki.debian.org/DebianRepository/UseThirdParty

# Tested on Debian 12 (bookworm)

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
    https://apt.releases.hashicorp.com/gpg \
    cafb01beac341bf2a9ba89793e6dd2468110291adfbb6c62ed11a0cde6c09029)
echo "$cert" |
    gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

[ -e /etc/apt/sources.list.d/hashicorp.sources ] || changing=y

tee /etc/apt/sources.list.d/hashicorp.sources << EOF
Types: deb
URIs: https://apt.releases.hashicorp.com
Suites: $codename
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/hashicorp-archive-keyring.gpg
EOF

if [ "$changing" = y ]; then apt-get update; fi

dpkg -s vagrant >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y vagrant; }
