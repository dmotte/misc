#!/bin/bash

set -e

# This script can be used to set up a TCP port-forwarding SSH tunnel. It's
# basically the equivalent of
# https://github.com/dmotte/docker-images/tree/main/portfwd-client but as a
# system service

# Tested on Debian 13 (trixie)

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o +n:s: -l name: \
    -l keepalive-interval:,restart-interval: \
    -l service: -- "$@")
eval "set -- $options"

name='' # Warning: some characters are forbidden. See the code below
keepalive_interval=30
restart_interval=30
service_lines=()

while :; do
    case $1 in
        -n|--name) shift; name=$1;;
        --keepalive-interval) shift; keepalive_interval=$1;;
        --restart-interval) shift; restart_interval=$1;;
        -s|--service) shift; service_lines+=("$1");;
        --) shift; break;;
    esac
    shift
done

ssh_args=$* # Warning: some characters are forbidden. See the code below

[[ "$name" =~ ^[0-9A-Za-z-]+$ ]] || { echo "Invalid name: $name" >&2; exit 1; }

[ -n "$ssh_args" ] || { echo 'SSH args cannot be empty' >&2; exit 1; }
{ [[ "$ssh_args" != *\'* ]] && [[ "$ssh_args" != *$'\n'* ]]; } ||
    { echo 'The SSH args string contains invalid characters' >&2; exit 1; }

################################################################################

readonly fullname=portfwd-client-$name

readonly ssh_command="/usr/bin/ssh -oServerAliveInterval=$keepalive_interval -oExitOnForwardFailure=yes $ssh_args"

################################################################################

[ -e "/etc/systemd/system/$fullname.service" ] || changing=y

install -Tvm644 /dev/stdin "/etc/systemd/system/$fullname.service" <<EOF
[Unit]
Description=$fullname
After=network.target network-online.target \\
    NetworkManager.service connman.service \\
    networking.service systemd-networkd.service

# Disable unit start rate limiting
StartLimitIntervalSec=0

[Service]
Type=simple
ExecStart=$ssh_command
$(printf '%s\n' "${service_lines[@]}")
Restart=always
RestartSec=$restart_interval

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd config and enabling $fullname service"
systemctl daemon-reload; systemctl enable "$fullname"

################################################################################

if [ "$PORTFWD_CLIENT_RELOAD" = always ] || {
    [ "$PORTFWD_CLIENT_RELOAD" = when-changed ] && [ "$changing" = y ]
}; then
    echo "Restarting $fullname service"
    systemctl restart "$fullname"
fi
