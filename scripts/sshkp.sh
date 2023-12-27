#!/bin/bash

set -e

# Script to execute an SSH command using a password from a KeePass database

# Usage example:
#   export KP_FILENAME=/path/to/my/keepass/database.kdbx
#   read -rsp 'Password: ' KP_PASSWORD && export KP_PASSWORD
#   ./sshkp.sh user@hostname cat /etc/os-release

# If running on Debian 12, you need to have these APT packages installed:
# keepassxc-cli sshpass

if [ -z "$KP_FILENAME" ]; then
    echo 'The KP_FILENAME env var is not defined' >&2
    exit 1
fi

if [ $# -lt 1 ]; then
    echo 'KeePass entry name not specified' >&2
    exit 1
fi

entryname="$1"; shift

if [ -n "$KP_PASSWORD" ]; then
    entrypass="$(echo "$KP_PASSWORD" | \
        keepassxc-cli show -qaPassword "$KP_FILENAME" "$entryname")"
else
    entrypass="$(keepassxc-cli show -aPassword "$KP_FILENAME" "$entryname")"
fi

unset KP_FILENAME KP_PASSWORD
SSHPASS="$entrypass" exec sshpass -e ssh "$entryname" "$@"
