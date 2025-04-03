#!/bin/bash

set -e

# This script can be used to define persistent iptables rules

# Tested on Debian 12 (bookworm)

# Usage example:
#   sed '/^\s*$/d;/^#/d' rules.v4 |
#     sudo IPTABLES_RULES_RELOAD=always bash iptables-rules.sh -4/dev/stdin

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o +4:6: -l rules-v4:,rules-v6: -- "$@")
eval "set -- $options"

rules_v4=''
rules_v6=''

while :; do
    case $1 in
        -4|--rules-v4) shift; rules_v4=$1;;
        -6|--rules-v6) shift; rules_v6=$1;;
        --) shift; break;;
    esac
    shift
done

if [ -n "$rules_v4" ]; then
    [ -e "$rules_v4" ] || { echo "File $rules_v4 not found" >&2; exit 1; }
fi
if [ -n "$rules_v6" ]; then
    [ -e "$rules_v6" ] || { echo "File $rules_v6 not found" >&2; exit 1; }
fi

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

################################################################################

[ -e /etc/iptables ] || changing=y

for i in 4 6; do # Do not save current rules to /etc/iptables/rules.v*
    echo "iptables-persistent iptables-persistent/autosave_v$i boolean false"
done | debconf-set-selections -v

dpkg -s iptables-persistent >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y iptables-persistent; }

chmod 600 /etc/iptables

[ -z "$rules_v4" ] || tr -d '\r' <"$rules_v4" |
    install -m600 /dev/stdin /etc/iptables/rules.v4
[ -z "$rules_v6" ] || tr -d '\r' <"$rules_v6" |
    install -m600 /dev/stdin /etc/iptables/rules.v6

################################################################################

if [ "$IPTABLES_RULES_RELOAD" = always ] || {
    [ "$IPTABLES_RULES_RELOAD" = when-changed ] && [ "$changing" = y ]
}; then
    for i in iptables ip6tables; do
        "$i" -P INPUT ACCEPT; "$i" -P FORWARD ACCEPT; "$i" -P OUTPUT ACCEPT
        "$i" -t nat -F; "$i" -t mangle -F; "$i" -F
        "$i" -X
    done

    systemctl restart netfilter-persistent
fi
