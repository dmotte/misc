# TODO

Draft content of `/etc/ssh`:

- (server) `sshd_config` + `.d/*.conf`
- (server) Host keys
- (server) `sshrc`
- (client) `ssh_config` + `.d/*.conf`
- (client) `ssh_known_hosts`

Draft content of `~/.ssh` for unprivileged `sshd`:

- (server) `sshd_config` + `.d/*.conf`
  - For the `sshd_config` file: you can copy from `/etc/ssh/sshd_config` (checking SHA-256 checksum first, which BTW will be different between Alpine and Debian) and make the required changes to make it work in unprivileged mode
- (server) Host keys

Draft content of `~/.ssh` (for each user):

- (server) `authorized_keys`
- (server) `rc`
- (client) `config`
- (client) `known_hosts`
- (client) Identity keys

Supported content of the **data directory** when running as `root`:

| Path                       | Category | Files extensions                           |
| -------------------------- | -------- | ------------------------------------------ |
| `sshd-config/`             | Server   | `*.conf` (suggestion)                      |
| `host-keys/`               | Server   | private keys: _none_, public keys: `*.pub` |
| `sshrc/`                   | Server   | `*.sh` (suggestion)                        |
| `ssh-config/`              | Client   | `*.conf` (suggestion)                      |
| `known-hosts/`             | Client   | `*.txt` (suggestion)                       |
| `users/*/authorized-keys/` | Server   | private keys: _none_, public keys: `*.pub` |
| `users/*/sshrc/`           | Server   | `*.sh` (suggestion)                        |
| `users/*/ssh-config/`      | Client   | `*.conf` (suggestion)                      |
| `users/*/known-hosts/`     | Client   | `*.txt` (suggestion)                       |
| `users/*/identity-keys/`   | Client   | private keys: _none_, public keys: `*.pub` |

Supported content of the **data directory** when running as unprivileged user:

| Path               | Category | Files extensions                           |
| ------------------ | -------- | ------------------------------------------ |
| `sshd-config/`     | Server   | `*.conf` (suggestion)                      |
| `host-keys/`       | Server   | private keys: _none_, public keys: `*.pub` |
| `authorized-keys/` | Server   | private keys: _none_, public keys: `*.pub` |
| `sshrc/`           | Server   | `*.sh` (suggestion)                        |
| `ssh-config/`      | Client   | `*.conf` (suggestion)                      |
| `known-hosts/`     | Client   | `*.txt` (suggestion)                       |
| `identity-keys/`   | Client   | private keys: _none_, public keys: `*.pub` |

In README, write to see the supported env vars at the top of the scripts themselves.

Remember to test the Bash scripts thoroughly, both for Alpine and Debian.
