#!/bin/bash

set -e

# This script can be used to define persistent iptables rules

# Tested on Debian 12 (bookworm)

# Usage example:
#   sed '/^\s*$/d;/^#.*$/d' rules.v4 | \
#     sudo IPTABLES_RULES_RELOAD=true bash iptables-rules.sh -4/dev/stdin

if [ "$EUID" != '0' ]; then
    echo 'This script must be run as root' >&2
    exit 1
fi

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

options=$(getopt -o '4:6:' -l rules-v4: -l rules-v6: -- "$@")
eval set -- "$options"

rules_v4=''
rules_v6=''

while :; do
    case "$1" in
        -4|--rules-v4) shift; rules_v4="$1";;
        -6|--rules-v6) shift; rules_v6="$1";;
        --) shift; break;;
    esac
    shift
done

################################################################################

for i in 4 6; do # Do not save current rules to /etc/iptables/rules.v*
    echo "iptables-persistent iptables-persistent/autosave_v$i boolean false"
done | debconf-set-selections -v

apt_update_if_old; apt-get install -y iptables-persistent

if [ -n "$rules_v4" ]; then tr -d '\r' <"$rules_v4" >/etc/iptables/rules.v4; fi
if [ -n "$rules_v6" ]; then tr -d '\r' <"$rules_v6" >/etc/iptables/rules.v6; fi

################################################################################

if [ "$IPTABLES_RULES_RELOAD" = 'true' ]; then
    for i in iptables ip6tables; do
        "$i" -P INPUT ACCEPT; "$i" -P FORWARD ACCEPT; "$i" -P OUTPUT ACCEPT
        "$i" -t nat -F; "$i" -t mangle -F; "$i" -F
        "$i" -X
    done

    systemctl restart netfilter-persistent
fi
