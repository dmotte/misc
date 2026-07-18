#!/bin/bash

set -e

readonly src_dir=${SSHSET_SRC_DIR:-/opt/sshset}

readonly gen_authkey=${SSHSET_GEN_AUTHKEY:-false}
readonly gen_idkey=${SSHSET_GEN_IDKEY:-false}

# TODO consider switch to toggle host keys generation (because it's not needed
# for the SSH client). Or maybe even have two separate scripts

# TODO avoid using "|| :" as it hides permissions issues (e.g. unable to read a
# private key file)

################################################################################

if [ "$EUID" = 0 ]; then
    readonly ssh_sys_dir=/etc/ssh # TODO check usage

    ############################################################################

    find "$src_dir/sshd-config" -mindepth 1 -maxdepth 1 \
        -type f -name '*.conf' \
        -exec install -vm644 -t/etc/ssh/sshd_config.d {} +

    ############################################################################

    find /etc/ssh -mindepth 1 -maxdepth 1 -type f \
        \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
        -printf 'Removing existing %p\n' -delete

    find "$src_dir/host-keys" -mindepth 1 -maxdepth 1 \
        -type f -name 'ssh_host_*_key' \
        -exec install -vm600 -t/etc/ssh {} +
    find "$src_dir/host-keys" -mindepth 1 -maxdepth 1 \
        -type f -name 'ssh_host_*_key.pub' \
        -exec install -vm644 -t/etc/ssh {} +

    ssh-keygen -A # Generate the missing host keys

    find /etc/ssh -mindepth 1 -maxdepth 1 -type f \
        \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
        -exec cp -nvt"$src_dir/host-keys" {} + || :
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

    find "$src_dir/sshd-config" -mindepth 1 -maxdepth 1 \
        -type f -name '*.conf' \
        -exec install -Dvm644 -t ~/.ssh/sshd_config.d {} +

    ############################################################################

    # Create the temporary directory for host keys generation
    mkdir -pv ~/.ssh/etc/ssh # TODO use mktemp

    # Get host keys from the volume
    install -vm600 -t ~/.ssh/etc/ssh \
        "$src_dir/host-keys"/ssh_host_*_key 2>/dev/null || :
    install -vm644 -t ~/.ssh/etc/ssh \
        "$src_dir/host-keys"/ssh_host_*_key.pub 2>/dev/null || :

    ssh-keygen -Af ~/.ssh # Generate the missing host keys

    # Move the host keys out of the temporary directory
    mv -vt ~/.ssh ~/.ssh/etc/ssh/*
    rm -rv ~/.ssh/etc

    # Copy the (previously missing) generated host keys to the volume
    cp -nvt"$src_dir/host-keys" ~/.ssh/ssh_host_*_key 2>/dev/null || :
    cp -nvt"$src_dir/host-keys" ~/.ssh/ssh_host_*_key.pub 2>/dev/null || :
fi

# TODO rc + users

# TODO users authkeys
