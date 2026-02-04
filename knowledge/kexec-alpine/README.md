# kexec-alpine

`kexec` is a Linux **system call** that allows you to load and **boot another kernel** from the currently running one.

In this guide we will see how to boot **Alpine Linux** with `kexec` from **Debian 13** (_trixie_).

:warning: **Warning**: **do NOT try this on your main system**! Use a virtual machine or a disposable test system instead. Your system can become **unbootable** if something goes wrong. I am **NOT responsible** for any data loss, system breakage, or any other damage that may result from following this guide.

Download the **Alpine Linux ISO file**. In my case I chose the `virt` flavor because I'm testing in a _VirtualBox_ VM. Then **mount** it:

```bash
sudo mkdir -v /mnt/myiso
sudo mount -rv alpine-virt-3.22.1-x86_64.iso /mnt/myiso
```

Copy the **`boot` and `apks` directories** from the ISO to a filesystem that will be **directly accessible** by the new kernel at boot time, i.e. that does not depend on LVM, encryption, or other userspace setup.

In my case the root filesystem (`/`) is a plain `ext4` partition, so copying to `/` works fine for me, but your setup may be different. For example, if you use LVM for `/` and have a dedicated `/boot` partition, you could copy to `/boot` instead.

```bash
sudo cp /mnt/myiso/{boot,apks} -Rivt/
```

Make sure you have the `kexec` command available on your system:

```bash
sudo apt update && sudo apt install -y kexec-tools
```

Then run the following:

```bash
sudo kexec -l /mnt/myiso/boot/vmlinuz-virt --initrd=/mnt/myiso/boot/initramfs-virt

sudo systemctl kexec
```

At this point, _Alpine Linux_ should start.

Note that, if you want it **running completely from RAM** now, you should stop all the services that may use the disk, such as `modloop`:

```bash
rc-service modloop stop
```

To check that no disk is used anymore, you can use the `mount` and `df -h` commands.

At this point you can do whatever you want with the disks, such as installing another OS:

> :warning: **Warning**: the following example `dd` commands overwrite EVERYTHING on `/dev/sda`! Unrecoverable **data loss** will occur.

```bash
curl -fsSL https://cloud.debian.org/images/cloud/trixie/latest/debian-13-nocloud-amd64.raw | dd of=/dev/sda bs=1M status=progress oflag=direct
```

> **Note**: the `curl` command and\or `dd`'s `status=progress` option might be unavailable by default on _Alpine Linux_.

Or even writing a **netboot installer ISO** to the main disk, so that you can perform a regular guided installation at reboot:

```bash
curl -fsSL https://deb.debian.org/debian/dists/trixie/main/installer-amd64/current/images/netboot/mini.iso | dd of=/dev/sda bs=1M status=progress oflag=direct
reboot
```

## Links

- [kexec(8) - kexec-tools - Debian trixie - Debian Manpages](https://manpages.debian.org/trixie/kexec-tools/kexec.8.en.html)
- [Installing Debian via the Internet](https://www.debian.org/distrib/netinst)
