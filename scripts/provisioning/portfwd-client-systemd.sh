#!/bin/bash

set -e

# This script can be used to set up a TCP port-forwarding SSH tunnel. It's
# basically the equivalent of
# https://github.com/dmotte/docker-images/tree/main/portfwd-client but as a
# system service

# Tested on Debian 13 (trixie)

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o +n:r: -l name-suffix: \
    -l running-user:,keepalive-interval:,restart-interval: \
    -l systemd-wantedby: -- "$@")
eval "set -- $options"

name_suffix='' # Warning: some characters are forbidden. See the code below
running_user=''
keepalive_interval=30
restart_interval=30
systemd_wantedby=multi-user.target

while :; do
    case $1 in
        -n|--name-suffix) shift; name_suffix=$1;;
        -r|--running-user) shift; running_user=$1;;
        --keepalive-interval) shift; keepalive_interval=$1;;
        --restart-interval) shift; restart_interval=$1;;
        --systemd-wantedby) shift; systemd_wantedby=$1;;
        --) shift; break;;
    esac
    shift
done

ssh_args=$* # Warning: some characters are forbidden. See the code below

[[ "$name_suffix" =~ ^[0-9A-Za-z-]+$ ]] ||
    { echo "Invalid name suffix: $name_suffix" >&2; exit 1; }

[ -n "$running_user" ] || { echo 'Running user cannot be empty' >&2; exit 1; }

[ -n "$ssh_args" ] || { echo 'SSH args cannot be empty' >&2; exit 1; }
{ [[ "$ssh_args" != *\'* ]] && [[ "$ssh_args" != *$'\n'* ]]; } ||
    { echo 'The SSH args string contains invalid characters' >&2; exit 1; }

################################################################################

readonly service_name=portfwd-client-$name_suffix
running_user_home=$(getent passwd "$running_user" | cut -d: -f6)
readonly ssh_command="/usr/bin/ssh -oServerAliveInterval=$keepalive_interval -oExitOnForwardFailure=yes $ssh_args"

################################################################################

[ -e "/etc/systemd/system/$service_name.service" ] || changing=y

install -Tvm644 /dev/stdin \
    "/etc/systemd/system/$service_name.service" <<EOF
[Unit]
Description=$service_name

# Disable unit start rate limiting
StartLimitIntervalSec=0

[Service]
Type=simple

User=$running_user

WorkingDirectory=$running_user_home
ExecStart=$ssh_command

Restart=always
RestartSec=$restart_interval

[Install]
WantedBy=$systemd_wantedby
EOF

echo "Reloading systemd config and enabling $service_name service"
systemctl daemon-reload; systemctl enable "$service_name"

################################################################################

if [ "$PORTFWD_CLIENT_RELOAD" = always ] || {
    [ "$PORTFWD_CLIENT_RELOAD" = when-changed ] && [ "$changing" = y ]
}; then
    echo "Restarting $service_name service"
    systemctl restart "$service_name"
fi
