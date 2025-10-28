#!/bin/bash

set -e

# Tested on Debian 13 (trixie)

# Warning: this is only a partial hardening and it should only serve as
# inspiration to make your own real hardening based on your specific environment

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o +apd -l sshd-addressfamily-inet -l sshd-disable-psw-auth \
    -l disable-ipv6 -- "$@")
eval "set -- $options"

sshd_addressfamily_inet=n
sshd_disable_psw_auth=n
disable_ipv6=n

while :; do
    case $1 in
        -a|--sshd-addressfamily-inet) sshd_addressfamily_inet=y;;
        -p|--sshd-disable-psw-auth) sshd_disable_psw_auth=y;;
        -d|--disable-ipv6) disable_ipv6=y;;
        --) shift; break;;
    esac
    shift
done

################################################################################

[ -e /etc/sysctl.d/99-hardening-ipv4.conf ] || changing=y

# Prevent setting the umask group bits to the same as owner bits
sed -Ei 's/^(session\s+optional\s+pam_umask\.so)$/\1 nousergroups/' \
    /etc/pam.d/common-session{,-noninteractive}

# The permissions mode for home directories of non-system users
sed -Ei 's/^#?(DIR_MODE=).*$/\10700/' /etc/adduser.conf

sed -Ei 's/^(127\.0\.1\.1\s+).*$/\1'"$HOSTNAME/" /etc/hosts

if [ -e /etc/ssh/sshd_config ]; then
    sed -Ei /etc/ssh/sshd_config \
        -e 's/^#?PermitRootLogin[ \t].*$/PermitRootLogin no/' \
        -e 's/^#?HostbasedAuthentication[ \t].*$/HostbasedAuthentication no/' \
        -e 's/^#?PermitEmptyPasswords[ \t].*$/PermitEmptyPasswords no/'
fi

if [ "$sshd_addressfamily_inet" = y ]; then
    sed -Ei 's/^#?AddressFamily[ \t].*$/AddressFamily inet/' \
        /etc/ssh/sshd_config
fi

if [ "$sshd_disable_psw_auth" = y ]; then
    sed -Ei  's/^#?PasswordAuthentication[ \t].*$/PasswordAuthentication no/' \
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

if [ "$HARDENING_RELOAD" = always ] || {
    [ "$HARDENING_RELOAD" = when-changed ] && [ "$changing" = y ]
}; then
    systemctl restart ssh systemd-timesyncd
    sysctl --system
fi
