#!/bin/bash

set -e

bash /opt/sshset/main.sh

################################################################################

# if [ "$EUID" = 0 ]
#     then exec /usr/sbin/sshd -De "$@"
#     else exec /usr/sbin/sshd -Def ~/.ssh/sshd_config "$@"
# fi

# exec /usr/bin/ssh "$@"

exec /bin/bash "$@"
