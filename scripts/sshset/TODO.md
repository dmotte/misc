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

Draft content of `/opt/sshset`:

- `main.sh`
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
  - `user.cfg` (?) (for user creation) (managed externally by `portfwd-server`)
    - `uid=1000`
    - `gid=1000`

Take inspiration from `userngo`.

Supported env vars:

- `SSHSET_CLIENT=true`: configure SSH client (`ssh`) stuff
- `SSHSET_SERVER=true`: configure SSH server (`sshd`) stuff
- `SSHSET_GEN_AUTHKEY=true`: generate an authorized key for users that don't have any
- `SSHSET_GEN_IDKEY=true`: generate an identity key for users that don't have any

Always overwrite destination files (e.g. `/opt/sshset/rc/` &rarr; `/etc/ssh/sshrc`) on script run, as they may change from one run to another.

Configurable source dir (default `/opt/sshset`).

No need to use `userngo` in this project, I guess.

Use `volumes` dir for volumes.
