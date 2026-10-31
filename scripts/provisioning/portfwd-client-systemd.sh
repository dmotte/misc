#!/bin/bash

set -e

# This script can be used to set up a TCP port-forwarding SSH tunnel. It's
# basically the equivalent of
# https://github.com/dmotte/docker-images/tree/main/portfwd-client but as a
# system service

# Tested on Debian 13 (trixie)

options=$(getopt -o +un:s: -l user,name: \
    -l keepalive-interval:,restart-interval: \
    -l service: -- "$@")
eval "set -- $options"

user=n
name='' # Warning: some characters are forbidden. See the code below
keepalive_interval=30
restart_interval=30
service_lines=()

while :; do
    case $1 in
        -u|--user) user=y;;
        -n|--name) shift; name=$1;;
        --keepalive-interval) shift; keepalive_interval=$1;;
        --restart-interval) shift; restart_interval=$1;;
        -s|--service) shift; service_lines+=("$1");;
        --) shift; break;;
    esac
    shift
done

ssh_args=$* # Warning: some characters are forbidden. See the code below

if [ "$user" = y ]; then
    [ "$EUID" != 0 ] ||
        { echo 'Must run as a regular user if --user is set' >&2; exit 1; }
    scoped_systemctl() { systemctl --user "$@"; }
    readonly systemd_units_dir=~/.config/systemd/user
else
    [ "$EUID" = 0 ] ||
        { echo 'Must run as root if --user is not set' >&2; exit 1; }
    scoped_systemctl() { systemctl "$@"; }
    readonly systemd_units_dir=/etc/systemd/system
fi

[[ "$name" =~ ^[0-9A-Za-z-]+$ ]] || { echo "Invalid name: $name" >&2; exit 1; }

[ -n "$ssh_args" ] || { echo 'SSH args cannot be empty' >&2; exit 1; }
{ [[ "$ssh_args" != *\'* ]] && [[ "$ssh_args" != *$'\n'* ]]; } ||
    { echo 'The SSH args string contains invalid characters' >&2; exit 1; }

################################################################################

readonly fullname=portfwd-client-$name

readonly ssh_command="/usr/bin/ssh -oServerAliveInterval=$keepalive_interval -oExitOnForwardFailure=yes $ssh_args"

if [ "$user" = y ]
    then readonly systemd_wantedby=default.target
    else readonly systemd_wantedby=multi-user.target
fi

################################################################################

[ -e "$systemd_units_dir/$fullname.service" ] || changing=y

install -DTvm644 /dev/stdin "$systemd_units_dir/$fullname.service" <<EOF
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
WantedBy=$systemd_wantedby
EOF

echo "Reloading systemd config and enabling $fullname service"
scoped_systemctl daemon-reload; scoped_systemctl enable "$fullname"

################################################################################

if [ "$PORTFWD_CLIENT_RESTART" = always ] || {
    [ "$PORTFWD_CLIENT_RESTART" = when-changed ] && [ "$changing" = y ]
}; then
    echo "Restarting $fullname"
    scoped_systemctl restart "$fullname"
fi
