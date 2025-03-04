#!/bin/bash

set -e

# This scripts installs Aqua Trivy via the official APT repository

# Inspired by the official guide:
# https://trivy.dev/v0.59/getting-started/installation/#debianubuntu-official
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

for i in curl gnupg; do
    dpkg -s "$i" >/dev/null 2>&1 ||
        { apt_update_if_old; apt-get install -y "$i"; }
done

cert=$(fetch_and_check \
    https://aquasecurity.github.io/trivy-repo/deb/public.key \
    51ca5d1384095c462099add67e46b028e0df0ff741c0f95ad30f561c4fad1ad4)
echo "$cert" | gpg --dearmor -o /usr/share/keyrings/trivy.gpg

[ -e /etc/apt/sources.list.d/trivy.sources ] || changing=y

tee /etc/apt/sources.list.d/trivy.sources << 'EOF'
Types: deb
URIs: https://aquasecurity.github.io/trivy-repo/deb
Suites: generic
Components: main
Signed-By: /usr/share/keyrings/trivy.gpg
EOF

if [ "$changing" = y ]; then apt-get update; fi

dpkg -s trivy >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y trivy; }
