#!/bin/bash

set -e

readonly src_dir=${SSHSET_SRC_DIR:-/opt/sshset}

readonly gen_hostkeys=${SSHSET_GEN_HOSTKEYS:-true}
readonly gen_authkey=${SSHSET_GEN_AUTHKEY:-false}
readonly gen_idkey=${SSHSET_GEN_IDKEY:-false}

# TODO consider switch to toggle host keys generation (because it's not needed
# for the SSH client). Or maybe even have two separate scripts

# TODO consider "mode" variable that can be "system" (ssh_sys_dir=/etc/ssh),
# "user" (ssh_sys_dir=~/.ssh), "auto" (default, based on EUID)

################################################################################

if [ "$EUID" = 0 ]; then
    readonly ssh_sys_dir=/etc/ssh # TODO check usage

    ############################################################################

    find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/sshd-config/*.conf" \
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

        find /etc/ssh -mindepth 1 -maxdepth 1 -type f \
            \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
            -exec cp -nvt"$src_dir/host-keys" {} + || : # No quit on errors
    fi

    ############################################################################

    files=$(find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/sshrc/*.sh")
    if [ -n "$files" ]; then
        files=$(echo -n "$files" | LC_ALL=C sort)
        # We use "awk 1" instead of "cat" because it automatically appends a
        # trailing newline at the end of files that are missing it
        content=$(echo -n "$files" | xargs -rd\\n awk 1)
        echo "$content" | install -Tvm644 /dev/stdin /etc/ssh/sshrc
    fi

    ############################################################################

    find "$src_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$src_dir/ssh-config/*.conf" \
        -exec install -Dvm644 -t/etc/ssh/ssh_config.d {} +
else
    readonly ssh_sys_dir=~/.ssh # TODO check usage

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
        -type f -path "$src_dir/sshd-config/*.conf" \
        -exec install -Dvm644 -t ~/.ssh/sshd_config.d {} +

    ############################################################################

    find ~/.ssh -mindepth 1 -maxdepth 1 -type f \
        \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
        -printf 'Removing existing %p\n' -delete

    if [ "$gen_hostkeys" = true ]; then
        rm -frv ~/.ssh/etc
        mkdir -pv ~/.ssh/etc/ssh # Temp dir for host keys generation

        find "$src_dir" -mindepth 2 -maxdepth 2 -type f \
            \( -path "$src_dir/host-keys/ssh_host_*_key" \
                -exec install -vm600 -t ~/.ssh/etc/ssh {} + \) \
            -o \( -path "$src_dir/host-keys/ssh_host_*_key.pub" \
                -exec install -vm644 -t ~/.ssh/etc/ssh {} + \)

        ssh-keygen -Af ~/.ssh # Generate the missing host keys

        find ~/.ssh/etc/ssh -mindepth 1 -maxdepth 1 -type f \
            \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
            -exec mv -vt ~/.ssh {} +

        rm -rv ~/.ssh/etc

        find ~/.ssh -mindepth 1 -maxdepth 1 -type f \
            \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
            -exec cp -nvt"$src_dir/host-keys" {} + || : # No quit on errors
    else
        find "$src_dir" -mindepth 2 -maxdepth 2 -type f \
            \( -path "$src_dir/host-keys/ssh_host_*_key" \
                -exec install -vm600 -t ~/.ssh {} + \) \
            -o \( -path "$src_dir/host-keys/ssh_host_*_key.pub" \
                -exec install -vm644 -t ~/.ssh {} + \)
    fi
fi
