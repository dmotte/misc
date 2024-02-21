#!/bin/bash

set -e

# This script can be used to configure unattended upgrades on Debian. See
# https://wiki.debian.org/UnattendedUpgrades for more information

# Tested on Debian 12 (bookworm)

# Tip: if you want to check in advance how a systemd calendar event expression
# will behave, you can use the systemd-analyze command:
#   systemd-analyze calendar '*-*-* 6,18:00' --iterations 10
# See https://www.freedesktop.org/software/systemd/man/systemd.time.html

# Usage example:
#   sudo UNATTENDED_UPGRADES_RELOAD=true bash \
#     unattended-upgrades.sh -rt'*-*-* 04:00' -T'*-*-* 05:00'

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o rt:T: -l auto-reboot,timer-update:,timer-upgrade: -- "$@")
eval "set -- $options"

auto_reboot='false'
timer_update=''
timer_upgrade=''

while :; do
    case "$1" in
        -r|--auto-reboot) auto_reboot=true;;
        -t|--timer-update) shift; timer_update="$1";;
        -T|--timer-upgrade) shift; timer_upgrade="$1";;
        --) shift; break;;
    esac
    shift
done

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

################################################################################

dpkg -s unattended-upgrades >/dev/null 2>&1 || \
    { apt_update_if_old; apt-get install -y unattended-upgrades; }

install -Dm644 /dev/stdin /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Origins-Pattern { "origin=*"; };
Unattended-Upgrade::Package-Blacklist {};

// Remove unused automatically installed kernel-related packages
// (kernel images, kernel headers and kernel version locked tools).
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
// Do automatic removal of newly unused dependencies after the upgrade
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
// Do automatic removal of unused packages after the upgrade
// (equivalent to apt-get autoremove)
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Automatically reboot *WITHOUT CONFIRMATION* if
//  the file /var/run/reboot-required is found after the upgrade
Unattended-Upgrade::Automatic-Reboot "$auto_reboot";
// Automatically reboot even if there are users currently logged in
// when Unattended-Upgrade::Automatic-Reboot is set to true
Unattended-Upgrade::Automatic-Reboot-WithUsers "$auto_reboot";

// Enable logging to syslog
Unattended-Upgrade::SyslogEnable "true";

// Download and install upgrades even on AC power
// This is needed because the powermgmt-base package is not installed, so
// unattended-upgrade is unable to check power status
Unattended-Upgrade::OnlyOnACPower "false";
// Download and install upgrades even on metered connection
// This is needed because the python3-gi package is not installed, so
// unattended-upgrade is unable to detect metered connections
Unattended-Upgrade::Skip-Updates-On-Metered-Connections "false";
EOF

if [ -n "$timer_update" ]; then
    echo 'Setting event expression for the apt-daily.timer unit'
    install -Dm644 /dev/stdin \
        /etc/systemd/system/apt-daily.timer.d/override.conf << EOF
[Timer]
# The empty "OnCalendar=" line is needed to reset the default value
OnCalendar=
OnCalendar=$timer_update
RandomizedDelaySec=0
EOF
fi

if [ -n "$timer_upgrade" ]; then
    echo 'Setting event expression for the apt-daily-upgrade.timer unit'
    install -Dm644 /dev/stdin \
        /etc/systemd/system/apt-daily-upgrade.timer.d/override.conf << EOF
[Timer]
# The empty "OnCalendar=" line is needed to reset the default value
OnCalendar=
OnCalendar=$timer_upgrade
RandomizedDelaySec=0
EOF
fi

# This should create the /etc/apt/apt.conf.d/20auto-upgrades file
echo 'unattended-upgrades unattended-upgrades/enable_auto_updates' \
    'boolean true' | debconf-set-selections -v

################################################################################

if [ "$UNATTENDED_UPGRADES_RELOAD" = 'true' ]; then
    systemctl daemon-reload
    systemctl restart apt-daily.timer apt-daily-upgrade.timer
    dpkg-reconfigure -f noninteractive unattended-upgrades
fi
