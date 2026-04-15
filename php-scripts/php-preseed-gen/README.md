# php-preseed-gen

:elephant: Simple PHP script that can be used to **generate Debian Preseed** files.

Based on the [official Preseed example for Debian 13 (trixie)](https://www.debian.org/releases/trixie/example-preseed.txt) (SHA-256 checksum: `5db6b4d2662b3fb94c10f5a67a1431e8ebfe1007bdc54652a366ffbfd513a4a3`).

:warning: **Caution**: this project is **highly experimental**. **Not suitable for production use**.

## Usage

> **Important**: the generation script has been tested with **PHP 8.4.16** on **Debian 13** (_trixie_). The generated configuration has been tested with `debian-13.1.0-amd64-netinst.iso` (SHA-256 checksum: `658b28e209b578fe788ec5867deebae57b6aac5fce3692bbb116bab9c65568b3`).

> **Note**: in this guide, we assume that you have two machines: a **control host** (e.g. your PC) and a **remote host** (e.g. a physical server) on which you want to install Debian using Preseed.

First of all, generate your _Debian Preseed_ configuration using the [`preseed-gen.php`](preseed-gen.php) script. Some examples:

```bash
php preseed-gen.php --country=IT --hostname=myhostname --disk=/dev/sda

curl -fsSL 'http://localhost:8080/preseed-gen.php?country=IT&hostname=myhostname&disk=/dev/sda'

curl -fsSL 'http://localhost:8080/preseed-gen.php' \
    --url-query country=IT \
    --url-query hostname=myhostname \
    --url-query password=changeme \
    --url-query disk=/dev/sda \
    --url-query tasksel=ssh-server \
    --url-query pkgs=python3 \
    --url-query sshd-port=2222 \
    --url-query sudo-nopasswd=true \
    --url-query ssh-authkeys='ssh-ed25519 AAAAC3Nza...'
```

Double-check the generated content. Then put it into a text file, name it `preseed.cfg`, and place it into some directory on your control host (e.g. `my-preseed-dir`) as **the only file**, as we're gonna serve that directory over HTTP in a while.

Download the **Debian `netinst` ISO file** from https://www.debian.org/ and flash it onto a **USB pendrive** (you can use [Rufus](https://rufus.ie/en/) for that).

Insert the USB stick into the remote host, power it on and **boot from the pendrive**.

In the Debian installation image boot screen, you can select `Advanced options` &rarr; `Automated install` from the menu to perform the OS setup using a **Debian Preseed** file.

One of the easiest ways to serve the **Preseed** file is to use an **HTTP server** on your control host. To do this with _Python 3_ you can do something like this:

```bash
python3 -mhttp.server -dmy-preseed-dir -b0.0.0.0
```

Once the installation procedure is finished, the device will shut down on its own (it won't restart).

If needed, turn on the device again and change the main user's password immediately (you can use the `passwd` command).
