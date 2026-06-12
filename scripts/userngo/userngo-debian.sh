#!/bin/bash

set -e

# TODO test thoroughly with both Alpine and Debian

readonly psw=$USERNGO_PSW
unset USERNGO_PSW

[ "$EUID" != 0 ] || [ -z "$psw" ] ||
    { echo "Setting the root user's password"; echo "root:$psw" | chpasswd; }

{ [ "$EUID" = 0 ] && [ -n "$USERNGO_USER" ]; } ||
    { echo 'Running main app'; exec "$@"; }

IFS=: read -ra parts <<< "$USERNGO_ID"
readonly id_user=${parts[0]:-1000}
readonly id_group=${parts[1]:-$id_user}
IFS=: read -ra parts <<< "$USERNGO_NAME"
readonly name_user=${parts[0]:-user}
readonly name_group=${parts[1]:-$name_user}

# TODO env var USERNGO_SUDOER
# TODO env var USERNGO_NOPASSWD

{ getent passwd "$new_uid" || getent passwd "$new_user"; } >/dev/null || {
    useradd_args=() # TODO build the args list and use it

    { getent group "$new_gid" || getent group "$new_group"; } >/dev/null || {
        echo "Creating group $new_group ($new_gid)"
        groupadd -g"$new_gid" "$new_group"
    }

    # TODO
}

# TODO INSPIRATION: useradd -m -s /bin/bash -u "$new_uid" -g "$new_gid" "$new_user"
echo "Creating user $new_user"
useradd -UGsudo -ms/bin/bash "$new_user"

echo "Setting the user's password"
echo "$new_user:$psw" | chpasswd

if [ "$USERNGO_NOPASSWD" = true ]; then
    echo "Enabling sudo without password for user $new_user"
    install -Tm440 <(echo "$new_user ALL=(ALL) NOPASSWD: ALL") \
        "/etc/sudoers.d/$new_user-nopassword"
fi

echo "Running main app as $new_uid:$new_gid"
exec gosu "$new_uid:$new_gid" "$@"
