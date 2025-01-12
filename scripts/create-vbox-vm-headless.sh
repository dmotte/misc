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

readonly ps2mouse=${VBOX_VM_PS2MOUSE:-true}
readonly rtcuseutc=${VBOX_VM_RTCUSEUTC:-true}
readonly vram=${VBOX_VM_VRAM:-16} # MB

################################################################################

vbox_sysprops=$(vboxmanage list systemproperties)
vbox_machinefolder=$(echo "$vbox_sysprops" |
    sed -En 's/^Default machine folder:\s+(.+)$/\1/p')

################################################################################

alias vboxmanage='echo TODO vboxmanage'

echo "Creating VM $name"

# The "--default" option applies a default hardware configuration for the
# specified guest OS
vboxmanage createvm --name "$name" --ostype "$os" --register --default

echo "Configuring VM $name settings"

[ -z "$desc" ] || vboxmanage modifyvm "$name" --description "$desc"

vboxmanage modifyvm "$name" --memory "$mem"

# Remove "Floppy" from Boot Order
vboxmanage modifyvm "$name" --boot1 dvd --boot2 disk --boot3 none --boot4 none

[ "$ps2mouse" = true ] && vboxmanage modifyvm "$name" --mouse ps2

[ "$rtcuseutc" = true ] && vboxmanage modifyvm "$name" --rtcuseutc on

vboxmanage modifyvm "$name" --cpus "$cpus"

vboxmanage modifyvm "$name" --vram "$vram"

echo TODO "$disks" "$iso" "$vbox_machinefolder"

################################################################################

if [ "$start" = y ]; then
    echo "Starting VM $name"
    echo TODO
fi
