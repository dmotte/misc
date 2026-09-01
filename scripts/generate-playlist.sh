#!/bin/bash

set -e

# Script to generate an M3U playlist

# Usage example:
#   time GENPL_TITLE='My Playlist' bash generate-playlist.sh mymusic/*.mp3 > myplaylist.m3u; echo $?
#   time GENPL_PATHS_PREFIX=file:// bash generate-playlist.sh ~/mymusic/*.mp3 > myplaylist.m3u; echo $?
#   time cygpath -m ~/mymusic/*.mp3 | GENPL_PATHS_PREFIX=file:/// xargs -rd\\n bash generate-playlist.sh > myplaylist.m3u; echo $?

readonly header=${GENPL_HEADER:-true}
readonly title=$GENPL_TITLE
readonly paths_prefix=$GENPL_PATHS_PREFIX

################################################################################

if [ "$header" = true ]; then echo '#EXTM3U'; fi

[ -z "$title" ] || echo "#PLAYLIST:$title"

for arg; do
    bn=${arg##*/}
    echo "#EXTINF:0,${bn%.*}"
    echo "$paths_prefix$arg"
done
