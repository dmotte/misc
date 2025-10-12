#!/bin/bash

set -e

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

cd "$(dirname "$0")"

options=$(getopt -o +r: -l running-user: -- "$@")
eval "set -- $options"

running_user=''

while :; do
    case $1 in
        -r|--running-user) shift; running_user=$1;;
        --) shift; break;;
    esac
    shift
done

perfmon_args=$* # Warning: some characters are forbidden. See the code below

[ -n "$running_user" ] || { echo 'Running user cannot be empty' >&2; exit 1; }

[[ "$perfmon_args" != *$'\n'* ]] ||
    { echo 'The perfmon args string contains invalid characters' >&2; exit 1; }

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

################################################################################

[ -e /opt/perfmon ] || changing=y

dpkg -s python3-psutil >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y python3-psutil; }

install -o"$running_user" -g"$running_user" -dvm700 /opt/perfmon

echo 'Creating perfmon service files'

install -o"$running_user" -g"$running_user" -Tm700 \
    perfmon.py /opt/perfmon/main.py

cat << EOF > /etc/systemd/system/perfmon.service
[Unit]
Description=perfmon

# Disable unit start rate limiting
StartLimitIntervalSec=0

[Service]
Type=simple

User=$running_user

WorkingDirectory=/opt/perfmon
ExecStart=/usr/bin/python3 -u /opt/perfmon/main.py $perfmon_args

Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

echo 'Reloading systemd config and enabling perfmon service'
systemctl daemon-reload; systemctl enable perfmon

################################################################################

if [ "$PERFMON_RESTART" = always ] || {
    [ "$PERFMON_RESTART" = when-changed ] && [ "$changing" = y ]
}; then
    echo 'Restarting perfmon'
    systemctl restart perfmon
fi
