#!/bin/bash

set -e

# Lognot ("LOG NOTifier") is a simple system that allows you to receive
# notifications (Telegram messages) about your server logs. This script helps
# you set it up

# Tested on Debian 12 (bookworm)

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o +i:m:b:c: -l service-manager: \
    -l msgbuf-url: -l msgbuf-checksum: \
    -l msgbuf-interval: -l msgbuf-max-msg-len: -l bot-token: -l chat-id: \
    -l supervisor-priority: -l systemd-restartsec: -l systemd-wantedby: -- "$@")
eval "set -- $options"

service_manager=auto
msgbuf_url=${MSGBUF_URL:-https://github.com/dmotte/msgbuf/releases/latest/download/msgbuf-$(uname -m)-unknown-linux-gnu}
msgbuf_checksum=${MSGBUF_CHECKSUM:-9819d40df68be4df94adc47692f83f24ce9b6e9481b525194b5c661d5d8ac94c} # The default value is the checksum for v1.0.3 x86_64
msgbuf_interval=10 # seconds
msgbuf_max_msg_len=2048 # bytes
bot_token='' # Telegram bot token
chat_id='' # Telegram chat ID of the recipient
supervisor_priority=50
systemd_restartsec=30
systemd_wantedby=multi-user.target

while :; do
    case $1 in
        --service-manager) shift; service_manager=$1;;
        --msgbuf-url) shift; msgbuf_url=$1;;
        --msgbuf-checksum) shift; msgbuf_checksum=$1;;
        -i|--msgbuf-interval) shift; msgbuf_interval=$1;;
        -m|--msgbuf-max-msg-len) shift; msgbuf_max_msg_len=$1;;
        -b|--bot-token) shift; bot_token=$1;;
        -c|--chat-id) shift; chat_id=$1;;
        --supervisor-priority) shift; supervisor_priority=$1;;
        --systemd-restartsec) shift; systemd_restartsec=$1;;
        --systemd-wantedby) shift; systemd_wantedby=$1;;
        --) shift; break;;
    esac
    shift
done

source_cmd=$* # Warning: some characters are forbidden. See the code below

[[ "$service_manager" =~ ^(auto|supervisor|systemd)$ ]] ||
    { echo "Unsupported service manager: $service_manager" >&2; exit 1; }

[ -n "$source_cmd" ] || { echo 'Source command cannot be empty' >&2; exit 1; }
{ [[ "$source_cmd" != *\'* ]] && [[ "$source_cmd" != *$'\n'* ]]; } ||
    { echo 'The source command contains invalid characters' >&2; exit 1; }

[ -n "$bot_token" ] || { echo 'Bot token cannot be empty' >&2; exit 1; }
[ -n "$chat_id" ] || { echo 'Chat ID cannot be empty' >&2; exit 1; }

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

################################################################################

if [ "$service_manager" = auto ]; then
    if command -v supervisord >/dev/null; then service_manager=supervisor
    else service_manager=systemd; fi

    echo "Detected service manager: $service_manager"
fi

bot_token=${bot_token#bot}

################################################################################

[ -e /opt/lognot ] || changing=y

dpkg -s curl >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y curl; }

install -dm700 /opt/lognot

if [ ! -e /opt/lognot/msgbuf ]; then
    echo "Downloading msgbuf binary from $msgbuf_url"
    curl -fLo /opt/lognot/msgbuf "$msgbuf_url"
    echo "$msgbuf_checksum /opt/lognot/msgbuf" | sha256sum -c
    chmod 700 /opt/lognot/msgbuf
fi

echo 'Creating lognot service files'

install -Tm700 /dev/stdin /opt/lognot/tg.sh << EOF
#!/bin/bash

set -e

bot_token=${bot_token@Q}
chat_id=${chat_id@Q}

curl -sSXPOST "https://api.telegram.org/bot\$bot_token/sendMessage" \\
    -dchat_id="\$chat_id" --data-urlencode text@- --fail-with-body -w'\n'
EOF

if [ "$service_manager" = supervisor ]; then
    cat << EOF > /etc/supervisor/conf.d/lognot.conf
[program:lognot]
command=/bin/bash -ec '$source_cmd |
    /opt/lognot/msgbuf -i$msgbuf_interval -m$msgbuf_max_msg_len -- \\
        /bin/bash /opt/lognot/tg.sh'
priority=$supervisor_priority
directory=/opt/lognot
EOF
elif [ "$service_manager" = systemd ]; then
    cat << EOF > /etc/systemd/system/lognot.service
[Unit]
Description=lognot

# Disable unit start rate limiting
StartLimitIntervalSec=0

[Service]
Type=simple

WorkingDirectory=/opt/lognot
ExecStart=/bin/bash -ec '$source_cmd | \\
    /opt/lognot/msgbuf -i$msgbuf_interval -m$msgbuf_max_msg_len -- \\
        /bin/bash /opt/lognot/tg.sh'

Restart=always
RestartSec=$systemd_restartsec

[Install]
WantedBy=$systemd_wantedby
EOF
    echo 'Reloading systemd config and enabling lognot service'
    systemctl daemon-reload; systemctl enable lognot
fi

################################################################################

if [ "$LOGNOT_RELOAD" = always ] || {
    [ "$LOGNOT_RELOAD" = when-changed ] && [ "$changing" = y ]
}; then
    if [ "$service_manager" = supervisor ]; then
        echo 'Running supervisorctl update'
        supervisorctl update
    elif [ "$service_manager" = systemd ]; then
        echo 'Restarting lognot'
        systemctl restart lognot
    fi
fi
