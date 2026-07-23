#!/bin/bash

set -e

readonly data_dir=${SSHSET_DATA_DIR:-/opt/sshset/data}

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

[ -d "$data_dir" ] || { echo "Dir $data_dir not found" >&2; exit 1; }

################################################################################

sortcat() {
    local files; files=$(LC_ALL=C sort)
    # We use "awk 1" instead of "cat" because it automatically appends a
    # trailing newline at the end of files that are missing it
    echo -n "$files" | xargs -rd\\n awk 1
}

################################################################################

if [ "$EUID" = 0 ]; then
    find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/sshd-config/*" \
        -exec install -Dvm644 -t/etc/ssh/sshd_config.d {} +

    ############################################################################

    find /etc/ssh -mindepth 1 -maxdepth 1 -type f \
        \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
        -printf 'Removing existing %p\n' -delete

    find "$data_dir" -mindepth 2 -maxdepth 2 -type f \
        \( -path "$data_dir/host-keys/ssh_host_*_key" \
            -exec install -vm600 -t/etc/ssh {} + \) \
        -o \( -path "$data_dir/host-keys/ssh_host_*_key.pub" \
            -exec install -vm644 -t/etc/ssh {} + \)

    if [ "$gen_hostkeys" = true ]; then
        ssh-keygen -A # Generate the missing host keys

        [ -d "$data_dir/host-keys" ] || install -dvm700 "$data_dir/host-keys"
        find /etc/ssh -mindepth 1 -maxdepth 1 -type f \
            \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
            -exec cp -nvt"$data_dir/host-keys" {} +
    fi

    ############################################################################

    files=$(find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/sshrc/*")
    if [ -n "$files" ]; then
        content=$(set -e; echo -n "$files" | sortcat)
        echo "$content" | install -Tvm644 /dev/stdin /etc/ssh/sshrc
    fi

    ############################################################################

    find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/ssh-config/*" \
        -exec install -Dvm644 -t/etc/ssh/ssh_config.d {} +

    ############################################################################

    files=$(find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/known-hosts/*")
    if [ -n "$files" ]; then
        content=$(set -e; echo -n "$files" | sortcat)
        echo "$content" | install -Tvm644 /dev/stdin /etc/ssh/ssh_known_hosts
    fi

    ############################################################################

    users=$(find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type d -path "$data_dir/users/*" -printf '%f\n')
    while IFS= read -r user || [ -n "$user" ]; do
        user_dir=$data_dir/users/$user

        user_group=$(id -gn "$user")
        user_home=$(getent passwd "$user" | cut -d: -f6)

        ########################################################################

        files=$(find "$user_dir" -mindepth 2 -maxdepth 2 \
            -type f -path "$user_dir/authorized-keys/*.pub")
        if [ -n "$files" ]; then
            content=$(set -e; echo -n "$files" | sortcat)
            echo "$content" | install -o"$user" -g"$user_group" -Tvm600 \
                /dev/stdin "$user_home/.ssh/authorized_keys"
        elif [ "$gen_authkey" = true ]; then
            [ -d "$user_dir/authorized-keys" ] || install \
                -o"$user" -g"$user_group" -dvm700 "$user_dir/authorized-keys"

            # We need the space between the "-C" flag and its value because it
            # can be an empty string
            ssh-keygen -ted25519 -C "$gen_authkey_comment" -N '' \
                -f"$user_dir/authorized-keys/id_ed25519"
            chown -v "$user:$user_group" \
                "$user_dir"/authorized-keys/id_ed25519{,.pub}

            install -o"$user" -g"$user_group" -Tvm600 \
                "$user_dir/authorized-keys/id_ed25519.pub" \
                "$user_home/.ssh/authorized_keys"
        fi

        ########################################################################

        files=$(find "$user_dir" -mindepth 2 -maxdepth 2 \
            -type f -path "$user_dir/sshrc/*")
        if [ -n "$files" ]; then
            content=$(set -e; echo -n "$files" | sortcat)
            echo "$content" | install -o"$user" -g"$user_group" -Tvm600 \
                /dev/stdin "$user_home/.ssh/rc"
        fi

        ########################################################################

        files=$(find "$user_dir" -mindepth 2 -maxdepth 2 \
            -type f -path "$user_dir/ssh-config/*")
        if [ -n "$files" ]; then
            content=$(set -e; echo -n "$files" | sortcat)
            echo "$content" | install -o"$user" -g"$user_group" -Tvm644 \
                /dev/stdin "$user_home/.ssh/config"
        fi

        ########################################################################

        files=$(find "$user_dir" -mindepth 2 -maxdepth 2 \
            -type f -path "$user_dir/known-hosts/*")
        if [ -n "$files" ]; then
            content=$(set -e; echo -n "$files" | sortcat)
            echo "$content" | install -o"$user" -g"$user_group" -Tvm600 \
                /dev/stdin "$user_home/.ssh/known_hosts"
        fi

        ########################################################################

        files=$(find "$user_dir" -mindepth 2 -maxdepth 2 \
            -type f -path "$user_dir/identity-keys/*" \! -name '*.pub')
        if [ -n "$files" ]; then
            echo -n "$files" | xargs -rd\\n install \
                -o"$user" -g"$user_group" -vm600 -t"$user_home/.ssh"

            find "$user_dir" -mindepth 2 -maxdepth 2 \
                -type f -path "$user_dir/identity-keys/*.pub" \
                -exec install -o"$user" -g"$user_group" -vm644 \
                -t"$user_home/.ssh" {} +
        elif [ "$gen_idkey" = true ]; then
            [ -d "$user_dir/identity-keys" ] || install \
                -o"$user" -g"$user_group" -dvm700 "$user_dir/identity-keys"

            # We need the space between the "-C" flag and its value because it
            # can be an empty string
            ssh-keygen -ted25519 -C "$gen_idkey_comment" -N '' \
                -f"$user_dir/identity-keys/id_ed25519"
            chown -v "$user:$user_group" \
                "$user_dir"/identity-keys/id_ed25519{,.pub}

            install -o"$user" -g"$user_group" -vm600 -t"$user_home/.ssh" \
                "$user_dir/identity-keys/id_ed25519"
            install -o"$user" -g"$user_group" -vm644 -t"$user_home/.ssh" \
                "$user_dir/identity-keys/id_ed25519.pub"
        fi
    done < <(printf '%s' "$users")
else
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

    find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/sshd-config/*" \
        -exec install -Dvm644 -t ~/.ssh/sshd_config.d {} +

    ############################################################################

    find ~/.ssh -mindepth 1 -maxdepth 1 -type f \
        \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
        -printf 'Removing existing %p\n' -delete

    if [ "$gen_hostkeys" = true ]; then
        tmpdir=~/.ssh/sshset-tmp-gen-host-keys
        rm -frv "$tmpdir"; mkdir -pv "$tmpdir/etc/ssh"

        find "$data_dir" -mindepth 2 -maxdepth 2 -type f \
            \( -path "$data_dir/host-keys/ssh_host_*_key" \
                -exec install -vm600 -t"$tmpdir/etc/ssh" {} + \) \
            -o \( -path "$data_dir/host-keys/ssh_host_*_key.pub" \
                -exec install -vm644 -t"$tmpdir/etc/ssh" {} + \)

        ssh-keygen -Af "$tmpdir" # Generate the missing host keys

        find "$tmpdir/etc/ssh" -mindepth 1 -maxdepth 1 -type f \
            \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
            -exec mv -vt ~/.ssh {} +

        rm -rv "$tmpdir"

        [ -d "$data_dir/host-keys" ] || install -dvm700 "$data_dir/host-keys"
        find ~/.ssh -mindepth 1 -maxdepth 1 -type f \
            \( -name 'ssh_host_*_key' -o -name 'ssh_host_*_key.pub' \) \
            -exec cp -nvt"$data_dir/host-keys" {} +
    else
        find "$data_dir" -mindepth 2 -maxdepth 2 -type f \
            \( -path "$data_dir/host-keys/ssh_host_*_key" \
                -exec install -vm600 -t ~/.ssh {} + \) \
            -o \( -path "$data_dir/host-keys/ssh_host_*_key.pub" \
                -exec install -vm644 -t ~/.ssh {} + \)
    fi

    ############################################################################

    files=$(find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/authorized-keys/*.pub")
    if [ -n "$files" ]; then
        content=$(set -e; echo -n "$files" | sortcat)
        echo "$content" | install -Tvm600 /dev/stdin ~/.ssh/authorized_keys
    elif [ "$gen_authkey" = true ]; then
        [ -d "$data_dir/authorized-keys" ] ||
            install -dvm700 "$data_dir/authorized-keys"

        # We need the space between the "-C" flag and its value because it
        # can be an empty string
        ssh-keygen -ted25519 -C "$gen_authkey_comment" -N '' \
            -f"$data_dir/authorized-keys/id_ed25519"

        install -Tvm600 "$data_dir/authorized-keys/id_ed25519.pub" \
            ~/.ssh/authorized_keys
    fi

    ############################################################################

    files=$(find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/sshrc/*")
    if [ -n "$files" ]; then
        content=$(set -e; echo -n "$files" | sortcat)
        echo "$content" | install -Tvm600 /dev/stdin ~/.ssh/rc
    fi

    ############################################################################

    files=$(find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/ssh-config/*")
    if [ -n "$files" ]; then
        content=$(set -e; echo -n "$files" | sortcat)
        echo "$content" | install -Tvm644 /dev/stdin ~/.ssh/config
    fi

    ############################################################################

    files=$(find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/known-hosts/*")
    if [ -n "$files" ]; then
        content=$(set -e; echo -n "$files" | sortcat)
        echo "$content" | install -Tvm600 /dev/stdin ~/.ssh/known_hosts
    fi

    ############################################################################

    files=$(find "$data_dir" -mindepth 2 -maxdepth 2 \
        -type f -path "$data_dir/identity-keys/*" \! -name '*.pub')
    if [ -n "$files" ]; then
        echo -n "$files" | xargs -rd\\n install -vm600 -t ~/.ssh

        find "$data_dir" -mindepth 2 -maxdepth 2 \
            -type f -path "$data_dir/identity-keys/*.pub" \
            -exec install -vm644 -t ~/.ssh {} +
    elif [ "$gen_idkey" = true ]; then
        [ -d "$data_dir/identity-keys" ] ||
            install -dvm700 "$data_dir/identity-keys"

        # We need the space between the "-C" flag and its value because it
        # can be an empty string
        ssh-keygen -ted25519 -C "$gen_idkey_comment" -N '' \
            -f"$data_dir/identity-keys/id_ed25519"

        install -vm600 -t ~/.ssh "$data_dir/identity-keys/id_ed25519"
        install -vm644 -t ~/.ssh "$data_dir/identity-keys/id_ed25519.pub"
    fi
fi
