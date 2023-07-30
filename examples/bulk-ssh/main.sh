#!/bin/bash

set -e

cd "$(dirname "$0")"

sshpass -e ssh user@host01 bash -s < remote.sh
sshpass -e ssh user@host02 bash -s < remote.sh
sshpass -e ssh user@host03 bash -s < remote.sh
