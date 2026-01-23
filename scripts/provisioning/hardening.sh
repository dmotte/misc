#!/bin/bash

set -e

# This script contains several hardening recipes for Linux hosts

# Tested on Debian 13 (trixie)

# Usage example:
#   sudo HARDENING_RELOAD=true bash hardening.sh bundle-desktop

# Warning: this is only a partial hardening and it should only serve as
# inspiration to make your own real hardening based on your specific environment

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

################################################################################

changed_sysctl=n
changed_nm=n
changed_timesyncd=n
changed_sshd=n

################################################################################

recipes_all=()

recipes_all+=(bundle-server-vm)
rcp_bundle_server_vm () {
    rcp_pam_umask_nousergroups

    rcp_sysctl_hardening_ipv4
    rcp_sysctl_hardening_ipv6

    rcp_hosts_127011

    rcp_sshd_rootlogin_no
    rcp_sshd_hostbasedauth_no
    rcp_sshd_emptypsws_no
    rcp_sshd_pswauth_no

    rcp_adduser_dirmode_0700
}

recipes_all+=(bundle-server-physical)
rcp_bundle_server_physical () {
    rcp_bundle_server_vm

    rcp_sysdnet_mac_rand

    rcp_timesyncd_dhcp_ntp_disable
}

recipes_all+=(bundle-desktop)
rcp_bundle_desktop () {
    rcp_pam_umask_nousergroups

    rcp_sysctl_hardening_ipv4
    rcp_sysctl_hardening_ipv6

    rcp_hosts_127011

    rcp_nm_mac_rand
    rcp_nm_hostname_mode_none
    rcp_nm_dhcp_send_hostname_false

    rcp_timesyncd_dhcp_ntp_disable

    rcp_adduser_dirmode_0700
}

recipes_all+=(pam-umask-nousergroups)
rcp_pam_umask_nousergroups () {
    echo 'Setting nousergroups for pam_umask.so'
    # Prevent setting the umask group bits to the same as owner bits
    sed -Ei 's/^(session\s+optional\s+pam_umask\.so)$/\1 nousergroups/' \
        /etc/pam.d/common-session{,-noninteractive}
}

recipes_all+=(kernel-ipv6-disable)
rcp_kernel_ipv6_disable () {
    local varname=GRUB_CMDLINE_LINUX_DEFAULT
    # Disable IPv6 via kernel boot parameter
    echo "$varname=\"\$$varname ipv6.disable=1\"" |
        install -Tvm644 /dev/stdin /etc/default/grub.d/disable-ipv6.cfg
    update-grub
}

recipes_all+=(sysctl-hardening-ipv4)
rcp_sysctl_hardening_ipv4 () {
    install -Tvm644 /dev/stdin /etc/sysctl.d/99-hardening-ipv4.conf << 'EOF'
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
    changed_sysctl=y
}

recipes_all+=(sysctl-hardening-ipv6)
rcp_sysctl_hardening_ipv6 () {
    install -Tvm644 /dev/stdin /etc/sysctl.d/99-hardening-ipv6.conf << 'EOF'
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.default.accept_ra=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
EOF
    changed_sysctl=y
}

recipes_all+=(sysctl-ipv6-disable)
rcp_sysctl_ipv6_disable () {
    install -Tvm644 /dev/stdin /etc/sysctl.d/99-disable-ipv6.conf << 'EOF'
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOF
    changed_sysctl=y
}

recipes_all+=(sysdnet-mac-rand)
rcp_sysdnet_mac_rand () {
    echo -e '[Link]\nMACAddressPolicy=random' | install -DTvm644 /dev/stdin \
        /etc/systemd/network/99-default.link.d/50-mac-rand.conf
}

recipes_all+=(hosts-127011)
rcp_hosts_127011 () {
    echo "Setting 127.0.1.1 entry to $HOSTNAME in /etc/hosts"
    sed -Ei 's/^(127\.0\.1\.1\s+).*$/\1'"$HOSTNAME/" /etc/hosts
}

recipes_all+=(nm-mac-rand)
rcp_nm_mac_rand () {
    install -Tvm644 /dev/stdin \
        /etc/NetworkManager/conf.d/50-mac-rand.conf << 'EOF'
[device]
wifi.scan-rand-mac-address=true

[connection]
ethernet.cloned-mac-address=stable
wifi.cloned-mac-address=stable
EOF
    changed_nm=y
}

