#!/bin/bash

set -e

cd "$(dirname "$0")"

if [[ "$(uname)" = MINGW* ]]
    then py=venv/Scripts/python
    else py=venv/bin/python3
fi

export WATSON_DIR=$PWD

if [ $# != 0 ]; then exec "$py" -mwatson "$@"; fi

prev_i=''

readonly cmd_startup_report=(report -Gac)
if [ "$LWATS_STARTUP_REPORT" = true ]; then
    echo "Startup report (${cmd_startup_report[*]}):"

    prev_i=${cmd_startup_report[*]}
    history -s -- "${cmd_startup_report[*]}"
    "$py" -mwatson "${cmd_startup_report[@]}" || :
fi

while read -rep 'lwats> ' i; do
    tput cuu1; tput el; echo "$(date +%H:%M:%S)> $i"

    if [ -z "$i" ]; then continue; fi
    if [ "$i" = exit ] || [ "$i" = quit ]; then break; fi

    if [ "$i" != "$prev_i" ]; then prev_i=$i; history -s -- "$i"; fi

    echo "$i" | xargs "$py" -mwatson || :
done
