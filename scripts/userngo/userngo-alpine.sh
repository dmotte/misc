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
    then echo 'userngo: setting root password'; echo "root:$psw" | chpasswd; fi

if [ "$scenario" != managed ]
    then echo 'userngo: running main app'; exec "$@"; fi

IFS=: read -ra parts <<< "$USERNGO_ID"
readonly id_user=${parts[0]:-auto}
readonly id_group=${parts[1]:-$id_user}
IFS=: read -ra parts <<< "$USERNGO_NAME"
readonly name_user=${parts[0]:-user}
readonly name_group=${parts[1]:-$name_user}
IFS=: read -ra parts <<< "$USERNGO_SYS"
readonly sys_user=${parts[0]:-false}
readonly sys_group=${parts[1]:-$sys_user}

readonly shell=${USERNGO_SHELL:-/bin/sh}
readonly wheel=$USERNGO_WHEEL
readonly nopass=$USERNGO_NOPASS

if ! getent passwd "$name_user" >/dev/null; then
    add_args_user=()

    if [ "$id_user:$name_user" != "$id_group:$name_group" ] ||
            [ "$sys_user" = true ]; then
        add_args_group=()

        [ "$id_group" = auto ] || add_args_group+=(-g"$id_group")
        [ "$sys_group" != true ] || add_args_group+=(-S)

        echo "userngo: creating group $name_group (ID $id_group)"
        addgroup "${add_args_group[@]}" "$name_group"

        add_args_user+=(-G"$name_group")
    fi

    [ "$id_user" = auto ] || add_args_user+=(-u"$id_user")
    [ "$sys_user" != true ] || add_args_user+=(-S)

    echo "userngo: creating user $name_user (ID $id_user)"
    adduser "${add_args_user[@]}" -Ds"$shell" "$name_user"

    if [ -n "$psw" ]; then
        echo "userngo: setting password for user $name_user"
        echo "$name_user:$psw" | chpasswd
    fi

    if [ "$wheel" = true ]; then
        echo "userngo: adding user $name_user to the wheel group"
        addgroup "$name_user" wheel
    fi

    if [ "$nopass" = true ]; then
        echo "userngo: enabling doas without password for user $name_user"
        echo "permit nopass $name_user" \
            > "/etc/doas.d/50-$name_user-nopass.conf"
    fi
fi

echo "userngo: running main app as $name_user:$name_group"
exec su-exec "$name_user:$name_group" "$@"
