#!/bin/bash

set -e

# TODO test thoroughly

if [ "$EUID" != 0 ]; then readonly scenario=unpriv
elif [ -n "$USERNGO_ID$USERNGO_NAME" ]; then readonly scenario=managed
else readonly scenario=root
fi

readonly psw=$USERNGO_PSW
unset USERNGO_PSW

[ "$scenario" = root ] && [ -n "$psw" ] &&
    { echo "Setting the root user's password"; echo "root:$psw" | chpasswd; }

[ "$scenario" = managed ] || { echo 'Running main app'; exec "$@"; }

IFS=: read -ra parts <<< "$USERNGO_ID"
readonly id_user=${parts[0]:-auto}
readonly id_group=${parts[1]:-$id_user}
IFS=: read -ra parts <<< "$USERNGO_NAME"
readonly name_user=${parts[0]:-user}
readonly name_group=${parts[1]:-$name_user}
IFS=: read -ra parts <<< "$USERNGO_SYS"
readonly sys_user=${parts[0]:-false}
readonly sys_group=${parts[1]:-$sys_user}

readonly sudoer=$USERNGO_SUDOER
readonly nopasswd=$USERNGO_NOPASSWD

{ getent passwd "$id_user" || getent passwd "$name_user"; } >/dev/null || {
    useradd_args=() # TODO build the args list and use it

    { getent group "$id_group" || getent group "$name_group"; } >/dev/null || {
        echo "Creating group $name_group ($id_group)"
        groupadd -g"$id_group" "$name_group"
    }

    # TODO
}

# TODO INSPIRATION: useradd -m -s /bin/bash -u "$id_user" -g "$id_group" "$name_user"
echo "Creating user $name_user"
useradd -UGsudo -ms/bin/bash "$name_user"

echo "Setting the user's password"
echo "$name_user:$psw" | chpasswd

if [ "$nopasswd" = true ]; then
    echo "Enabling sudo without password for user $name_user"
    install -Tm440 <(echo "$name_user ALL=(ALL) NOPASSWD: ALL") \
        "/etc/sudoers.d/$name_user-nopassword"
fi

echo "Running main app as $id_user:$id_group"
exec gosu "$id_user:$id_group" "$@"
