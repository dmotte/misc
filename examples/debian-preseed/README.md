# debian-preseed

This directory contains a [`preseed.cfg`](preseed.cfg) file, which is an example of how to use **Debian Preseed**.

It has been developed starting from the [official Preseed example for Debian Bookworm](https://www.debian.org/releases/bookworm/example-preseed.txt) (SHA256 checksum: `7d634dd7f1ec07ee4e189963d824860b648de6d0e126dd730cbfbe265dcdabcc`).

## Usage

> **Note**: in this guide, we assume that you have two machines: a **control host** (e.g. your PC) and a **remote host** (e.g. a physical server) on which you want to install Debian using Preseed.

**Customize** the [`preseed.cfg`](preseed.cfg) file and place it into some directory on your control host (e.g. `my-preseed-dir`) as **the only file**, as we're gonna serve that directory over HTTP in a while.

In particular, pay attention to the following:

- `d-i netcfg/get_hostname string ...`
- `d-i netcfg/hostname string ...`
- `d-i partman-auto/disk string ...`
- the `d-i preseed/late_command` block at the bottom, which is just an example of what can be done

Download a **Debian installation image** (e.g. `debian-12.0.0-amd64-netinst.iso`) from https://www.debian.org/ and flash it onto a **USB pendrive**. To do that you can use [Rufus](https://rufus.ie/en/).

Insert the USB stick into the remote host, power it on and **boot from the pendrive**.

In the Debian installation image boot screen, you can select `Advanced options` &rarr; `Automated install` from the menu to perform the OS setup using a **Debian Preseed** file.

One of the easiest ways to serve the **Preseed** file is to use an **HTTP server** on your control host. To do this with _Python3_ you can do something like this:

```bash
python3 -m http.server -d my-preseed-dir -b '0.0.0.0'
```

Once the installation procedure is finished, the device will shut down on its own (it won't restart) due to the `d-i debian-installer/exit/poweroff boolean true` line.

If needed, turn on the device again and change the main user's password immediately (you can use the `passwd` command).

## Notes

- The `d-i preseed/early_command string kill-all-dhcp; netcfg` line is needed to restart _netcfg_. This is needed if you are preseeding via network, otherwise the `netcfg/*` values are all ignored. See https://unix.stackexchange.com/questions/106614/preseed-cfg-ignoring-hostname-setting/342179#comment737438_342179
