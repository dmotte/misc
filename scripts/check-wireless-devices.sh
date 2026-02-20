#!/bin/bash

set -e

# To run this script without downloading it:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/check-wireless-devices.sh); echo $?

# Tested on Debian 13 (trixie)

echo 'Checking that no wireless devices are present'

text=$(bash -c 'lspci; lsusb; lsmod; ip a; rfkill list' 2>&1 || :)
if echo "$text" | grep -Ei 'wireless|wifi|wi-fi|wlan|802\.11|80211|bluetooth'; then
    echo 'Some wireless device(s) found' >&2; exit 1
fi
text=$(systemctl status bluetooth 2>&1 || :)
if [ "$text" != 'Unit bluetooth.service could not be found.' ]; then
    echo 'The bluetooth.service unit may be running' >&2; exit 1
fi
