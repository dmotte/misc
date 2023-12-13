# snippets

Some pieces of code I find useful for some reason.

## Bash

- `tmux new-session -As0`
- `tmux setw -g mouse on`
- `eval $(ssh-agent)`, `ssh-add -t 1800` (30 minutes), `eval $(ssh-agent -k)`
- `git log --graph --oneline`
- `git fsck`
- `git clone --depth=1 ...`
- `git tag v1.2.3 && git push --tags`
- `git diff --no-index dir1/ dir2/`
- `grep -IRi --exclude-dir=.git pattern`
- `type python3`
- `tar -cvzf archive.tar.gz folder/`, `tar -xvzf archive.tar.gz`
- `curl -LO https://...`, `curl -Lo target.zip https://...`
- `top` and then press `xcV`. Then `W` to save the config
- `cd "$(dirname "$0")"` useful in a _Bash_ script
- `export $(grep '^[^#]' secret.env | tr -d '\r' | xargs)` parses a `.env` (_dotenv_) file in _Bash_ ignoring comments and handling newlines properly
- `sudo blkid`
- `ffmpeg -ss 97 -i input.mp4 -t 10 output.mp4`
- `watch -n.2 date`
- `scp myfile.txt user@hostname:/home/user/myfile.txt`
- `ipfs daemon &`, `jobs`, `fg 1`, `kill %1`
- `nohup mycommand &`, `pgrep mycommand`, `pkill mycommand`
- `find -printf '%p %s %T@\n'`
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
- `read -rsp 'Password: ' MYPASSWORD && export MYPASSWORD`
- `diff <(ls -l) <(ls -la)`
- `ps -aux --sort -pcpu | head -10`
- `export SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh`
- `python3 -m http.server`
- `sleep infinity`
- `dig @ns1.example.com www.example.com`
- `git pull --no-edit && git add . && { git commit "-m$(date +%s)" || :; } && git push`
- `find -type d -name .git | while read -r i; do echo "${i:0:-5}"; done`
- `git describe --tags --exact-match`, `git describe --tags --dirty`
- `[ "$(git status -s)" == '' ]`
- `git log --follow --format=%H myfile.txt | while read -r i; do echo -n "$i,$(git show -s --format=%aI "$i"),"; grep -ci 'mypattern' <(git show "$i:./myfile.txt"); done`
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
- `echo 'Hello $USER!' | envsubst`
- `sudo tcpdump -wfile.pcap`, `termshark -rfile.pcap`
- `bash <(curl -fsSL https://sh.rustup.rs/) -y && . ~/.cargo/env`
- `mkfifo mypipe; while :; do date | tee mypipe; done`
- `date | curl -sSXPOST "https://api.telegram.org/bot${1#bot}/sendMessage" -dchat_id="$2" --data-urlencode text@- --fail-with-body -w'\n'`
- `for i in 192.168.1.1{01..19}; do ping "$i" & done | grep -i 'bytes from .*: icmp_seq='`
- `echo '#EXTM3U'; while read -r i; do echo "#EXTINF:0,$(basename "${i%.*}")"; echo "file://$HOME/Music/$i"; done`

## Shell snippets for Docker

- `docker ps -a --format {{.Names}}`
- `docker run -v my-volume:/volume --rm --log-driver none loomchild/volume-backup backup - > my-backup.tar.gz`
- `docker run -i -v my-volume:/volume --rm loomchild/volume-backup restore - < my-backup.tar.gz`
- `docker run -it --rm -p8080:8080 -v "$PWD:/pwd" php:8 -S '0.0.0.0:8080' -t /pwd`

```bash
docker build -t img-sshsrv01:latest - << 'EOF'
FROM docker.io/library/debian:12
RUN apt-get update && \
    apt-get install -y sudo openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd
# Warning: leaving the generated host keys in place!
EXPOSE 22
RUN useradd -UGsudo -ms/bin/bash mainuser && \
    bash -c 'install -m440 <(echo "mainuser ALL=(ALL) NOPASSWD: ALL") \
        /etc/sudoers.d/mainuser-nopassword' && \
    echo mainuser:changeme | chpasswd # Warning: very bad password!
ENTRYPOINT ["/usr/sbin/sshd", "-De"]
EOF

docker run -d --name=sshsrv01 -p2222:22 img-sshsrv01:latest
```

## Shell snippets for Podman

- `sudo XDG_RUNTIME_DIR=/run/user/1001 -iu myuser`
- `podman ps -ap`
- `systemctl --user status podman-kube@$(systemd-escape ~/kube.yaml)`
- `journalctl --user -u podman-kube@$(systemd-escape ~/kube.yaml)`
- `ls -la ~/.local/share/containers/storage/volumes`
- `(read -rsp 'Password: ' && echo -e "{\"main\":\"$(echo -n "$REPLY" | base64 -w0)\"}") | podman secret create mypassword -`
- `echo -e "{\"main\":\"$(base64 -w0 < mykey.pem)\"}" | podman secret create mykey -`

## Git Bash (Windows)

- `export MSYS_NO_PATHCONV=1`
- `winpty rclone ncdu .`
- `choco list --local-only`
- `sudo choco upgrade -y all`
- `sudo choco install -y rclone winfsp && rclone mount myremote: X:`

## Prometheus queries

- `abs(mymetric - mymetric offset 1m)`
