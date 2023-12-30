#!/bin/bash

set -e

if [ "$EUID" != '0' ]; then
    echo 'This script must be run as root' >&2
    exit 1
fi

options=$(getopt -o n -l no-reload -- "$@")
eval set -- "$options"

reload=y

while :; do
    case "$1" in
        -n|--no-reload) reload=n;;
        --) shift; break;;
    esac
    shift
done

cat << 'EOF' > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOF

if [ "$reload" = y ]; then sysctl --system; fi
