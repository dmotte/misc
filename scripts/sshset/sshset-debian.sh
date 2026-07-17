#!/bin/bash

set -e

readonly src_dir=${SSHSET_SRC_DIR:-/opt/sshset}

readonly gen_authkey=${SSHSET_GEN_AUTHKEY:-false}
readonly gen_idkey=${SSHSET_GEN_IDKEY:-false}

# TODO consider switch to toggle host keys generation (because it's not needed
# for the SSH client). Or maybe even have two separate scripts

################################################################################

if [ "$EUID" = 0 ]; then
    readonly ssh_sys_dir=/etc/ssh # TODO check usage

    ############################################################################

    # Get host keys from the volume
    rm -fv /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub
    install -vm600 -t/etc/ssh \
        "$src_dir/host-keys"/ssh_host_*_key 2>/dev/null || :
    install -vm644 -t/etc/ssh \
        "$src_dir/host-keys"/ssh_host_*_key.pub 2>/dev/null || :

    # Generate the missing host keys
    ssh-keygen -A

    # Copy the (previously missing) generated host keys to the volume
    cp -nvt"$src_dir/host-keys" /etc/ssh/ssh_host_*_key 2>/dev/null || :
    cp -nvt"$src_dir/host-keys" /etc/ssh/ssh_host_*_key.pub 2>/dev/null || :
else
    readonly ssh_sys_dir=~/.ssh # TODO check usage

    install -dvm700 ~/.ssh

    ############################################################################

    # TODO not sure, because it works only with specific Debian version
    echo f1805313ad346bdb80dff4a560a080edfca9a998f620b64da2a1aba6bcf6782e \
        /etc/ssh/sshd_config | sha256sum -c >/dev/null

    echo 'Generating ~/.ssh/sshd_config'
    sed -E /etc/ssh/sshd_config \
        -e 's|^(Include)[ \t]+/etc/ssh/(.+)$|\1 ~/.ssh/\2|' \
        -e 's/^#?(Port)[ \t].*$/\1 2222/' \
        -e 's|^#?(HostKey)[ \t]+/etc/ssh/(.+)$|\1 ~/.ssh/\2|' \
        -e 's|^#?(PidFile)[ \t].*$|\1 ~/.ssh/sshd.pid|' \
        > ~/.ssh/sshd_config

    ############################################################################

    # Create the temporary directory for host keys generation
    mkdir -pv ~/.ssh/etc/ssh

    # Get host keys from the volume
    install -vm600 -t ~/.ssh/etc/ssh \
        "$src_dir/host-keys"/ssh_host_*_key 2>/dev/null || :
    install -vm644 -t ~/.ssh/etc/ssh \
        "$src_dir/host-keys"/ssh_host_*_key.pub 2>/dev/null || :

    # Generate the missing host keys
    ssh-keygen -Af ~/.ssh

    # Move the host keys out of the temporary directory
    mv -vt ~/.ssh ~/.ssh/etc/ssh/*
    rm -rv ~/.ssh/etc

    # Copy the (previously missing) generated host keys to the volume
    cp -nvt"$src_dir/host-keys" ~/.ssh/ssh_host_*_key 2>/dev/null || :
    cp -nvt"$src_dir/host-keys" ~/.ssh/ssh_host_*_key.pub 2>/dev/null || :
fi

# TODO copy sshd_config.d files
