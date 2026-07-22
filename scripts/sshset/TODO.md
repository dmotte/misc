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

Draft content of `/opt/sshset/data` for when running as `root`:

- (server) `sshd-config/*.conf`
- (server) `host-keys/`
- (server) `sshrc/`
- (client) `ssh-config/*.conf`
- (client) `known-hosts/`
- `users/*/`
  - (server) `authorized-keys/`
  - (server) `sshrc/`
  - (client) `ssh-config/*.conf`
  - (client) `known-hosts/`
  - (client) `identity-keys/`

Draft content of `/opt/sshset/data` for when running as unprivileged user:

- (server) `sshd-config/*.conf`
- (server) `host-keys/`
- (server) `authorized-keys/`
- (server) `sshrc/`
- (client) `ssh-config/*.conf`
- (client) `known-hosts/`
- (client) `identity-keys/`

Take inspiration from `userngo`.

Supported env vars:

- `SSHSET_CLIENT=true`: configure SSH client (`ssh`) stuff
- `SSHSET_SERVER=true`: configure SSH server (`sshd`) stuff
- `SSHSET_GEN_AUTHKEY=true`: generate an authorized key for users that don't have any
- `SSHSET_GEN_IDKEY=true`: generate an identity key for users that don't have any

Always overwrite destination files (e.g. `/opt/sshset/data/sshrc/` &rarr; `/etc/ssh/sshrc`) on script run, as they may change from one run to another.

No need to use `userngo` in this project, I guess.

In images like `portfwd-server`, for user creation, you could add a `user.cfg` file (externally managed) for each user, with directives like `uid=1000` and `gid=1000` for example.

In README, write the suggested file extensions somehow. For example `.sh` for `sshrc/*` files, `.txt` for `known-hosts/*` files, etc.

Consider using Bash subshell functions like `myfunc() (...)`.
