#!/bin/bash

set -e

bash /opt/sshset/main.sh

# exec /usr/sbin/sshd -De
# exec /usr/sbin/sshd -Def ~/.ssh/sshd_config
exec /bin/bash
