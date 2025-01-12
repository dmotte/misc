#!/bin/bash

set -e

# This script can be used to create a VirtualBox VM with some predefined
# settings suitable for a headless Linux server (without GUI)

# Tested on VirtualBox v7.1.4

# Usage example: ./create-vbox-vm-headless.sh -nMyVM -m2048 -d20480,102400

options=$(getopt -o +n:o:D:c:m:d:i:s -l name: -l os: -l desc: -l cpus: \
    -l mem: -l disks: -l iso: -l start -- "$@")
eval "set -- $options"

name=
os=Debian_64
desc=
cpus=1
mem=1024 # MB
disks=10240 # Comma-separated values in MB
iso=
start=n

while :; do
    case $1 in
        -n|--name) shift; name=$1;;
        -o|--os) shift; os=$1;;
        -D|--desc) shift; desc=$1;;
        -c|--cpus) shift; cpus=$1;;
        -m|--mem) shift; mem=$1;;
        -d|--disks) shift; disks=$1;;
        -i|--iso) shift; iso=$1;;
        -s|--start) start=y;;
        --) shift; break;;
    esac
    shift
done

[ -n "$name" ] || { echo 'The VM name cannot be empty' >&2; exit 1; }

readonly rtcuseutc=${VBOX_VM_HEADLESS_RTCUSEUTC:-true}
# TODO other env vars

################################################################################

vbox_sysprops=$(vboxmanage list systemproperties)
vbox_machinefolder=$(echo "$vbox_sysprops" |
    sed -En 's/^Default machine folder:\s+(.+)$/\1/p')

################################################################################

echo "Creating VM $name"

echo TODO vboxmanage createvm --name "$name" --ostype "$os" --register --default

echo "Configuring VM $name settings"

echo TODO

################################################################################

if [ "$start" = y ]; then
    echo "Starting VM $name"
    echo TODO
fi
