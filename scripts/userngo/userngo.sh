#!/bin/bash

set -e

# TODO test thoroughly with both Alpine and Debian

readonly psw=$USERNGO_PSW
unset USERNGO_PSW

[ "$EUID" != 0 ] || [ -z "$psw" ] ||
    { echo "Setting the root user's password"; echo "root:$psw" | chpasswd; }

{ [ "$EUID" = 0 ] && [ -n "$USERNGO_USER" ]; } ||
    { echo 'Running TODOapp'; exec "$@"; }

IFS=: read -ar parts <<< "$USERNGO_USER"
readonly new_uid=${parts[0]:-1000}
readonly new_user=${parts[1]:-user}
readonly new_gid=${parts[2]:-$new_uid}
readonly new_group=${parts[3]:-$new_user}

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

echo "Running TODOapp as $new_uid:$new_gid"
exec gosu "$new_uid:$new_gid" "$@"
