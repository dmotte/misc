# useful-commands

Some commands I want to remember for some reason.

## Linux

- `tmux new-session -As main`
- `tmux setw -g mouse on`
- `eval $(ssh-agent)`, `ssh-add -t 1800` (30 minutes), `eval $(ssh-agent -k)`
- `git log --graph --oneline`
- `grep -IRi --exclude-dir=.git pattern`
- `type python3`
- `tar -cvzf archive.tar.gz folder/`, `tar -xvzf archive.tar.gz`
- `curl -o target.zip https://...`
- `top` and then press `xcV`. Then `W` to save the config
- `cd "$(dirname "$0")"` useful in a _Bash_ script

## Git Bash on Windows

- `export MSYS_NO_PATHCONV=1`
- `winpty rclone ncdu .`
- `wsl -e ansible-playbook -Kk -i hosts.yml playbook.yml -l hostname -t tags --list-tasks`
