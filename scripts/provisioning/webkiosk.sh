#!/bin/bash

set -e

# This script turns your Linux device into a web-based kiosk (i.e. a device
# whose sole purpose is to display a full-screen maximized web page, and
# consent minimal user interaction). This can be useful e.g. to display
# information on a large screen or similar

# Tested on Debian 13 (trixie)

# Usage example:
#   sudo KIOSK_RESTART=when-changed bash webkiosk.sh \
#     https://play.grafana.org/?theme=dark

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

readonly webkiosk_url=${1:-http://127.0.0.1/}

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

################################################################################

[ -e /etc/systemd/system/kiosk.service ] || changing=y

for i in cage chromium; do
    dpkg -s "$i" >/dev/null 2>&1 ||
        { apt_update_if_old; apt-get install -y "$i"; }
done

if ! id kioskuser >/dev/null 2>&1; then
    echo 'Creating user kioskuser'
    useradd -Ums/bin/bash kioskuser
fi

echo 'Creating kiosk service files'

install -okioskuser -gkioskuser -DTvm644 /dev/stdin \
    ~kioskuser/.config/xkb/symbols/kiosk << EOF
default partial alphanumeric_keys
xkb_symbols "basic" {
    // Overwrite the left and right "Ctrl" keys to do nothing
    replace key <LCTL> { [ VoidSymbol ] };
    replace key <RCTL> { [ VoidSymbol ] };

    // Overwrite the left and right "Alt" keys to do nothing
    replace key <LALT> { [ VoidSymbol ] };
    replace key <RALT> { [ VoidSymbol ] };

    // Overwrite the left and right "Super" keys to do nothing
    replace key <LWIN> { [ VoidSymbol ] };
    replace key <RWIN> { [ VoidSymbol ] };

    // Overwrite function keys to Escape (VoidSymbol wouldn't work here)
    replace key <FK01> { [ Escape ] };
    replace key <FK02> { [ Escape ] };
    replace key <FK03> { [ Escape ] };
    replace key <FK04> { [ Escape ] };
    replace key <FK05> { [ Escape ] };
    replace key <FK06> { [ Escape ] };
    replace key <FK07> { [ Escape ] };
    replace key <FK08> { [ Escape ] };
    replace key <FK09> { [ Escape ] };
    replace key <FK10> { [ Escape ] };
    replace key <FK11> { [ Escape ] };
    replace key <FK12> { [ Escape ] };
    replace key <FK13> { [ Escape ] };
    replace key <FK14> { [ Escape ] };
    replace key <FK15> { [ Escape ] };
    replace key <FK16> { [ Escape ] };
    replace key <FK17> { [ Escape ] };
    replace key <FK18> { [ Escape ] };
    replace key <FK19> { [ Escape ] };
    replace key <FK20> { [ Escape ] };
    replace key <FK21> { [ Escape ] };
    replace key <FK22> { [ Escape ] };
    replace key <FK23> { [ Escape ] };
    replace key <FK24> { [ Escape ] };
};
EOF

install -okioskuser -gkioskuser -DTvm644 /dev/stdin \
    ~kioskuser/.config/xkb/rules/evdev << EOF
! option = symbols
  kiosk = +kiosk

! include %S/evdev
EOF

install -okioskuser -gkioskuser -Tvm644 /dev/stdin ~kioskuser/kiosk.sh << EOF
#!/bin/bash

set -e

cd "\$(dirname "\$0")"

# Force wlroots to use the CPU-based Pixman renderer instead of the GPU,
# maximizing hardware compatibility
export WLR_RENDERER=pixman

export XKB_DEFAULT_OPTIONS=kiosk

# Uncomment the following line to enable dark theme
# export GTK_THEME=Adwaita:dark

# Start Cage with Chromium in kiosk mode
# For more information on Chromium's command line options, see this link:
# https://peter.sh/experiments/chromium-command-line-switches/
cage -d -- chromium --kiosk \\
    --disable-translate --disable-sync --noerrdialogs --no-message-box \\
    --no-first-run --start-fullscreen --disable-hang-monitor \\
    --disable-infobars --disable-logging --disable-settings-window \\
    ${webkiosk_url@Q}
EOF

install -Tvm644 /dev/stdin /etc/systemd/system/kiosk.service << 'EOF'
[Unit]
Description=kiosk

# Disable unit start rate limiting
StartLimitIntervalSec=0

[Service]
Type=simple

User=kioskuser
# Needed to have XDG_RUNTIME_DIR
PAMName=login

WorkingDirectory=/home/kioskuser
ExecStartPre=/bin/chvt 7
ExecStart=/bin/bash /home/kioskuser/kiosk.sh

StandardInput=tty
StandardOutput=tty
StandardError=tty
TTYPath=/dev/tty7

Restart=always
RestartSec=5

[Install]
WantedBy=getty.target
EOF

echo 'Reloading systemd config and enabling kiosk service'
systemctl daemon-reload; systemctl enable kiosk

################################################################################

if [ "$KIOSK_RESTART" = always ] || {
    [ "$KIOSK_RESTART" = when-changed ] && [ "$changing" = y ]
}; then
    echo 'Restarting kiosk'
    systemctl restart kiosk
fi
