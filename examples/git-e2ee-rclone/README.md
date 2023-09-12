# git-e2ee-rclone

In this example we'll set up an **end-to-end encrypted** (E2EE) **Git remote** with **Rclone**. It will be accessible via the **WebDAV** protocol.

> **Note**: we cannot use [`rclone serve sftp`](https://rclone.org/commands/rclone_serve_sftp/) for this project because [Git over SSH relies on **real shell commands**](https://serverfault.com/questions/620648/does-git-server-over-ssh-requires-sftp/620649#620649), not SFTP.

First of all, download _Rclone_ if it's not already installed on your system:

```bash
curl -LO https://downloads.rclone.org/v1.63.1/rclone-v1.63.1-linux-amd64.zip
echo ca1cb4b1d9a3e45d0704aa77651b0497eacc3e415192936a5be7f7272f2c94c5 rclone-v1.63.1-linux-amd64.zip | sha256sum -c
unzip -j rclone-v1.63.1-linux-amd64.zip rclone-v1.63.1-linux-amd64/rclone
```

Then set up a new **Rclone `crypt` remote** following the official instructions (see https://rclone.org/crypt/). Hereinafter, we'll refer to it as `mycrypt`.

Create a new empty **bare Git repo** locally, and enable and run the **`post-update` hook** for it ([required for "dumb" WebDAV Git remotes](https://cets.seas.upenn.edu/answers/git-repository.html)):

```bash
git init --bare repo01.git
(cd repo01.git/hooks && cp post-update{.sample,} && ./post-update)
```

Now upload your new blank Git bare repo onto the `mycrypt` remote:

```bash
./rclone sync -v --create-empty-src-dirs ./repo01.git mycrypt:/repo01.git
```

And finally you can **serve** your end-to-end encrypted Git remote with **WebDAV**:

```bash
./rclone serve webdav -v --dir-cache-time=0 --disable-dir-list --addr=127.0.0.1:8001 --user=git --pass=changeme mycrypt:/
```

> **Warning**: this is just an example. It's considered a bad practice to specify passwords with command-line flags.

You can now clone your repo and do some Git operations to check that everything is working properly:

```bash
git clone http://git:changeme@localhost:8001/repo01.git repo01-clone
```

> **Warning**: again, this is just an example. It's considered a bad practice to specify the password directly in the Git remote URL.

## Links

- https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols#Dumb-HTTP
- https://cets.seas.upenn.edu/answers/git-repository.html
