#!/bin/bash

set -e

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

cd "$(dirname "$0")"

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

################################################################################

[ -e /opt/raspi-safe-shutdown ] || changing=y

dpkg -s python3-rpi.gpio >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y python3-rpi.gpio; }

install -dvm700 /opt/raspi-safe-shutdown

echo 'Creating raspi-safe-shutdown service files'

install -Tm700 raspi-safe-shutdown.py /opt/raspi-safe-shutdown/main.py

cat << EOF > /etc/systemd/system/raspi-safe-shutdown.service
[Unit]
Description=raspi-safe-shutdown

# Disable unit start rate limiting
StartLimitIntervalSec=0

[Service]
Type=simple

WorkingDirectory=/opt/raspi-safe-shutdown
ExecStart=/usr/bin/python3 -u /opt/raspi-safe-shutdown/main.py

Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

echo 'Reloading systemd config and enabling raspi-safe-shutdown service'
systemctl daemon-reload; systemctl enable raspi-safe-shutdown

################################################################################

if [ "$RASPI_SAFE_SHUTDOWN_RESTART" = always ] || {
    [ "$RASPI_SAFE_SHUTDOWN_RESTART" = when-changed ] && [ "$changing" = y ]
}; then
    echo 'Restarting raspi-safe-shutdown'
    systemctl restart raspi-safe-shutdown
fi
