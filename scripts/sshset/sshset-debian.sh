#!/bin/bash

set -e

readonly src_dir=${SSHSET_SRC_DIR:-/opt/sshset}

readonly gen_hostkeys=${SSHSET_GEN_HOSTKEYS:-true}
readonly gen_authkey=${SSHSET_GEN_AUTHKEY:-false}
readonly gen_authkey_comment=$SSHSET_GEN_AUTHKEY_COMMENT
readonly gen_idkey=${SSHSET_GEN_IDKEY:-false}
readonly gen_idkey_comment=$SSHSET_GEN_IDKEY_COMMENT

# TODO consider switch to toggle host keys generation (because it's not needed
# for the SSH client). Or maybe even have two separate scripts

# TODO consider "mode" variable that can be "system" (ssh_sys_dir=/etc/ssh),
# "user" (ssh_sys_dir=~/.ssh), "auto" (default, based on EUID)

# TODO test this script thoroughly

################################################################################

[ -d "$src_dir" ] || { echo "Dir $src_dir not found" >&2; exit 1; }

################################################################################

if [ "$EUID" = 0 ]; then
    # readonly ssh_sys_dir=/etc/ssh # TODO needed?

    ############################################################################

    find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/sshd-config/*" \
        -exec install -Dvm644 -t/etc/ssh/sshd_config.d {} +

    ############################################################################

    find /etc/ssh -mindepth 1 -maxdepth 1 -type f \
        \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
        -printf 'Removing existing %p\n' -delete

    find "$src_dir" -mindepth 2 -maxdepth 2 -type f \
        \( -path "$src_dir/host-keys/ssh_host_*_key" \
            -exec install -vm600 -t/etc/ssh {} + \) \
        -o \( -path "$src_dir/host-keys/ssh_host_*_key.pub" \
            -exec install -vm644 -t/etc/ssh {} + \)

    if [ "$gen_hostkeys" = true ]; then
        ssh-keygen -A # Generate the missing host keys

        mkdir -pv "$src_dir/host-keys"
        find /etc/ssh -mindepth 1 -maxdepth 1 -type f \
            \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
            -exec cp -nvt"$src_dir/host-keys" {} +
    fi

    ############################################################################

    files=$(find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/sshrc/*")
    if [ -n "$files" ]; then
        files=$(echo -n "$files" | LC_ALL=C sort)
        # We use "awk 1" instead of "cat" because it automatically appends a
        # trailing newline at the end of files that are missing it
        content=$(echo -n "$files" | xargs -rd\\n awk 1)
        echo "$content" | install -Tvm644 /dev/stdin /etc/ssh/sshrc
    fi

    ############################################################################

    find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/ssh-config/*" \
        -exec install -Dvm644 -t/etc/ssh/ssh_config.d {} +

    ############################################################################

    files=$(find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/known-hosts/*")
    if [ -n "$files" ]; then
        files=$(echo -n "$files" | LC_ALL=C sort)
        # We use "awk 1" instead of "cat" because it automatically appends a
        # trailing newline at the end of files that are missing it
        content=$(echo -n "$files" | xargs -rd\\n awk 1)
        echo "$content" | install -Tvm644 /dev/stdin /etc/ssh/ssh_known_hosts
    fi
else
    # readonly ssh_sys_dir=~/.ssh # TODO needed?

    install -dvm700 ~/.ssh

    ############################################################################

    echo 'Generating ~/.ssh/sshd_config'
    sed -E /etc/ssh/sshd_config \
        -e 's|^(Include)[ \t]+/etc/ssh/(.+)$|\1 ~/.ssh/\2|' \
        -e 's/^#?(Port)[ \t].*$/\1 2222/' \
        -e 's|^#?(HostKey)[ \t]+/etc/ssh/(.+)$|\1 ~/.ssh/\2|' \
        -e 's|^#?(PidFile)[ \t].*$|\1 ~/.ssh/sshd.pid|' \
        > ~/.ssh/sshd_config

    ############################################################################

    find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/sshd-config/*" \
        -exec install -Dvm644 -t ~/.ssh/sshd_config.d {} +

    ############################################################################

    find ~/.ssh -mindepth 1 -maxdepth 1 -type f \
        \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
        -printf 'Removing existing %p\n' -delete

    if [ "$gen_hostkeys" = true ]; then
        tmpdir=~/.ssh/sshset-tmp-gen-host-keys
        rm -frv "$tmpdir"; mkdir -pv "$tmpdir/etc/ssh"

        find "$src_dir" -mindepth 2 -maxdepth 2 -type f \
            \( -path "$src_dir/host-keys/ssh_host_*_key" \
                -exec install -vm600 -t"$tmpdir/etc/ssh" {} + \) \
            -o \( -path "$src_dir/host-keys/ssh_host_*_key.pub" \
                -exec install -vm644 -t"$tmpdir/etc/ssh" {} + \)

        ssh-keygen -Af "$tmpdir" # Generate the missing host keys

        find "$tmpdir/etc/ssh" -mindepth 1 -maxdepth 1 -type f \
            \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
            -exec mv -vt ~/.ssh {} +

        rm -rv "$tmpdir"

        mkdir -pv "$src_dir/host-keys"
        find ~/.ssh -mindepth 1 -maxdepth 1 -type f \
            \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
            -exec cp -nvt"$src_dir/host-keys" {} +
    else
        find "$src_dir" -mindepth 2 -maxdepth 2 -type f \
            \( -path "$src_dir/host-keys/ssh_host_*_key" \
                -exec install -vm600 -t ~/.ssh {} + \) \
            -o \( -path "$src_dir/host-keys/ssh_host_*_key.pub" \
                -exec install -vm644 -t ~/.ssh {} + \)
    fi

    ############################################################################

    files=$(find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/authorized-keys/*.pub")
    if [ -n "$files" ]; then
        files=$(echo -n "$files" | LC_ALL=C sort)
        # We use "awk 1" instead of "cat" because it automatically appends a
        # trailing newline at the end of files that are missing it
        content=$(echo -n "$files" | xargs -rd\\n awk 1)
        echo "$content" | install -Tvm600 /dev/stdin ~/.ssh/authorized_keys
    elif [ "$gen_authkey" = true ]; then
        mkdir -pv "$src_dir/authorized-keys"

        # We need the space between the "-C" flag and its value because it
        # can be an empty string
        ssh-keygen -ted25519 -C "$gen_authkey_comment" -N '' \
            -f"$src_dir/authorized-keys/id_ed25519"

        install -Tvm600 "$src_dir/authorized-keys/id_ed25519.pub" \
            ~/.ssh/authorized_keys
    fi

    ############################################################################

    files=$(find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/sshrc/*")
    if [ -n "$files" ]; then
        files=$(echo -n "$files" | LC_ALL=C sort)
        # We use "awk 1" instead of "cat" because it automatically appends a
        # trailing newline at the end of files that are missing it
        content=$(echo -n "$files" | xargs -rd\\n awk 1)
        echo "$content" | install -Tvm600 /dev/stdin ~/.ssh/rc
    fi

    ############################################################################

    files=$(find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/ssh-config/*")
    if [ -n "$files" ]; then
        files=$(echo -n "$files" | LC_ALL=C sort)
        # We use "awk 1" instead of "cat" because it automatically appends a
        # trailing newline at the end of files that are missing it
        content=$(echo -n "$files" | xargs -rd\\n awk 1)
        echo "$content" | install -Tvm644 /dev/stdin ~/.ssh/config
    fi

    ############################################################################

    files=$(find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/known-hosts/*")
    if [ -n "$files" ]; then
        files=$(echo -n "$files" | LC_ALL=C sort)
        # We use "awk 1" instead of "cat" because it automatically appends a
        # trailing newline at the end of files that are missing it
        content=$(echo -n "$files" | xargs -rd\\n awk 1)
        echo "$content" | install -Tvm600 /dev/stdin ~/.ssh/known_hosts
    fi

    ############################################################################

    # TODO identity keys
fi
