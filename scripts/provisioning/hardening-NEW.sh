#!/bin/bash

set -e

# This script contains several hardening recipes for Linux hosts

# Tested on Debian 13 (trixie)

# Usage example:
#   sudo HARDENING_RELOAD=always bash hardening.sh TODOrecipes

# Warning: this is only a partial hardening and it should only serve as
# inspiration to make your own real hardening based on your specific environment

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

# TODO in the end: test everything thoroughly
# TODO in the end: make sure to put all the stuff from the old hardening.sh

# TODO verbose recipes
# TODO no more installed_xxx vars; be explicit about all the recipes in the args instead
# TODO force the order of recipes appropriately (and final restarts accordingly)
# TODO multiple changed_xxx vars, so you can simplify the checks in the final restarts
# TODO add some helper recipes (at the beginning) that invoke other commonly used recipes

################################################################################

recipes_all=()

recipes_all+=(pam-umask-nousergroups)
rcp_pam_umask_nousergroups () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(kernel-ipv6-disable)
rcp_kernel_ipv6_disable () {
    echo 'Disabling IPv6 via kernel boot parameter'
    echo TODO
}

recipes_all+=(sysctl-hardening-ipv4)
rcp_sysctl_hardening_ipv4 () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(sysctl-hardening-ipv6)
rcp_sysctl_hardening_ipv6 () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(sysctl-ipv6-disable)
rcp_sysctl_ipv6_disable () {
    echo 'Disabling IPv6 via sysctl'
    echo TODO
}

recipes_all+=(hosts-127011)
rcp_hosts_127011 () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(nm-ipv6-disable)
rcp_nm_ipv6_disable () {
    echo 'Disabling IPv6 via NetworkManager dispatcher'
    echo TODO
}

recipes_all+=(timesyncd-dhcp-ntp-disable)
rcp_timesyncd_dhcp_ntp_disable () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(sshd-rootlogin-no)
rcp_sshd_rootlogin_no () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(sshd-hostbasedauth-no)
rcp_sshd_hostbasedauth_no () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(sshd-emptypsws-no)
rcp_sshd_emptypsws_no () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(sshd-addressfamily-inet)
rcp_sshd_addressfamily_inet () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(sshd-pswauth-no)
rcp_sshd_pswauth_no () {
    echo 'TODO description'
    echo TODO
}

recipes_all+=(adduser-dirmode-700)
rcp_adduser_dirmode_700 () {
    echo 'TODO description'
    echo TODO
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
