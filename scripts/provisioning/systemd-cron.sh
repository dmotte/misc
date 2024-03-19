#!/bin/bash

set -e

# This script can be used to set up a systemd-based "cron job" consisting of a
# timer and a oneshot service

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o +n:e:w: -l name:,event-expr:,workdir: -- "$@")
eval "set -- $options"

name='' # Warning: some characters are forbidden. See the code below
event_expr=''
workdir=''

while :; do
    case "$1" in
        -n|--name) shift; name="$1";;
        -e|--event-expr) shift; event_expr="$1";;
        -w|--workdir) shift; workdir="$1";;
        --) shift; break;;
    esac
    shift
done

command=$* # Warning: some characters are forbidden. See the code below

[[ "$name" =~ ^[0-9A-Za-z-]+$ ]] || { echo "Invalid name: $name" >&2; exit 1; }

[ -n "$event_expr" ] || { echo 'Event expression cannot be empty' >&2; exit 1; }

[ -n "$command" ] || { echo 'Command cannot be empty' >&2; exit 1; }
[[ "$command" != *$'\n'* ]] || \
    { echo 'Command contains invalid characters' >&2; exit 1; }

################################################################################

if [ -n "$workdir" ]; then line_workdir="WorkingDirectory=$workdir"; fi

[ -e "/etc/systemd/system/$name.service" ] || changing=y

echo "Creating $name service and timer"

cat << EOF > "/etc/systemd/system/$name.service"
[Unit]
Description=$name service
After=network.target network-online.target systemd-networkd.service NetworkManager.service connman.service

[Service]
Type=oneshot

$line_workdir
ExecStart=$command
EOF

cat << EOF > "/etc/systemd/system/$name.timer"
[Unit]
Description=$name timer

[Timer]
OnCalendar=$event_expr
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "Reloading systemd config and enabling $name timer"
systemctl daemon-reload; systemctl enable "$name.timer"

################################################################################

if [ "$SYSTEMD_TIMER_RESTART" = always ] || {
    [ "$SYSTEMD_TIMER_RESTART" = when-changed ] && [ "$changing" = y ]
}; then
    echo "Restarting $name timer"
    systemctl restart "$name.timer"
fi
