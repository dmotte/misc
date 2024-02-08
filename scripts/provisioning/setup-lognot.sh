#!/bin/bash

set -e

# Lognot ("LOG NOTifier") is a simple system that allows you to receive
# notifications (Telegram messages) about your server logs. This script helps
# you set it up

# Usage example:
#   sudo bash setup-lognot.sh TODO

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

options=$(getopt -o s:i:m:b:c: -l service-manager: -l source-cmd: \
    -l msgbuf-url -l msgbuf-checksum \
    -l msgbuf-interval: -l msgbuf-max-msg-len: -l bot-token: -l chat-id: \
    -l supervisor-priority: -l systemd-restartsec: -l systemd-wantedby: -- "$@")
eval "set -- $options"

service_manager=auto
source_cmd=''
msgbuf_url="https://github.com/dmotte/msgbuf/releases/latest/download/msgbuf-$(uname -m)-unknown-linux-gnu"
msgbuf_checksum='3fcec4e61ef0fdbc9e4a703ba3c5b3075b20336d57b963e05676ccdab3ad5ca4'
msgbuf_interval=60 # seconds
msgbuf_max_msg_len=2048 # bytes
bot_token='' # Telegram bot token
chat_id='' # Telegram chat ID of the recipient
supervisor_priority=50
systemd_restartsec=30
systemd_wantedby=multi-user.target

while :; do
    case "$1" in
        --service-manager) shift; service_manager="$1";;
        -s|--source-cmd) shift; source_cmd="$1";;
        --msgbuf-url) shift; msgbuf_url="$1";;
        --msgbuf-checksum) shift; msgbuf_checksum="$1";;
        -i|--msgbuf-interval) shift; msgbuf_interval="$1";;
        -m|--msgbuf-max-msg-len) shift; msgbuf_max_msg_len="$1";;
        -b|--bot-token) shift; bot_token="$1";;
        -c|--chat-id) shift; chat_id="$1";;
        --supervisor-priority) shift; supervisor_priority="$1";;
        --systemd-restartsec) shift; systemd_restartsec="$1";;
        --systemd-wantedby) shift; systemd_wantedby="$1";;
        --) shift; break;;
    esac
    shift
done

[[ "$service_manager" =~ ^(auto|supervisor|systemd)$ ]] || \
    { echo "Unsupported service manager: $service_manager" >&2; exit 1; }

# TODO error if source_cmd or bot_token or chat_id are empty

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        apt-get update
    fi
}

################################################################################

apt_update_if_old; apt-get install -y curl

# TODO service manager detection if "auto"

# TODO

################################################################################

if [ "$LOGNOT_RELOAD" = 'true' ]; then
    # TODO also commands for supervisorctl
    systemctl daemon-reload
    systemctl restart lognot
fi
