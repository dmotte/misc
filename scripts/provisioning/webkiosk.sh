#!/bin/bash

set -e

# This script turns your Linux device into a web kiosk (i.e. a device whose sole
# purpose is to display a web page and consent minimal user interaction). This
# can be useful e.g. to display information on a large screen or similar

# To make the system as lightweight as possible, only Xorg and a full-screen
# Chromium browser instance are started. No window manager needed!

# Tested on Debian 12 (bookworm)

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

for i in xorg chromium; do
    dpkg -s "$i" >/dev/null 2>&1 ||
        { apt_update_if_old; apt-get install -y --no-install-recommends "$i"; }
done

# The Xorg setuid wrapper is needed to start Xorg as a non-root user. You can
# configure it by editing the /etc/X11/Xwrapper.config file
dpkg -s xserver-xorg-legacy >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y xserver-xorg-legacy; }

if ! id kioskuser >/dev/null 2>&1; then
    echo 'Creating user kioskuser'
    useradd -Ums/bin/bash kioskuser
fi

echo 'Creating kiosk service files'

install -okioskuser -gkioskuser -Tm644 /dev/stdin ~kioskuser/.xinitrc << 'EOF'
#!/bin/bash

set -e

# Get display resolution

display_resolution=$(xrandr --current | grep \* | uniq | awk '{print $1}')
display_res_w=$(echo $display_resolution | cut -dx -f1 | sed 's/[^0-9]*//g')
display_res_h=$(echo $display_resolution | cut -dx -f2 | sed 's/[^0-9]*//g')

# Disable Xorg screen blanking and DPMS

xset s off -dpms

# Disable some keys (see https://stackoverflow.com/a/44804851)

xmodmap -e 'keycode 37 = '   # Disable the CTRL_L key in the current display
xmodmap -e 'keycode 105 = '  # Disable the CTRL_R key in the current display

xmodmap -e 'keycode 64 = '   # Disable the Alt_L key in the current display
xmodmap -e 'keycode 204 = '

xmodmap -e 'keycode 133 = '  # Disable the Super_L key in the current display
xmodmap -e 'keycode 134 = '  # Disable the Super_R key in the current display

xmodmap -e 'keycode 67 = Escape'  # Disable the F1 key in the current display
xmodmap -e 'keycode 71 = Escape'  # Disable the F5 key in the current display

# Start Chromium in kiosk mode
# For more information on the command line options, see the following link:
# https://peter.sh/experiments/chromium-command-line-switches/

chromium --kiosk \
    --window-position=0,0 --window-size="$display_res_w,$display_res_h" \
    --disable-translate --disable-sync --noerrdialogs --no-message-box \
    --no-first-run --start-fullscreen --disable-hang-monitor \
    --disable-infobars --disable-logging --disable-sync \
    --disable-settings-window \
    '{{ webkiosk_url }}'
EOF

sed -i "s|{{ webkiosk_url }}|$webkiosk_url|" ~kioskuser/.xinitrc

install -okioskuser -gkioskuser -Tm644 /dev/stdin ~kioskuser/.profile << 'EOF'
# If $DISPLAY is not defined and I'm on TTY7
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 7 ]; then
    # Run startx replacing the current process
    exec /usr/bin/startx
fi
EOF

cat << 'EOF' > /etc/systemd/system/kiosk.service
[Unit]
Description=startx on tty7

# Disable unit start rate limiting
StartLimitIntervalSec=0

[Service]
Type=simple

WorkingDirectory=/home/kioskuser
ExecStartPre=/bin/chvt 7
ExecStart=/bin/su -l kioskuser

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
