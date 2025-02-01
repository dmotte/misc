# win-ssh-x11-fwd

This guide explains how to do **X11 Forwarding** with **OpenSSH** on **Windows 10** using [**VcXsrv**](https://github.com/marchaesen/vcxsrv).

> **Note**: before starting, make sure that [`X11Forwarding`](https://man.openbsd.org/sshd_config#X11Forwarding) is enabled and `xauth` is installed on the SSH server you want to connect to.

First of all, you need to install **VcXsrv**. Example with the [**Chocolatey**](https://chocolatey.org/) package manager:

```bash
sudo choco install -y vcxsrv
```

> **Note**: the `sudo` binary here is provided by [**gsudo**](https://community.chocolatey.org/packages/gsudo) on _Windows_.

Then start the application (it should be **XLaunch** in the applications menu). After a quick configuration wizard, it will minimize to the Windows **tray bar**.

Now you can connect to an SSH server with X11 Forwarding. Open a _Git Bash_ window and type the following (adjusting the server connection parameters):

```bash
DISPLAY=127.0.0.1:0 ssh -Y myuser@192.168.0.123
```

Then, in the remote shell:

```bash
sudo apt install x11-apps
xclock
```

## Links

- [xorg - Setting up X11 forwarding over SSH on Windows 10 Subsystem for Linux - Super User](https://superuser.com/questions/1332709/setting-up-x11-forwarding-over-ssh-on-windows-10-subsystem-for-linux/1332739#1332739)
- [ssh - Problems with X11 forwarding - Super User](https://superuser.com/questions/966015/problems-with-x11-forwarding/1365234#1365234)
