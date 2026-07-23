# TODO

Draft content of `/etc/ssh`:

- (server) `sshd_config` + `.d/*.conf`
- (server) Host keys
- (server) `sshrc`
- (client) `ssh_config` + `.d/*.conf`
- (client) `ssh_known_hosts`

Draft content of `~/.ssh` for unprivileged `sshd`:

- (server) `sshd_config` + `.d/*.conf`
- (server) Host keys

Draft content of `~/.ssh` (for each user):

- (server) `authorized_keys`
- (server) `rc`
- (client) `config`
- (client) `known_hosts`
- (client) Identity keys

Supported content of the **data directory** when running as `root`:

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

Supported content of the **data directory** when running as unprivileged user:

| Path               | Category | Files extensions                           | Configures                 |
| ------------------ | -------- | ------------------------------------------ | -------------------------- |
| `sshd-config/`     | Server   | `*.conf` (suggestion)                      | `~/.ssh/sshd_config.d/`    |
| `host-keys/`       | Server   | private keys: _none_, public keys: `*.pub` | Host keys in `~/.ssh/`     |
| `authorized-keys/` | Server   | private keys: _none_, public keys: `*.pub` | `~/.ssh/authorized_keys`   |
| `sshrc/`           | Server   | `*.sh` (suggestion)                        | `~/.ssh/rc`                |
| `ssh-config/`      | Client   | `*.conf` (suggestion)                      | `~/.ssh/config`            |
| `known-hosts/`     | Client   | `*.txt` (suggestion)                       | `~/.ssh/known_hosts`       |
| `identity-keys/`   | Client   | private keys: _none_, public keys: `*.pub` | Identity keys in `~/.ssh/` |

In README, write to see the supported env vars at the top of the scripts themselves.

Remember to test the Bash scripts thoroughly, both for Alpine and Debian.
