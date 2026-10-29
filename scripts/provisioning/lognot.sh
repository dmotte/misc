#!/bin/bash

set -e

# Lognot ("LOG NOTifier") is a simple system that allows you to receive
# notifications (Telegram messages) about your server logs. This script helps
# you set it up

# Tested on Debian 13 (trixie)

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o +i:m:b:c: -l msgbuf-url:,msgbuf-checksum: \
    -l msgbuf-interval:,msgbuf-max-msg-len:,bot-token:,chat-id: \
    -l systemd-restartsec:,systemd-wantedby: -- "$@")
eval "set -- $options"

msgbuf_url=${MSGBUF_URL:-https://github.com/dmotte/msgbuf/releases/latest/download/msgbuf-$(uname -m)-unknown-linux-gnu}
msgbuf_checksum=${MSGBUF_CHECKSUM:-f04eab84ecabde00b1c69971ce54add10699542a89e28c6e076365fb4593d850} # The default value is the checksum for v2.0.0 x86_64
msgbuf_interval=10000 # milliseconds
msgbuf_max_msg_len=4000 # bytes
bot_token='' # Telegram bot token
chat_id='' # Telegram chat ID of the recipient
systemd_restartsec=30
systemd_wantedby=multi-user.target

while :; do
    case $1 in
        --msgbuf-url) shift; msgbuf_url=$1;;
        --msgbuf-checksum) shift; msgbuf_checksum=$1;;
        -i|--msgbuf-interval) shift; msgbuf_interval=$1;;
        -m|--msgbuf-max-msg-len) shift; msgbuf_max_msg_len=$1;;
        -b|--bot-token) shift; bot_token=$1;;
        -c|--chat-id) shift; chat_id=$1;;
        --systemd-restartsec) shift; systemd_restartsec=$1;;
        --systemd-wantedby) shift; systemd_wantedby=$1;;
        --) shift; break;;
    esac
    shift
done

source_cmd=$* # Warning: some characters are forbidden. See the code below

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

bot_token=${bot_token#bot}

[ -e /opt/lognot ] || changing=y

dpkg -s curl >/dev/null 2>&1 ||
    { apt_update_if_old; apt-get install -y curl; }

install -dvm700 /opt/lognot

if [ ! -e /opt/lognot/msgbuf ]; then
    echo "Downloading msgbuf binary from $msgbuf_url"
    curl -fLo /opt/lognot/msgbuf "$msgbuf_url"
    echo "$msgbuf_checksum /opt/lognot/msgbuf" | sha256sum -c
    chmod -v 700 /opt/lognot/msgbuf
fi

install -Tvm700 /dev/stdin /opt/lognot/tg.sh <<EOF
#!/bin/bash

set -e

readonly bot_token=${bot_token@Q}
readonly chat_id=${chat_id@Q}

exec curl -sSXPOST "https://api.telegram.org/bot\$bot_token/sendMessage" \\
    --data-urlencode 'link_preview_options={"is_disabled":true}' \\
    -dchat_id="\$chat_id" --data-urlencode text@- --fail-with-body -w'\n'
EOF

install -Tvm644 /dev/stdin /etc/systemd/system/lognot.service <<EOF
[Unit]
Description=lognot

# Disable unit start rate limiting
StartLimitIntervalSec=0

[Service]
Type=simple

WorkingDirectory=/opt/lognot
ExecStart=/bin/bash -ec '$source_cmd | \\
    /opt/lognot/msgbuf -i$msgbuf_interval -m$msgbuf_max_msg_len -s10 -- \\
        /bin/bash /opt/lognot/tg.sh'

Restart=always
RestartSec=$systemd_restartsec

[Install]
WantedBy=$systemd_wantedby
EOF

echo 'Reloading systemd config and enabling lognot service'
systemctl daemon-reload; systemctl enable lognot

################################################################################

if [ "$LOGNOT_RELOAD" = always ] || {
    [ "$LOGNOT_RELOAD" = when-changed ] && [ "$changing" = y ]
}; then
    echo 'Restarting lognot'
    systemctl restart lognot
fi
