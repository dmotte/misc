# TODO

Draft content of `~/.ssh` (for each user):

- `authorized_keys`
- `rc`
- `config`
- `known_hosts`
- Identity keys

Draft content of `/etc/ssh`:

- `sshd_config` + `.d/*.conf`
- Host keys
- `sshrc`
- `ssh_config` + `.d/*.conf`
- `ssh_known_hosts`

Draft content of `~/.ssh` (for each user) for unprivileged `sshd`:

- `sshd_config` + `.d/*.conf`
- Host keys

Draft content of `/opt/sshset`:

- `sshd-config/*.conf`
- `host-keys/`
- `rc/`
- `ssh-config/*.conf`
- `known-hosts/`
- `user/`
  - `authorized-keys/`
  - `rc/`
  - `config/*.conf`
  - `known-hosts/`
  - `identity-keys/`
- `users/*/`
  - Content like `user/`
  - `user.cfg` (managed by `portfwd-server`)
    - `uid=1000`
    - `gid=1000`

Take inspiration from `userngo`.
