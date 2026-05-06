#!/bin/bash

set -e

# This script installs and configures overlayroot on Debian, with tmpfs as the
# upper filesystem

# Inspired by https://spin.atomicobject.com/protecting-ubuntu-root-filesystem/

# Tested on Debian 13 (trixie)

# Note: once overlayroot is configured on your system, you can temporarily
# access the underlying root filesystem in write mode by either running
# "sudo overlayroot-chroot" or booting the system with the
# "overlayroot=disabled" (or simply "overlayroot=") boot parameter

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

################################################################################

[ -e "/etc/overlayroot.local.conf" ] || changing=y

dpkg -s overlayroot >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y overlayroot; }

echo 'overlayroot="tmpfs:recurse=0"' |
    install -DTm600 /dev/stdin /etc/overlayroot.local.conf

# Fix for the "mount: /: fsconfig() failed: overlay: No changes allowed in
# reconfigure" issue, otherwise the overlay root is mounted in read-only mode
echo -e '[Service]\nEnvironment=LIBMOUNT_FORCE_MOUNT2=always' |
    install -DTvm644 /dev/stdin \
        /etc/systemd/system/systemd-remount-fs.service.d/50-mount2.conf

################################################################################

if [ "$OVERLAYROOT_TMPFS_RELOAD" = always ] || {
    [ "$OVERLAYROOT_TMPFS_RELOAD" = when-changed ] && [ "$changing" = y ]
}; then
    systemctl daemon-reload
fi
