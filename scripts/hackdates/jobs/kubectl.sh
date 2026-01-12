#!/bin/bash

set -e

echo 'Checking kubectl version'

text=$(kubectl version --client)
v_local=$(echo "$text" | sed -En 's/^Client Version: (.+)$/\1/p')

v_latest=$(curl -fsSL https://dl.k8s.io/release/stable.txt)

if [ "$v_local" = "$v_latest" ]
    then echo "OK ($v_local)"
    else echo "ERROR: local is $v_local but latest is $v_latest" >&2; exit 1
fi
