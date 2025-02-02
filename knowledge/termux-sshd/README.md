# termux-sshd

You can run **OpenSSH Server** in [Termux](https://termux.dev/en/) to make it remotely controllable.

To **install** it:

```bash
pkg install openssh
```

If you want to set up **password authentication**:

```bash
passwd
```

> **Note**: the password will be stored ([hashed](https://github.com/termux/termux-auth/blob/0bb85b4faa24f4259cfd217ac1865c1b9c4ffc2a/termux-auth.c#L65-L91)) into `~/.termux_authinfo`. The `passwd` command will NOT ask you for the old one, so you can always reset it in case you forget it.

If you want to set up **public key authentication**:

```bash
echo 'ssh-ed25519 AAAAC3Nza...' >> ~/.ssh/authorized_keys
```

To be able to connect, you also need to know what is your **username** in _Termux_, and the **IP address** of your device:

```bash
whoami
ip a
```

Now you can **start the SSH server**:

```bash
sshd -De
```

You can now **connect** to it by running the following **from another host** (the default port of the SSH server in _Termux_ is **8022**):

```bash
ssh u0_a123@192.168.0.123 -p8022
```

## Links

- [Using the SSH server - Remote Access - Termux Wiki](https://wiki.termux.com/wiki/Remote_Access#Using_the_SSH_server)
