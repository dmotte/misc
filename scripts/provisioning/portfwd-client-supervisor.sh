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
    -l supervisor-priority: -- "$@")
eval "set -- $options"

name_suffix='' # Warning: some characters are forbidden. See the code below
running_user=''
keepalive_interval=30
restart_interval=30
supervisor_priority=''

while :; do
    case $1 in
        -n|--name-suffix) shift; name_suffix=$1;;
        -r|--running-user) shift; running_user=$1;;
        --keepalive-interval) shift; keepalive_interval=$1;;
        --restart-interval) shift; restart_interval=$1;;
        --supervisor-priority) shift; supervisor_priority=$1;;
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

if [ -n "$supervisor_priority" ]
    then line_priority=priority=$supervisor_priority; fi

################################################################################

[ -e "/etc/supervisor/conf.d/50-$service_name.conf" ] || changing=y

install -Tvm644 /dev/stdin \
    "/etc/supervisor/conf.d/50-$service_name.conf" <<EOF
[program:$service_name]
command=/bin/bash -ec '$ssh_command \\
    || result=\$?; sleep $restart_interval; exit "\${result:-0}"'
startsecs=0
$line_priority
user=$running_user
directory=$running_user_home
EOF

################################################################################

if [ "$PORTFWD_CLIENT_RELOAD" = always ] || {
    [ "$PORTFWD_CLIENT_RELOAD" = when-changed ] && [ "$changing" = y ]
}; then
    if [ "$PORTFWD_CLIENT_RELOAD_MODE" = pid1-sighup ]; then
        echo 'Sending SIGHUP to PID 1'
        kill -sHUP 1
    elif [ "$PORTFWD_CLIENT_RELOAD_MODE" = pid1-sigterm ]; then
        echo 'Sending SIGTERM to PID 1'
        # The container will restart if its restart policy is set that way
        kill 1
    else
        echo 'Running supervisorctl update'
        supervisorctl update
    fi
fi
