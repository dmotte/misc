# proot

[PRoot](https://proot-me.github.io/) usage example.

Download a **rootfs tarball**:

```bash
curl -fLo tarball.tar.xz \
    https://github.com/termux/proot-distro/releases/download/v4.7.0/debian-bookworm-x86_64-pd-v4.7.0.tar.xz
```

Check its integrity with **SHA256**:

```bash
echo '164932ab77a0b94a8e355c9b68158a5b76d5abef89ada509488c44ff54655d61' \
    tarball.tar.xz | sha256sum -c
```

**Extract** the tarball content into a `rootfs` directory:

```bash
mkdir -p rootfs
tar -x --auto-compress -f tarball.tar.xz --recursive-unlink --preserve-permissions -C rootfs
```

> **Note**: the `mknod` errors reported by `tar` can be safely ignored

Download the **PRoot executable** file:

```bash
curl -fLO https://proot.gitlab.io/proot/bin/proot
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
        'HOME=/root' \
        'LANG=C.UTF-8' \
        'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
        "TERM=$TERM" \
        'TMPDIR=/tmp' \
        /bin/bash
```

Now you can do root stuff inside it, e.g. installing apt packages:

```bash
apt update && apt install htop
```

## Links

- https://wiki.termux.com/wiki/PRoot
- https://github.com/termux/proot-distro/blob/master/proot-distro.sh
