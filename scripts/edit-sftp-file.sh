#!/bin/bash

set -e

# This script can be used to quickly edit a remote text file on an SFTP server

# Usage example:
#   bash edit-sftp-file.sh user@127.0.0.1:myfile.txt scp -P2022

editor=${EDITOR:-}

[ -n "$editor" ] || for i in nano vi vim; do
    tmp_command=$(command -v "$i") && { editor=$tmp_command; break; }
done

[ -n "$editor" ] || { echo 'Cannot find a valid text editor' >&2; exit 1; }

readonly scp_remote_file=${1:?} scp_app=${2:?}; shift 2
scp_args=("$@")

################################################################################

tmpdir=$(mktemp -d --tmpdir edit-sftp-file-XXXXXXXXXX)
trap 'rm -rf $tmpdir' EXIT

readonly scp_local_file=$tmpdir/tmp-file

echo "Downloading file to $scp_local_file"
"$scp_app" "${scp_args[@]}" "$scp_remote_file" "$scp_local_file"

lastmod=$(date -r "$scp_local_file" +%s.%N)

"$editor" "$scp_local_file"

if [ "$(date -r "$scp_local_file" +%s.%N)" = "$lastmod" ]; then
    echo 'File unchanged. Skipping upload'
else
    echo 'Uploading file'
    "$scp_app" "${scp_args[@]}" "$scp_local_file" "$scp_remote_file"
fi
