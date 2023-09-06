# useful-commands

Some commands I want to remember for some reason.

## Linux

- `tmux new-session -As0`
- `tmux setw -g mouse on`
- `eval $(ssh-agent)`, `ssh-add -t 1800` (30 minutes), `eval $(ssh-agent -k)`
- `git log --graph --oneline`
- `git fsck`
- `git clone --depth=1 ...`
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
- `ss -tulpn`
- `df -h`
- `du -sh`
- `zip -r archive.zip folder/`
- `echo $(date +%Y-%m-%d-%H%M%S)`
- `less myfile.txt`
- `last`, `lastb`, `lastlog`
- `read -rsp "Password: " MYPASSWORD && export MYPASSWORD`
- `diff <(ls -l) <(ls -la)`
- `docker ps -a --format {{.Names}}`
- `ps -aux --sort -pcpu | head -10`
- `export SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh`
- `docker run -v my-volume:/volume --rm --log-driver none loomchild/volume-backup backup - > my-backup.tar.gz`
- `docker run -i -v my-volume:/volume --rm loomchild/volume-backup restore - < my-backup.tar.gz`
- `python3 -m http.server`
- `sleep infinity`
- `dig @ns1.example.com www.example.com`
- `git pull --no-edit && git add . && { git commit "-m$(date +%s)" || :; } && git push`
- `git checkout dev && git merge main && git push && git checkout main`
- `find -type d -name .git | while read -r i; do j="${i:0:-5}"; echo -n "### $j: "; git -C "$j" fetch && git -C "$j" status -bs; done`
- `ssh-keygen -t ed25519 -C mydevice -f ~/.ssh/id_ed25519`, `ssh-keygen -t rsa -b 4096 -C mydevice -f ~/.ssh/id_rsa`
- `ansible-playbook -Kk -i hosts.yml playbook.yml -t tags --list-tasks`
- `withprefix() { while read -r i; do echo "$1$i"; done }`
- `echo Message | mail -s Subject recipient@example.com`
- `iostat -o JSON`
- `S_COLORS=always watch -d -n.5 --color iostat`
- `systemctl -a | grep -i myunit` (`-a` = also dead ones), `systemctl list-unit-files | grep -i myunit` (also disabled ones)
- `systemctl list-timers`
- `: "${MYVAR:=myvalue}"`
- `ssh-keygen -R [myserver.example.com]:2001`
- `socat - tcp:example.com:80`
- `socat UNIX-LISTEN:/tmp/my.sock,mode=777,fork STDOUT`, `date | socat - UNIX-CONNECT:/tmp/my.sock`
- `export XDG_RUNTIME_DIR=/run/user/$UID` to use systemctl as a linger-enabled user
- `nano -\$v filename`, `vim -R filename`
- `while read -r i; do vboxmanage controlvm myvm keyboardputstring "$i"; vboxmanage controlvm myvm keyboardputscancode 1C 9C; done`
- `ssh-keygen -lf <(cat /etc/ssh/ssh_host_*_key.pub)`

## Podman

- `sudo XDG_RUNTIME_DIR=/run/user/1001 -iu myuser`
- `podman ps -ap`
- `systemctl --user status podman-kube@$(systemd-escape ~/kube.yaml)`
- `journalctl --user -u podman-kube@$(systemd-escape ~/kube.yaml)`
- `ls -la ~/.local/share/containers/storage/volumes`
- `(read -rsp 'Password: ' && echo -e "{\"main\":\"$(echo -n "$REPLY" | base64 -w0)\"}") | podman secret create mypassword -`
- `echo -e "{\"main\":\"$(base64 -w0 < mykey.pem)\"}" | podman secret create mykey -`

## Git Bash on Windows

- `export MSYS_NO_PATHCONV=1`
- `winpty rclone ncdu .`
- `choco list --local-only`
- `sudo choco upgrade -y all`
- `sudo choco install -y rclone winfsp && rclone mount myremote: X:`
