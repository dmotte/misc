#!/bin/bash

set -e

basedir=$(dirname "$0")

if [[ "$(uname)" = MINGW* ]]
    then py=$basedir/venv/Scripts/python
    else py=$basedir/venv/bin/python3
fi
[ -e "$py" ] || { echo "Python binary $py not found" >&2; exit 1; }

[ -n "$WATSON_DIR" ] || export WATSON_DIR=$PWD
[ "$DWATS_DEBUG" = true ] && echo "WATSON_DIR: $WATSON_DIR" >&2

if [ $# != 0 ]; then exec "$py" -mwatson "$@"; fi

prev_i=''

readonly cmd_startup_report=(report -Gac)
if [ "$DWATS_STARTUP_REPORT" = true ]; then
    echo "Startup report (${cmd_startup_report[*]}):"

    prev_i=${cmd_startup_report[*]}
    history -s -- "${cmd_startup_report[*]}"
    "$py" -mwatson "${cmd_startup_report[@]}" || :
fi

while IFS= read -rep 'dwats> ' i; do
    tput cuu1; tput el; echo "$(date +%H:%M:%S)> $i"

    if [ -z "$i" ]; then continue; fi
    if [ "$i" = exit ] || [ "$i" = quit ]; then break; fi

    if [ "$i" != "$prev_i" ]; then prev_i=$i; history -s -- "$i"; fi

    echo "$i" | xargs "$py" -mwatson || :
done
