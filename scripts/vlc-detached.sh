#!/bin/bash

set -e

# This script runs VLC detached from the terminal window

# Usage example:
#   bash vlc-detached.sh ~/mymusic/*.mp3

# Usage example useful for Git Bash on Windows:
#   cygpath -w ~/mymusic/*.mp3 | xargs -rd\\n bash vlc-detached.sh

readonly vlc_win='/c/Program Files/VideoLAN/VLC/vlc.exe'

if command -v vlc >/dev/null; then
    vlc=vlc
elif [[ "$(uname)" = MINGW* ]] && [ -e "$vlc_win" ]; then
    vlc=$vlc_win
else
    echo 'VLC not found' >&2; exit 1
fi

nohup "$vlc" "$@" >/dev/null 2>&1 & disown
