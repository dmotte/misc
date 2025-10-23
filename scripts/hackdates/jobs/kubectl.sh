#!/bin/bash

set -ex

v_local=$(kubectl version --client | sed -En 's/^Client Version: (.+)$/\1/p')

v_latest=$(curl -fsSL https://dl.k8s.io/release/stable.txt)

[ "$v_local" = "$v_latest" ] || { echo 'Version mismatch' >&2; exit 1; }
