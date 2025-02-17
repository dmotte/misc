#!/bin/bash

set -e

# This script can be used to create a VirtualBox VM with some predefined
# settings suitable for a headless Linux server (without GUI)

# Tested with VirtualBox v7.1.4

# Usage example:
#   ./create-vbox-vm-headless.sh -nMyVM -m2048 -d20480,102400 \
#     -fSSH,tcp,127.0.0.1,2201,,22 -fHTTP,tcp,127.0.0.1,8001,,80 -sheadless

options=$(getopt -o +n:o:D:c:m:d:i:f:s: -l name: -l os: -l desc: \
    -l cpus: -l mem: -l disks: -l iso: -l fwd: \
    -l snap-name: -l snap-desc: -l start: -- "$@")
eval "set -- $options"

name=
os=Debian_64
desc=
cpus=1
mem=1024 # MB
disks=10240 # Comma-separated values in MB
iso=
fwds=()
snap_name=
snap_desc=
start=

while :; do
    case $1 in
        -n|--name) shift; name=$1;;
        -o|--os) shift; os=$1;;
        -D|--desc) shift; desc=$1;;
        -c|--cpus) shift; cpus=$1;;
        -m|--mem) shift; mem=$1;;
        -d|--disks) shift; disks=$1;;
        -i|--iso) shift; iso=$1;;
        -f|--fwd) shift; fwds+=("$1");;
        --snap-name) shift; snap_name=$1;;
        --snap-desc) shift; snap_desc=$1;;
        -s|--start) shift; start=$1;;
        --) shift; break;;
    esac
    shift
done

[ -n "$name" ] || { echo 'The VM name cannot be empty' >&2; exit 1; }

readonly ps2mouse=${VBOX_VM_PS2MOUSE:-true}
readonly rtcuseutc=${VBOX_VM_RTCUSEUTC:-true}
readonly vram=${VBOX_VM_VRAM:-16} # MB
readonly disable_audio=${VBOX_VM_DISABLE_AUDIO:-true}
readonly disable_usb=${VBOX_VM_DISABLE_USB:-true}
readonly disable_mini_toolbar=${VBOX_VM_DISABLE_MINI_TOOLBAR:-false}

################################################################################

vbox_sysprops=$(vboxmanage list systemproperties)
vbox_machinefolder=$(echo "$vbox_sysprops" |
    sed -En 's/^Default machine folder:\s+(.+)$/\1/p')

################################################################################

echo "Creating VM $name"

# The --default option applies a default hardware configuration for the
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

[ "$disable_audio" = true ] && vboxmanage modifyvm "$name" --audio-enabled off

[ "$disable_usb" = true ] && vboxmanage modifyvm "$name" --usb{,-{e,o,x}hci}=off

vboxmanage modifyvm "$name" --nic1 nat

for i in "${fwds[@]}"; do vboxmanage modifyvm "$name" --natpf1 "$i"; done

[ "$disable_mini_toolbar" = true ] &&
    vboxmanage setextradata "$name" GUI/ShowMiniToolBar false

################################################################################

i=0
while read -r size; do
    str_i=$(printf "%02d" "$i")
    virtdisk=$vbox_machinefolder/$name/disk$str_i.vdi

    echo "Creating virtual disk file $virtdisk (size $size MB)"
    vboxmanage createmedium disk --filename "$virtdisk" --size "$size"

    echo "Mounting virtual disk file $virtdisk into VM $name"
    # The device number (--device) must always be 0 if using the SATA
    # controller, because it only allows one device per port
    vboxmanage storageattach "$name" --storagectl SATA \
        --port "$i" --device 0 --type hdd --medium "$virtdisk"

    ((i+=1))
done < <(echo "$disks" | tr , '\n')

if [ -n "$iso" ]; then
    echo "Mounting ISO file $iso into VM $name"
    # IDE device on channel Primary (--port 0) Master (--device 0)
    vboxmanage storageattach "$name" --storagectl IDE \
        --port 0 --device 0 --type dvddrive --medium "$iso"
fi

################################################################################

if [ -n "$snap_name" ]; then
    echo "Taking snapshot $snap_name"
    vboxmanage snapshot "$name" take "$snap_name" --description "$snap_desc"
fi

################################################################################

if [ -n "$start" ]; then
    echo "Starting VM $name (type $start)"
    vboxmanage startvm "$name" --type "$start"
fi