recipes_all+=(nm-ipv6-disable)
rcp_nm_ipv6_disable () {
    install -Tv /dev/stdin \
        /etc/NetworkManager/dispatcher.d/pre-up.d/10-disable-ipv6.sh << 'EOF'
#!/bin/bash

set -e

readonly iface=${1:?}

# Required to prevent "Operation not supported" log spam in
# "journalctl -u NetworkManager". See
# https://www.dedoimedo.com/computers/linux-nm-ipv6-disable.html for detail
[ "$iface" = lo ] || nmcli device modify "$iface" ipv6.method disabled || :

sysctl -w "net.ipv6.conf.$iface.disable_ipv6=1" || :
EOF
    changed_nm=y
}

recipes_all+=(nm-hostname-mode-none)
rcp_nm_hostname_mode_none () {
    install -Tvm644 /dev/stdin \
        /etc/NetworkManager/conf.d/50-hostname-mode-none.conf << 'EOF'
[main]
hostname-mode=none
EOF
    changed_nm=y
}

recipes_all+=(nm-dhcp-send-hostname-false)
rcp_nm_dhcp_send_hostname_false () {
    install -Tv /dev/stdin \
        /etc/NetworkManager/dispatcher.d/pre-up.d/50-dhcp-send-hostname-false.sh << 'EOF'
#!/bin/bash

set -e

readonly iface=${1:?}

[ "$iface" = lo ] || nmcli device modify "$iface" \
    ipv4.dhcp-send-hostname false \
    ipv6.dhcp-send-hostname false
EOF
    changed_nm=y
}

recipes_all+=(timesyncd-dhcp-ntp-disable)
rcp_timesyncd_dhcp_ntp_disable () {
    # Prevent setting NTP server from DHCP (by systemd-timesyncd)
    rm -fv /etc/dhcp/dhclient-exit-hooks.d/timesyncd \
        /run/systemd/timesyncd.conf.d/01-dhclient.conf
    changed_timesyncd=y
}

recipes_all+=(sshd-rootlogin-no)
rcp_sshd_rootlogin_no () {
    echo 'Setting PermitRootLogin to no in /etc/ssh/sshd_config'
    sed -Ei 's/^#?(PermitRootLogin\s+).*$/\1no/' \
        /etc/ssh/sshd_config
    changed_sshd=y
}

recipes_all+=(sshd-hostbasedauth-no)
rcp_sshd_hostbasedauth_no () {
    echo 'Setting HostbasedAuthentication to no in /etc/ssh/sshd_config'
    sed -Ei 's/^#?(HostbasedAuthentication\s+).*$/\1no/' \
        /etc/ssh/sshd_config
    changed_sshd=y
}

recipes_all+=(sshd-emptypsws-no)
rcp_sshd_emptypsws_no () {
    echo 'Setting PermitEmptyPasswords to no in /etc/ssh/sshd_config'
    sed -Ei 's/^#?(PermitEmptyPasswords\s+).*$/\1no/' \
        /etc/ssh/sshd_config
    changed_sshd=y
}

recipes_all+=(sshd-addressfamily-inet)
rcp_sshd_addressfamily_inet () {
    echo 'Setting AddressFamily to inet in /etc/ssh/sshd_config'
    sed -Ei 's/^#?(AddressFamily\s+).*$/\1inet/' \
        /etc/ssh/sshd_config
    changed_sshd=y
}

recipes_all+=(sshd-pswauth-no)
rcp_sshd_pswauth_no () {
    echo 'Setting PasswordAuthentication to no in /etc/ssh/sshd_config'
    sed -Ei 's/^#?(PasswordAuthentication\s+).*$/\1no/' \
        /etc/ssh/sshd_config
    changed_sshd=y
}

recipes_all+=(adduser-dirmode-0700)
rcp_adduser_dirmode_0700 () {
    echo 'Setting DIR_MODE to 0700 in /etc/adduser.conf'
    # The permissions mode for home directories of non-system users
    sed -Ei 's/^#?(DIR_MODE=).*$/\10700/' /etc/adduser.conf
}

################################################################################

recipes_run=()

# Read the recipes passed by args and make sure they are in the correct order
for i in "${recipes_all[@]}"; do
    [ -n "$1" ] || break
    [ "$1" = "$i" ] && { recipes_run+=("$i"); shift; }
done

[ -z "$1" ] || { echo "Unexpected recipe: $1" >&2; exit 1; }

for i in "${recipes_run[@]}"; do "rcp_${i//-/_}"; done

################################################################################

if [ "$HARDENING_RELOAD" = true ]; then
    [ "$changed_sysctl" = y ] && sysctl --system
    [ "$changed_nm" = y ] && systemctl restart NetworkManager
    [ "$changed_timesyncd" = y ] && systemctl restart systemd-timesyncd
    [ "$changed_sshd" = y ] && systemctl restart ssh
fi
