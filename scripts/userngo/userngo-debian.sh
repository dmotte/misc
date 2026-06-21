#!/bin/bash

set -e

# TODO test thoroughly

if [ "$EUID" != 0 ]; then readonly scenario=unpriv
elif [ -n "$USERNGO_ID$USERNGO_NAME" ]; then readonly scenario=managed
else readonly scenario=root
fi

readonly psw=$USERNGO_PSW
unset USERNGO_PSW

if [ "$scenario" = root ] && [ -n "$psw" ]
    then echo 'Setting root password'; echo "root:$psw" | chpasswd; fi

if [ "$scenario" != managed ]; then echo 'Running main app'; exec "$@"; fi

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

if ! { getent passwd "$id_user" ||
        getent passwd "$name_user"; } >/dev/null; then
    add_args_user=()

    if [ "$id_user:$name_user" = "$id_group:$name_group" ]; then
        add_args_user+=(-U)
    else
        add_args_group=()

        [ "$id_group" = auto ] || add_args_group+=(-g"$id_group")
        [ "$sys_group" != true ] || add_args_group+=(-r)

        echo "Creating group $name_group (ID $id_group)"
        groupadd "${add_args_group[@]}" "$name_group"

        add_args_user+=(-g"$name_group")
    fi

    [ "$id_user" = auto ] || add_args_user+=(-u"$id_user")
    [ "$sys_user" != true ] || add_args_user+=(-r)
    [ "$sudoer" != true ] || add_args_user+=(-Gsudo)

    shell=$(getent passwd root | cut -d: -f7)

    echo "Creating user $name_user (ID $id_user)"
    useradd "${add_args_user[@]}" -ms"$shell" "$name_user"

    if [ -n "$psw" ]; then
        echo "Setting password for user $name_user"
        echo "$name_user:$psw" | chpasswd
    fi

    if [ "$nopasswd" = true ]; then
        echo "Enabling sudo without password for user $name_user"
        install -Tm440 <(echo "$name_user ALL=(ALL) NOPASSWD: ALL") \
            "/etc/sudoers.d/$name_user-nopasswd"
    fi
fi

echo "Running main app as $id_user:$id_group"
exec gosu "$id_user:$id_group" "$@"
