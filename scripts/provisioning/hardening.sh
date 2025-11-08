#!/bin/bash

set -e

# Tested on Debian 13 (trixie)

# Warning: this is only a partial hardening and it should only serve as
# inspiration to make your own real hardening based on your specific environment

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o +adknp -l sshd-addressfamily-inet -l sshd-disable-psw-auth \
    -l disable-ipv6-sysctl -l disable-ipv6-kernel-param \
    -l disable-ipv6-nm-dispatcher -- "$@")
eval "set -- $options"

sshd_addressfamily_inet=n
sshd_disable_psw_auth=n
disable_ipv6_sysctl=n
disable_ipv6_kernel_param=n
disable_ipv6_nm_dispatcher=n

while :; do
    case $1 in
        -a|--sshd-addressfamily-inet) sshd_addressfamily_inet=y;;
        -p|--sshd-disable-psw-auth) sshd_disable_psw_auth=y;;
        -d|--disable-ipv6-sysctl) disable_ipv6_sysctl=y;;
        -k|--disable-ipv6-kernel-param) disable_ipv6_kernel_param=y;;
        -n|--disable-ipv6-nm-dispatcher) disable_ipv6_nm_dispatcher=y;;
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

installed_sshd=$([ -e /etc/ssh/sshd_config ] && echo true || echo false)

if [ "$installed_sshd" = true ]; then
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

installed_timesyncd=$([ -e /etc/systemd/timesyncd.conf ] && echo true || echo false)

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

if [ "$disable_ipv6_sysctl" = y ]; then
    cat << 'EOF' > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOF
fi

if [ "$disable_ipv6_kernel_param" = y ]; then
    # shellcheck disable=SC2016
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT ipv6.disable=1"' > /etc/default/grub.d/disable-ipv6.cfg
    update-grub
fi

installed_nm=$([ -e /etc/NetworkManager ] && echo true || echo false)

if [ "$disable_ipv6_nm_dispatcher" = y ]; then
    install -Tv /dev/stdin /etc/NetworkManager/dispatcher.d/pre-up.d/10-disable-ipv6.sh << 'EOF'
#!/bin/bash

set -e

readonly iface=${1:?}

# Required to prevent "Operation not supported" log spam in
# "journalctl -u NetworkManager". See
# https://www.dedoimedo.com/computers/linux-nm-ipv6-disable.html for detail
[ "$iface" = lo ] || nmcli device modify "$iface" ipv6.method disabled || :

sysctl -w "net.ipv6.conf.$iface.disable_ipv6=1" || :
EOF
fi

################################################################################

if [ "$HARDENING_RELOAD" = always ] || {
    [ "$HARDENING_RELOAD" = when-changed ] && [ "$changing" = y ]
}; then
    sysctl --system
    [ "$disable_ipv6_nm_dispatcher" = y ] && [ "$installed_nm" = true ] &&
        systemctl restart NetworkManager
    [ "$installed_timesyncd" = true ] && systemctl restart systemd-timesyncd
    [ "$installed_sshd" = true ] && systemctl restart ssh
fi
