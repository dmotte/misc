#!/bin/bash

set -e

# This script can be used to set up a TCP port-forwarding SSH tunnel. It's
# basically the equivalent of
# https://github.com/dmotte/docker-images/tree/main/portfwd-client but as a
# system service

# Tested on Debian 13 (trixie)

options=$(getopt -o +n:c:p: -l name:,cfgfile: \
    -l keepalive-interval:,restart-interval: \
    -l program: -- "$@")
eval "set -- $options"

name='' # Warning: some characters are forbidden. See the code below
cfgfile=''
keepalive_interval=30
restart_interval=30
program_lines=()

while :; do
    case $1 in
        -n|--name) shift; name=$1;;
        -c|--cfgfile) shift; cfgfile=$1;;
        --keepalive-interval) shift; keepalive_interval=$1;;
        --restart-interval) shift; restart_interval=$1;;
        -p|--program) shift; program_lines+=("$1");;
        --) shift; break;;
    esac
    shift
done

ssh_args=$* # Warning: some characters are forbidden. See the code below

[[ "$name" =~ ^[0-9A-Za-z-]+$ ]] || { echo "Invalid name: $name" >&2; exit 1; }

[ -n "$cfgfile" ] || { echo 'Config file path cannot be empty' >&2; exit 1; }

[ -n "$ssh_args" ] || { echo 'SSH args cannot be empty' >&2; exit 1; }
{ [[ "$ssh_args" != *\'* ]] && [[ "$ssh_args" != *$'\n'* ]]; } ||
    { echo 'The SSH args string contains invalid characters' >&2; exit 1; }

################################################################################

readonly fullname=portfwd-client-$name

readonly ssh_command="/usr/bin/ssh -oServerAliveInterval=$keepalive_interval -oExitOnForwardFailure=yes $ssh_args"

################################################################################

[ -e "$cfgfile" ] || changing=y

install -Tvm644 /dev/stdin "$cfgfile" <<EOF
[program:$fullname]
command=/bin/bash -ec '$ssh_command \\
    || result=\$?; sleep $restart_interval; exit "\${result:-0}"'
startsecs=0
$(printf '%s\n' "${program_lines[@]}")
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
        # If running in a container, it will restart if its restart policy is
        # set that way
        kill 1
    else
        echo 'Running supervisorctl update'
        supervisorctl update
    fi
fi
