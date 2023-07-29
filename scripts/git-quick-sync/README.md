# git-quick-sync

Simple _Bash_ script that performs the following _Git_ operations in sequence:

1. **Pull** the current branch from the remote
2. **Add** any changes to stage (relative to the working directory)
3. Make a **commit** if needed
4. **Push** the current branch to the remote

## Usage

```bash
git quick-sync [-m message] [-p]
```

See `git quick-sync --help` for more information.

Note that, for it to be found by Git, you need to install it in a directory in your `$PATH` (see [below](#installation)).

## Installation

To install or update _git-quick-sync_ you just have to execute the following commands as root:

```bash
curl -Lo "/usr/local/bin/git-quick-sync" \
    https://github.com/dmotte/git-quick-sync/releases/latest/download/git-quick-sync
chmod +x "/usr/local/bin/git-quick-sync"
```

:information_source: For **user installation** (no root needed, will only work for current user) we recommend `~/.local/bin` instead of `/usr/local/bin`. If it's not in your `$PATH`, you can add the following to your `.bashrc` or `.zshrc`:

```bash
export PATH="~/.local/bin:$PATH"
```
