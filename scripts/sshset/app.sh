#!/bin/bash

set -e

# (
#     unset -- "${!SSHSET_@}"
#     export SSHSET_SETUP_SERVER=true
#     bash /opt/sshset/main.sh
# )

bash /opt/sshset/main.sh

################################################################################

# if [ "$EUID" = 0 ]
#     then exec /usr/sbin/sshd -De "$@"
#     else exec /usr/sbin/sshd -Def ~/.ssh/sshd_config "$@"
# fi

# exec /usr/bin/ssh "$@"

exec /bin/bash "$@"
