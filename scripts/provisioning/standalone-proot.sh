#!/bin/bash

set -e

# This script can be used to set up a standalone installation of a specific
# version of PRoot with a custom tarball in a specific directory

# Tested on Debian 12 (bookworm)

# It also works (I tested it) when run as a regular user (non-root) inside an
# unprivileged Podman container (i.e. created by a regular user on the host)

# Usage example:
#   ./standalone-proot.sh myproot --kernel-release=5.4.0-faked --cwd=/
#   myproot/main.sh uname -a

# TODO test the usage example

# Useful links:
# - https://proot-me.github.io/
# - https://wiki.termux.com/wiki/PRoot
# - https://github.com/termux/proot-distro/blob/master/proot-distro.sh

options=$(getopt -o + -l binary-url: -l binary-checksum: \
    -l tarball-url: -l tarball-checksum: -l tarball-top-dir: -- "$@")
eval "set -- $options"

binary_url=https://proot.gitlab.io/proot/bin/proot
binary_checksum=''
tarball_url=https://github.com/termux/proot-distro/releases/download/v4.7.0/debian-bookworm-x86_64-pd-v4.7.0.tar.xz
tarball_checksum=''
tarball_top_dir=debian-bookworm-x86_64

while :; do
    case $1 in
        --binary-url) shift; binary_url=$1;;
        --binary-checksum) shift; binary_checksum=$1;;
        --tarball-url) shift; tarball_url=$1;;
        --tarball-checksum) shift; tarball_checksum=$1;;
        --tarball-top-dir) shift; tarball_top_dir=$1;;
        --) shift; break;;
    esac
    shift
done

readonly install_dir=${1:?}; shift

add_options=("$@")

################################################################################

if [ -d "$install_dir" ]; then
    echo "Directory $install_dir already exists" >&2; exit 1
fi

mkdir -p "$install_dir"

readonly binary_path="$install_dir/proot"
readonly tarball_path="$install_dir/tarball.tar.xz"
readonly rootfs_path="$install_dir/rootfs"
readonly main_sh_path="$install_dir/main.sh"

echo "Downloading PRoot binary $binary_url to $binary_path"
curl -fLo "$binary_path" "$binary_url"

if [ -n "$binary_checksum" ]; then
    echo "$binary_checksum $binary_path" | sha256sum -c
fi

chmod +x "$binary_path"

echo "Downloading tarball $tarball_url to $tarball_path"
curl -fLo "$tarball_path" "$tarball_url"

if [ -n "$tarball_checksum" ]; then
    echo "$tarball_checksum $tarball_path" | sha256sum -c
fi

echo "Extracting tarball $tarball_path to $rootfs_path"
tar -x --auto-compress -f "$tarball_path" \
    --exclude="$tarball_top_dir"/{dev,proc,sys,tmp} \
    --recursive-unlink --preserve-permissions -C "$install_dir"
mv -T "$install_dir/$tarball_top_dir" "$rootfs_path"

# TODO make sure that it works well with "exec"

echo "Creating script $main_sh_path"
install -m755 /dev/stdin "$main_sh_path" << EOF
#!/bin/bash

set -e

basedir=\$(dirname "\$0")

if [ \$# = 0 ]; then set -- bash; fi

exec "\$basedir/proot" \\
    --rootfs="\$basedir/rootfs" --root-id \\
    --bind=/{dev,proc,sys,tmp} \\
    --bind=/etc/{host.conf,hosts,nsswitch.conf,resolv.conf} \\
    ${add_options[*]@Q} \\
    /usr/bin/env -i \\
        HOME=/root LANG="\$LANG" TERM="\$TERM" \\
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \\
        "\$@"
EOF
