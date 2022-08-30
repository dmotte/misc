# useful-commands

Some commands I want to remember for some reason.

## Linux

- `tmux new-session -As main`
- `tmux setw -g mouse on`
- `eval $(ssh-agent)`, `ssh-add -t 1800` (30 minutes), `eval $(ssh-agent -k)`
- `git log --graph --oneline`
- `git fsck`
- `git clone ... --depth 1`
- `git diff --no-index dir1/ dir2/`
- `grep -IRi --exclude-dir=.git pattern`
- `type python3`
- `tar -cvzf archive.tar.gz folder/`, `tar -xvzf archive.tar.gz`
- `curl -LO https://...`, `curl -Lo target.zip https://...`
- `top` and then press `xcV`. Then `W` to save the config
- `cd "$(dirname "$0")"` useful in a _Bash_ script
- `export $(grep -e '^[^#]' secret.env | tr -d '\r' | xargs)` parses a `.env` (_dotenv_) file in _Bash_ ignoring comments and handling newlines properly
- `sudo blkid`
- `ffmpeg -ss 97 -i input.mp4 -t 10 output.mp4`
- `watch -n.2 date`
- `scp myfile.txt user@hostname:/home/user/myfile.txt`
- `ipfs daemon &`, `jobs`, `fg 1`, `kill %1`
- `nohup mycommand &`, `pgrep mycommand`, `pkill mycommand`
- `find -printf "%p %s %T@\n"`
- `rclone lsf -R --format pst myremote: | LC_ALL=C sort`
- `tree -paugh`
- `find | grep -i pattern`
- `cp -Rv /media/sorcedisk/folder /media/destdisk`
- `ss -tl`
- `df -h`
- `du -sh`
- `zip -r archive.zip folder/`
- `echo $(date +%Y-%m-%d-%H%M%S)`
- `less myfile.txt`
- `last`, `lastb`, `lastlog`
- `read -p "Password: " -s MYPASSWORD && export MYPASSWORD`
- `diff <(ls -l) <(ls -la)`
- `docker ps -a --format {{.Names}}`
- `ps -aux --sort -pcpu | head -10`
- `export SSH_AUTH_SOCK="$(echo /run/user/*/keyring/ssh)"`
- `docker run -v my-volume:/volume --rm --log-driver none loomchild/volume-backup backup - > my-backup.tar.gz`
- `docker run -i -v my-volume:/volume --rm loomchild/volume-backup restore - < my-backup.tar.gz`
- `python3 -m http.server`
- `sleep infinity`

## Git Bash on Windows

- `export MSYS_NO_PATHCONV=1`
- `winpty rclone ncdu .`
- `wsl -e ansible-playbook -Kk -i hosts.yml playbook.yml -l hostname -t tags --list-tasks`
- `choco list --local-only`
- `sudo choco upgrade -y all`
- `sudo choco install -y rclone winfsp && rclone mount myremote: X:`
