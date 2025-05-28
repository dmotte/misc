#!/bin/bash

set -e

# This script can be used to set up a systemd-based "cron job" consisting of a
# timer and a oneshot service

# Tested on Debian 12 (bookworm)

options=$(getopt -o +un:e:w: -l user,name:,event-expr:,workdir: -- "$@")
eval "set -- $options"

user=n
name='' # Warning: some characters are forbidden. See the code below
event_expr=''
workdir=''

while :; do
    case $1 in
        -u|--user) user=y;;
        -n|--name) shift; name=$1;;
        -e|--event-expr) shift; event_expr=$1;;
        -w|--workdir) shift; workdir=$1;;
        --) shift; break;;
    esac
    shift
done

command=$* # Warning: some characters are forbidden. See the code below

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

[ -n "$event_expr" ] || { echo 'Event expression cannot be empty' >&2; exit 1; }

[ -n "$command" ] || { echo 'Command cannot be empty' >&2; exit 1; }
[[ "$command" != *$'\n'* ]] ||
    { echo 'Command contains invalid characters' >&2; exit 1; }

################################################################################

if [ -n "$workdir" ]; then line_workdir=WorkingDirectory=$workdir; fi

[ -e "$systemd_units_dir/$name.service" ] || changing=y

echo "Creating $name service and timer"

install -DTm644 /dev/stdin "$systemd_units_dir/$name.service" << EOF
[Unit]
Description=$name service
After=network.target network-online.target systemd-networkd.service NetworkManager.service connman.service

[Service]
Type=oneshot

$line_workdir
ExecStart=$command
EOF

install -DTm644 /dev/stdin "$systemd_units_dir/$name.timer" << EOF
[Unit]
Description=$name timer

[Timer]
OnCalendar=$event_expr
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "Reloading systemd config and enabling $name timer"
scoped_systemctl daemon-reload; scoped_systemctl enable "$name.timer"

################################################################################

if [ "$SYSTEMD_TIMER_RESTART" = always ] || {
    [ "$SYSTEMD_TIMER_RESTART" = when-changed ] && [ "$changing" = y ]
}; then
    echo "Restarting $name timer"
    scoped_systemctl restart "$name.timer"
fi
