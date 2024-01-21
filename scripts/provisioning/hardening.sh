#!/bin/bash

set -e

# Tested on Debian 12 (bookworm)

# Warning: this is only a partial hardening and it should only serve as
# inspiration to make your own real hardening based on your specific environment

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o apd -l sshd-addressfamily-inet -l sshd-disable-psw-auth \
    -l disable-ipv6 -- "$@")
eval set -- "$options"

sshd_addressfamily_inet=n
sshd_disable_psw_auth=n
disable_ipv6=n

while :; do
    case "$1" in
        -a|--sshd-addressfamily-inet) sshd_addressfamily_inet=y;;
        -p|--sshd-disable-psw-auth) sshd_disable_psw_auth=y;;
        -d|--disable-ipv6) disable_ipv6=y;;
        --) shift; break;;
    esac
    shift
done

################################################################################

sed -Ei 's/^#?UMASK.*$/UMASK 077/' /etc/login.defs
sed -Ei 's/^#?DIR_MODE=.*$/DIR_MODE=0700/' /etc/adduser.conf

sed -Ei 's/^127\.0\.1\.1( |\t).*$/127.0.1.1\t'"$HOSTNAME/" /etc/hosts

sed -Ei /etc/ssh/sshd_config \
    -e 's/^#?PermitRootLogin.*$/PermitRootLogin no/' \
    -e 's/^#?HostbasedAuthentication.*$/HostbasedAuthentication no/' \
    -e 's/^#?PermitEmptyPasswords.*$/PermitEmptyPasswords no/'

if [ "$sshd_addressfamily_inet" = y ]; then
    sed -Ei 's/^#?AddressFamily.*$/AddressFamily inet/' /etc/ssh/sshd_config
fi

if [ "$sshd_disable_psw_auth" = y ]; then
    sed -Ei  's/^#?PasswordAuthentication.*$/PasswordAuthentication no/' \
        /etc/ssh/sshd_config
fi

# Prevent setting NTP server from DHCP (by systemd-timesyncd)
rm -f /etc/dhcp/dhclient-exit-hooks.d/timesyncd \
    /run/systemd/timesyncd.conf.d/01-dhclient.conf

cat << 'EOF' > /etc/sysctl.d/99-hardening-ipv4.conf
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.default.log_martians=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
EOF

cat << 'EOF' > /etc/sysctl.d/99-hardening-ipv6.conf
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.default.accept_ra=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
EOF

if [ "$disable_ipv6" = y ]; then
    cat << 'EOF' > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOF
fi

################################################################################

if [ "$SSHD_RESTART" = 'true' ]; then systemctl restart ssh; fi
if [ "$TIMESYNCD_RESTART" = 'true' ]; then
    systemctl restart systemd-timesyncd
fi
if [ "$SYSCTL_RELOAD" = 'true' ]; then sysctl --system; fi
