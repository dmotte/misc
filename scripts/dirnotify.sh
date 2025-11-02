#!/bin/bash

set -e

# This script recursively monitors a specific directory (using inotifywait) and
# notifies the user (using org.freedesktop.Notifications.Notify) when any
# change occurs in it

# Usage example: ./dirnotify.sh ~/mydir

readonly dir=${1:?}

# Src: https://github.com/dmotte/misc/tree/main/snippets
readonly events=MODIFY,ATTRIB,CLOSE_WRITE,MOVE,MOVE_SELF,CREATE,DELETE,DELETE_SELF,UNMOUNT

fdo_notify() { # Src: https://github.com/dmotte/misc/tree/main/snippets
    gdbus call --session --dest=org.freedesktop.Notifications \
        --object-path=/org/freedesktop/Notifications \
        --method=org.freedesktop.Notifications.Notify -- \
        "$1" 0 "$2" "$3" "$4" '[]' '{}' -1
}

readonly appname=${DIRNOTIFY_APPNAME:-dirnotify}
readonly icon=${DIRNOTIFY_ICON:-dialog-information}
readonly interval=${DIRNOTIFY_SLEEP:-5}

while :; do
    change=$(inotifywait -re"$events" "$dir")
    datetime=$(date)
    echo "Change detected at $datetime: $change"
    fdo_notify "$appname" "$icon" 'File system change detected' \
        "$datetime: $change"
    echo "Sleeping $interval seconds"
    sleep "$interval"
done
