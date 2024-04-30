#!/bin/bash

set -e

# This script can be used to install and configure Podman on Linux at system
# level, or to configure Podman for a single user

# Tested on Debian 12 (bookworm)

# Usage example:
#   sudo SYSCTL_RELOAD=always bash setup-podman.sh system -cs0 -anever -p80
#   sudo useradd -Ums/bin/bash alice
#   sudo loginctl enable-linger alice
#   sudo XDG_RUNTIME_DIR=/run/user/$(id -u alice) -ualice bash \
#     setup-podman.sh user -s0 -a'Mon 01:00' \
#     -k--net=slirp4netns:port_handler=slirp4netns,enable_ipv6=false

# Note: you may need to wait a few seconds for the systemd user session to
# initialize after running "enable-linger"

mode=${1:?}; shift

if [ "$mode" = system ]; then
    [ "$EUID" = 0 ] ||
        { echo 'Must run as root if mode=system is used' >&2; exit 1; }
    scoped_systemctl() { systemctl "$@"; }
    systemd_units_dir=/etc/systemd/system
elif [ "$mode" = user ]; then
    [ "$EUID" != 0 ] ||
        { echo 'Must run as a regular user if mode=user is used' >&2; exit 1; }
    scoped_systemctl() { systemctl --user "$@"; }
    systemd_units_dir=~/.config/systemd/user
else
    echo 'Invalid mode' >&2; exit 1
fi

options=$(getopt -o +cs:a:k:p: -l compose -l socket: -l auto-update: \
    -l kube-extra-args: -l unprivileged-port-start: -- "$@")
eval "set -- $options"

flag_compose=n
socket=$SETUP_PODMAN_SOCKET
auto_update=$SETUP_PODMAN_AUTO_UPDATE
kube_extra_args=$SETUP_PODMAN_KUBE_EXTRA_ARGS
unprivileged_port_start=''

while :; do
    case $1 in
        -c|--compose) flag_compose=y;;
        -s|--socket) shift; socket=$1;;
        -a|--auto-update) shift; auto_update=$1;;
        -k|--kube-extra-args) shift; kube_extra_args=$1;;
        -p|--unprivileged-port-start) shift; unprivileged_port_start=$1;;
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

if [ "$mode" = system ]; then
    dpkg -s podman >/dev/null 2>&1 ||
        { apt_update_if_old; apt-get install -y podman; changing=y; }

    if [ "$flag_compose" = y ]; then
        dpkg -s podman-compose >/dev/null 2>&1 ||
            { apt_update_if_old; apt-get install -y podman-compose; }
    fi

    echo 'Disabling the podman-auto-update service at boot'
    systemctl disable podman-auto-update
elif [ "$mode" = user ]; then
    echo 'Starting the D-Bus socket for the user'
    # To fix https://github.com/containers/podman/issues/12983 immediately,
    # without rebooting
    systemctl --user start dbus.socket
fi

if [ "$socket" = 0 ]; then
    echo 'Disabling Podman socket'
    scoped_systemctl disable --now podman.socket
    scoped_systemctl mask --now podman.socket
    scoped_systemctl stop podman
elif [ "$socket" = 1 ]; then
    echo 'Enabling Podman socket'
    scoped_systemctl unmask --now podman.socket
    scoped_systemctl enable --now podman.socket
fi

if [ "$auto_update" = never ]; then
    echo 'Disabling Podman auto-update'
    scoped_systemctl disable --now podman-auto-update.timer
elif [ -n "$auto_update" ]; then
    echo 'Enabling Podman auto-update'
    install -Dm644 /dev/stdin \
        "$systemd_units_dir/podman-auto-update.timer.d/override.conf" << EOF
[Timer]
# The empty "OnCalendar=" line is needed to reset the default value
OnCalendar=
OnCalendar=$auto_update
RandomizedDelaySec=0
EOF
    scoped_systemctl daemon-reload
    scoped_systemctl enable podman-auto-update.timer
    scoped_systemctl restart podman-auto-update.timer
fi

if [ -n "$kube_extra_args" ]; then
    echo 'Setting Podman kube extra args'
    install -Dm644 /dev/stdin \
        "$systemd_units_dir/podman-kube@.service.d/override.conf" << EOF
[Service]
# The empty "ExecStart=" line is needed to reset the default value
ExecStart=
$(grep '^ExecStart=' "/usr/lib/systemd/$mode/podman-kube@.service" |
    sed "s|%I|$kube_extra_args %I|")
EOF
    scoped_systemctl daemon-reload
fi

if [ "$mode" = system ] && [ -n "$unprivileged_port_start" ]; then
    echo "net.ipv4.ip_unprivileged_port_start=$unprivileged_port_start" |
        tee /etc/sysctl.d/99-unprivileged-port-start.conf
fi

################################################################################

if [ "$mode" = system ] && {
    [ "$SYSCTL_RELOAD" = always ] || {
        [ "$SYSCTL_RELOAD" = when-changed ] && [ "$changing" = y ]
    }
}; then
    sysctl --system
fi
