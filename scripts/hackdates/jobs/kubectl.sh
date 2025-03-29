#!/bin/bash

set -e

job_name=$(basename "$0")
job_name=${job_name%.sh}

v_local=$(kubectl version --client)
v_local=$(echo "$v_local" | sed -En 's/^Client Version: (.+)$/\1/p')
echo "$job_name v_local: $v_local"

v_latest=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
echo "$job_name v_latest: $v_latest"

if [ "$v_local" = "$v_latest" ]
    then echo "$job_name: versions match"
    else echo "$job_name: versions do NOT match" >&2; exit 1
fi
