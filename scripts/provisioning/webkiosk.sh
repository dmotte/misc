#!/bin/bash

set -e

# This script turns your Linux device into a web kiosk (i.e. a device whose sole
# purpose is to display a web page and consent minimal user interaction). This
# can be useful e.g. to display information on a large screen or similar

# To make the system as lightweight as possible, only Xorg and a full-screen
# Chromium browser instance are started. No window manager needed!

# Tested on Debian 12 (bookworm)

if [ "$EUID" != '0' ]; then
    echo 'This script must be run as root' >&2
    exit 1
fi

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

webkiosk_url="${1:-http://127.0.0.1/}"

################################################################################

apt_update_if_old
apt-get install -y --no-install-recommends xorg chromium
# This is needed to start Xorg as a non-root user. You can configure
# Xorg wrapper by editing the /etc/X11/Xwrapper.config file
apt-get install -y xserver-xorg-legacy

if [ ! -e ~kioskuser ]; then useradd -Ums/bin/bash kioskuser; fi

install -okioskuser -gkioskuser -m644 /dev/stdin ~kioskuser/.xinitrc << 'EOF'
#!/bin/bash

set -e

# Get display resolution

DISPLAY_RESOLUTION="$(xrandr --current | grep \* | uniq | awk '{print $1}')"
DISPLAY_RES_W="$(echo $DISPLAY_RESOLUTION | cut -dx -f1 | sed 's/[^0-9]*//g')"
DISPLAY_RES_H="$(echo $DISPLAY_RESOLUTION | cut -dx -f2 | sed 's/[^0-9]*//g')"

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
    --window-position=0,0 --window-size="$DISPLAY_RES_W,$DISPLAY_RES_H" \
    --disable-translate --disable-sync --noerrdialogs --no-message-box \
    --no-first-run --start-fullscreen --disable-hang-monitor \
    --disable-infobars --disable-logging --disable-sync \
    --disable-settings-window \
    '{{ webkiosk_url }}'
EOF

sed -i "s|{{ webkiosk_url }}|$webkiosk_url|" ~kioskuser/.xinitrc

install -okioskuser -gkioskuser -m644 /dev/stdin ~kioskuser/.profile << 'EOF'
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

systemctl enable kiosk

################################################################################

if [ "$SYSTEMCTL_DAEMON_RELOAD" = 'true' ]; then systemctl daemon-reload; fi
if [ "$KIOSK_RESTART" = 'true' ]; then systemctl restart kiosk; fi
