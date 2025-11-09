#!/bin/bash

set -e

# This script contains several hardening recipes for Linux hosts

# Tested on Debian 13 (trixie)

# Usage example:
#   sudo HARDENING_RELOAD=true bash hardening.sh TODOrecipes

# Warning: this is only a partial hardening and it should only serve as
# inspiration to make your own real hardening based on your specific environment

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

# TODO in the end: test everything thoroughly
# TODO in the end: make sure to put all the stuff from the old hardening.sh

# TODO verbose recipes

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

    rcp_adduser_dirmode_700
}

recipes_all+=(bundle-server-physical)
rcp_bundle_server_physical () {
    rcp_bundle_server_vm

    rcp_timesyncd_dhcp_ntp_disable
}

recipes_all+=(bundle-desktop)
rcp_bundle_desktop () {
    rcp_pam_umask_nousergroups

    rcp_sysctl_hardening_ipv4
    rcp_sysctl_hardening_ipv6

    rcp_hosts_127011

    rcp_timesyncd_dhcp_ntp_disable

    rcp_adduser_dirmode_700
}

recipes_all+=(pam-umask-nousergroups)
rcp_pam_umask_nousergroups () {
    echo 'TODO description'
    echo TODO pam-umask-nousergroups
}

recipes_all+=(kernel-ipv6-disable)
rcp_kernel_ipv6_disable () {
    echo 'Disabling IPv6 via kernel boot parameter'
    echo TODO kernel-ipv6-disable
}

recipes_all+=(sysctl-hardening-ipv4)
rcp_sysctl_hardening_ipv4 () {
    echo 'TODO description'
    echo TODO sysctl-hardening-ipv4
    changed_sysctl=y
}

recipes_all+=(sysctl-hardening-ipv6)
rcp_sysctl_hardening_ipv6 () {
    echo 'TODO description'
    echo TODO sysctl-hardening-ipv6
    changed_sysctl=y
}

recipes_all+=(sysctl-ipv6-disable)
rcp_sysctl_ipv6_disable () {
    echo 'Disabling IPv6 via sysctl'
    echo TODO sysctl-ipv6-disable
    changed_sysctl=y
}

recipes_all+=(hosts-127011)
rcp_hosts_127011 () {
    echo 'TODO description'
    echo TODO hosts-127011
}

recipes_all+=(nm-ipv6-disable)
rcp_nm_ipv6_disable () {
    echo 'Disabling IPv6 via NetworkManager dispatcher'
    echo TODO nm-ipv6-disable
    changed_nm=y
}

recipes_all+=(timesyncd-dhcp-ntp-disable)
rcp_timesyncd_dhcp_ntp_disable () {
    echo 'TODO description'
    echo TODO timesyncd-dhcp-ntp-disable
    changed_timesyncd=y
}

recipes_all+=(sshd-rootlogin-no)
rcp_sshd_rootlogin_no () {
    echo 'TODO description'
    echo TODO sshd-rootlogin-no
    changed_sshd=y
}

recipes_all+=(sshd-hostbasedauth-no)
rcp_sshd_hostbasedauth_no () {
    echo 'TODO description'
    echo TODO sshd-hostbasedauth-no
    changed_sshd=y
}

recipes_all+=(sshd-emptypsws-no)
rcp_sshd_emptypsws_no () {
    echo 'TODO description'
    echo TODO sshd-emptypsws-no
    changed_sshd=y
}

recipes_all+=(sshd-addressfamily-inet)
rcp_sshd_addressfamily_inet () {
    echo 'TODO description'
    echo TODO sshd-addressfamily-inet
    changed_sshd=y
}

recipes_all+=(sshd-pswauth-no)
rcp_sshd_pswauth_no () {
    echo 'TODO description'
    echo TODO sshd-pswauth-no
    changed_sshd=y
}

recipes_all+=(adduser-dirmode-700)
rcp_adduser_dirmode_700 () {
    echo 'TODO description'
    echo TODO adduser-dirmode-700
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
