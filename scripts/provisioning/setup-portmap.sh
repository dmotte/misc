#!/bin/bash

set -e

# This script can be used to set up a TCP port-forwarding SSH tunnel. It's
# basically the equivalent of https://github.com/dmotte/docker-portmap-client
# but as a system service

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o n:r:s: -l service-manager: -l name-suffix: \
    -l running-user: -l ssh-args: -l keepalive-interval: -l restart-interval: \
    -l supervisor-priority: -l systemd-wantedby: -- "$@")
eval "set -- $options"

service_manager=auto
name_suffix='' # Warning: some characters are forbidden. See the code below
running_user=''
ssh_args='' # Warning: some characters are forbidden. See the code below
keepalive_interval=30
restart_interval=30
supervisor_priority=50
systemd_wantedby=multi-user.target

while :; do
    case "$1" in
        --service-manager) shift; service_manager="$1";;
        -n|--name-suffix) shift; name_suffix="$1";;
        -r|--running-user) shift; running_user="$1";;
        -s|--ssh-args) shift; ssh_args="$1";;
        --keepalive-interval) shift; keepalive_interval="$1";;
        --restart-interval) shift; restart_interval="$1";;
        --supervisor-priority) shift; supervisor_priority="$1";;
        --systemd-wantedby) shift; systemd_wantedby="$1";;
        --) shift; break;;
    esac
    shift
done

[[ "$service_manager" =~ ^(auto|supervisor|systemd)$ ]] || \
    { echo "Unsupported service manager: $service_manager" >&2; exit 1; }

[[ "$name_suffix" =~ ^[0-9A-Za-z-]+$ ]] || \
    { echo "Invalid name suffix: $name_suffix" >&2; exit 1; }

[ -n "$running_user" ] || { echo 'Running user cannot be empty' >&2; exit 1; }

[ -n "$ssh_args" ] || { echo 'SSH args cannot be empty' >&2; exit 1; }
{ [[ "$ssh_args" != *\'* ]] && [[ "$ssh_args" != *$'\n'* ]]; } || \
    { echo 'The SSH args string contains invalid characters' >&2; exit 1; }

################################################################################

if [ "$service_manager" = auto ]; then
    if command -v supervisord >/dev/null; then service_manager=supervisor
    else service_manager=systemd; fi

    echo "Detected service manager: $service_manager"
fi

service_name="portmap-$name_suffix"
running_user_home=$(eval "echo ~$running_user")
ssh_command="/usr/bin/ssh -oServerAliveInterval=$keepalive_interval -oExitOnForwardFailure=yes $ssh_args"

################################################################################

if [ "$service_manager" = supervisor ]; then
    cat << EOF > "/etc/supervisor/conf.d/$service_name.conf"
[program:$service_name]
command=/bin/bash -ec '$ssh_command \\
    || result=\$?; sleep $restart_interval; exit "\${result:-0}"'
startsecs=0
priority=$supervisor_priority
user=$running_user
directory=$running_user_home
EOF
elif [ "$service_manager" = systemd ]; then
    cat << EOF > "/etc/systemd/system/$service_name.service"
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
    systemctl daemon-reload; systemctl enable "$service_name"
fi

################################################################################

if [ "$PORTMAP_RELOAD" = 'true' ]; then
    if [ "$service_manager" = supervisor ]; then
        supervisorctl update
    elif [ "$service_manager" = systemd ]; then
        systemctl restart "$service_name"
    fi
fi
