# proot

[PRoot](https://proot-me.github.io/) usage example.

Download a **rootfs tarball**:

```bash
curl -LO https://github.com/termux/proot-distro/releases/download/v2.2.0/debian-x86_64-pd-v2.2.0.tar.xz
```

Check its integrity with **SHA256**:

```bash
echo 5ce7f65e089831b37d1cddeb67cfe4f3c487a507226b90535f420e13a37b9434 debian-x86_64-pd-v2.2.0.tar.xz | sha256sum -c
```

**Extract** the tarball content into a `rootfs` directory:

```bash
mkdir -p rootfs
tar -x --auto-compress -f debian-x86_64-pd-v2.2.0.tar.xz --recursive-unlink --preserve-permissions -C rootfs
```

> **Note**: the `mknod` errors reported by `tar` can be safely ignored

Download the **PRoot executable** file:

```bash
curl -LO https://proot.gitlab.io/proot/bin/proot
chmod +x proot
```

Finally, to start your **PRoot environment**, you can execute a command like the following one:

```bash
./proot \
    -k 5.4.0-faked \
    -r rootfs \
    -0 \
    -w /root \
    -b /dev \
    -b /dev/urandom:/dev/random \
    -b /proc \
    -b /proc/self/fd:/dev/fd \
    -b /proc/self/fd/0:/dev/stdin \
    -b /proc/self/fd/1:/dev/stdout \
    -b /proc/self/fd/2:/dev/stderr \
    -b /sys \
    -b /etc/host.conf \
    -b /etc/hosts \
    -b /etc/nsswitch.conf \
    -b /etc/resolv.conf \
    -b /tmp/ \
    /usr/bin/env -i \
        "HOME=/root" \
        "LANG=C.UTF-8" \
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        "TERM=$TERM" \
        "TMPDIR=/tmp" \
        /bin/bash
```

Now you can do root stuff inside it, e.g. installing apt packages:

```bash
apt update && apt install htop
```

## Links

- https://wiki.termux.com/wiki/PRoot
- https://github.com/termux/proot-distro/blob/master/proot-distro.sh
