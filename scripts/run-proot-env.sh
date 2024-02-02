#!/bin/bash

set -e

# This script runs a command inside a custom PRoot environment. You can create
# several environments with different names

# It also works (I tested it) when run as a regular user (non-root) inside an
# unprivileged Podman container (i.e. created as a regular user on the host)

# Usage example:
#   PROOT_ADD_OPTIONS='--kernel-release=5.4.0-faked' \
#     ./run-proot-env.sh myenv uname -a

# Useful links:
# - https://proot-me.github.io/
# - https://wiki.termux.com/wiki/PRoot
# - https://github.com/termux/proot-distro/blob/master/proot-distro.sh

: "${PROOT_TARBALL_URL:=https://github.com/termux/proot-distro/releases/download/v4.7.0/debian-bookworm-x86_64-pd-v4.7.0.tar.xz}"
: "${PROOT_TARBALL_CHECKSUM:=164932ab77a0b94a8e355c9b68158a5b76d5abef89ada509488c44ff54655d61}"
: "${PROOT_TARBALL_TOP_DIR:=debian-bookworm-x86_64}"
: "${PROOT_WORKDIR:=/root}"

tarball_path=$(dirname "$0")/tarball.tar.xz
proot_url=https://proot.gitlab.io/proot/bin/proot
proot_path=$(dirname "$0")/proot
envs_dir=$(dirname "$0")/envs

[ $# -ge 1 ] || { echo 'Not enough args' >&2; exit 1; }
env_name="$1"; shift

if [ ! -e "$tarball_path" ]; then
    echo "Downloading tarball $PROOT_TARBALL_URL to $tarball_path"
    curl -fLo "$tarball_path" "$PROOT_TARBALL_URL"
    echo "$PROOT_TARBALL_CHECKSUM" "$tarball_path" | sha256sum -c
fi

if [ ! -e "$proot_path" ]; then
    echo "Downloading PRoot binary $proot_url to $proot_path"
    curl -fLo "$proot_path" "$proot_url"
    chmod +x "$proot_path"
fi

rootfs_dir="$envs_dir/$env_name"
rootfs_dir_tmp="$rootfs_dir-tmp-$(date +%Y-%m-%d-%H%M%S)"

if [ ! -d "$rootfs_dir" ]; then
    mkdir -p "$rootfs_dir_tmp"

    echo "Extracting tarball $tarball_path to $rootfs_dir"
    tar -x --auto-compress -f "$tarball_path" \
        --exclude="$PROOT_TARBALL_TOP_DIR"/{dev,proc,sys,tmp} \
        --recursive-unlink --preserve-permissions -C "$rootfs_dir_tmp"
    mv "$rootfs_dir_tmp/$PROOT_TARBALL_TOP_DIR" "$rootfs_dir"
    rm -r "$rootfs_dir_tmp"
fi

if [ $# = 0 ]; then set -- bash; fi

# shellcheck disable=SC2086
"$proot_path" \
    --rootfs="$rootfs_dir" --root-id --cwd="$PROOT_WORKDIR" \
    --bind=/{dev,proc,sys,tmp} \
    --bind=/etc/{host.conf,hosts,nsswitch.conf,resolv.conf} \
    $PROOT_ADD_OPTIONS \
    /usr/bin/env -i \
        HOME=/root LANG="$LANG" TERM="$TERM" \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        "$@"
