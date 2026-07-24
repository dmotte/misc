# sshset

This is a simple Bash script [`sshset.sh`](sshset.sh) that can be used to set up stuff needed for **OpenSSH Server and Client** (such as configuration files, keys, etc.) starting from a (configurable) **data directory** and some **environment variables**.

:warning: **Warning**: this tool assumes the data directory and the environment variables are **trusted**! It is NOT suitable for use in environments with untrusted input.

Supported content of the **data directory** when running as **`root`**:

| Path                       | Category | Files extensions                           | Configures                               |
| -------------------------- | -------- | ------------------------------------------ | ---------------------------------------- |
| `sshd-config/`             | Server   | `*.conf` (suggestion)                      | `/etc/ssh/sshd_config.d/`                |
| `host-keys/`               | Server   | private keys: _none_, public keys: `*.pub` | Host keys in `/etc/ssh/`                 |
| `sshrc/`                   | Server   | `*.sh` (suggestion)                        | `/etc/ssh/sshrc`                         |
| `ssh-config/`              | Client   | `*.conf` (suggestion)                      | `/etc/ssh/ssh_config.d/`                 |
| `known-hosts/`             | Client   | `*.txt` (suggestion)                       | `/etc/ssh/ssh_known_hosts`               |
| `users/*/authorized-keys/` | Server   | private keys: _none_, public keys: `*.pub` | `~/.ssh/authorized_keys` for each user   |
| `users/*/sshrc/`           | Server   | `*.sh` (suggestion)                        | `~/.ssh/rc` for each user                |
| `users/*/ssh-config/`      | Client   | `*.conf` (suggestion)                      | `~/.ssh/config` for each user            |
| `users/*/known-hosts/`     | Client   | `*.txt` (suggestion)                       | `~/.ssh/known_hosts` for each user       |
| `users/*/identity-keys/`   | Client   | private keys: _none_, public keys: `*.pub` | Identity keys in `~/.ssh/` for each user |

> **Note**: the `/etc/ssh/ssh_config` and `/etc/ssh/sshd_config` files are not touched ad all.

Supported content of the **data directory** when running as **unprivileged user**:

| Path               | Category | Files extensions                           | Configures                 |
| ------------------ | -------- | ------------------------------------------ | -------------------------- |
| `sshd-config/`     | Server   | `*.conf` (suggestion)                      | `~/.ssh/sshd_config.d/`    |
| `host-keys/`       | Server   | private keys: _none_, public keys: `*.pub` | Host keys in `~/.ssh/`     |
| `authorized-keys/` | Server   | private keys: _none_, public keys: `*.pub` | `~/.ssh/authorized_keys`   |
| `sshrc/`           | Server   | `*.sh` (suggestion)                        | `~/.ssh/rc`                |
| `ssh-config/`      | Client   | `*.conf` (suggestion)                      | `~/.ssh/config`            |
| `known-hosts/`     | Client   | `*.txt` (suggestion)                       | `~/.ssh/known_hosts`       |
| `identity-keys/`   | Client   | private keys: _none_, public keys: `*.pub` | Identity keys in `~/.ssh/` |

> **Note**: when setting up the SSH server as unprivileged user, an `~/.ssh/sshd_config` file is created automatically, which can then be used with the `-f` option of the `sshd` command.

:bulb: **Tip**: in general, where files processing order matters, it is recommended to **prefix filenames with numbers** (e.g. `50-myfile.conf`).

For a list of the **supported environment variables**, see the top section of the script itself.

## Examples

See [`app.sh`](app.sh) and the Dockerfiles in this directory for **usage examples**. They are also useful for **development**.

To **build** the example images:

```bash
for i in {alpine,debian}-{root,unpriv}; do
    docker build -t "img-sshset-$i" -f "test-$i.Dockerfile" .
done
```

Then you can **run** them like this:

```bash
mkdir -pv data

docker run -it --rm -v"$PWD/data:/opt/sshset/data" -eSSHSET_{SETUP_{SERVER,CLIENT}=true,GEN_{HOSTKEYS,AUTHKEY,IDKEY}=true} img-sshset-debian-root
```
