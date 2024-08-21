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
- `git diff --cached > my.patch`, `git apply my.patch`
- `git clean -dfnX`
- `git remote set-url origin git@github.com:octocat/hello-world.git`
- `grep -IRi --exclude-dir=.git pattern`
- `type python3`
- `tar -cvzf archive.tar.gz folder/`, `tar -xvzf archive.tar.gz`
- `curl -fLO https://...`, `curl -fLo target.zip https://...`
- `curl -I https://example.com/`, `curl -i https://example.com/`
- `top` and then press `xcV`. Then `W` to save the config
- `cd "$(dirname "$0")"` useful in a _Bash_ script
- `sudo blkid`
- `ffmpeg -i input.mp4 -ss 97 -t 10 output.mp4`
- `ffmpeg -i input.jpg -vf 'scale=iw*1/2:ih*1/2' output.jpg`
- `( ow=640; oh=360; ffmpeg -i input.mp4 -vf "scale=$ow:$oh:force_original_aspect_ratio=decrease,pad=$ow:$oh:(ow-iw)/2:(oh-ih)/2" output.mp4 )`
- `for i in *.mp3; do echo "$i"; ffmpeg -i "$i" -af volumedetect -vn -sn -dn -f null /dev/null 2>&1 | grep -E '^\[Parsed_volumedetect.+_volume: .+$'; done`
- `ffmpeg -i input.mp3 -filter:a 'dynaudnorm=p=0.9:s=5' output.mp3`
- `watch -n.2 date`
- `scp myfile.txt user@hostname:/home/user/myfile.txt`
- `ipfs daemon &`, `jobs`, `fg 1`, `kill %1`
- `nohup mycommand &`, `pgrep mycommand`, `pkill mycommand`
- `find -printf '%p %s %T@\n'`
- `rclone lsf -R --format=pst myremote: | LC_ALL=C sort`
- `tree -paugh`
- `find | grep -i pattern`
- `cp -Rv /media/sourcedisk/folder /media/destdisk`
- `ss -tulpn`
- `df -h`
- `du -sh`
- `zip -r archive.zip folder/`
- `date -ur myfile.txt +%Y-%m-%d-%H%M%S`, `date +%s`, `date +%s.%N`
- `less myfile.txt`
- `last`, `lastb`, `lastlog`
- `read -rsp 'Password: ' MYPASSWORD && export MYPASSWORD`
- `diff <(ls -l) <(ls -la)`
- `ps -aux --sort -pcpu | head -10`
- `export SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh`
- `python3 -mhttp.server`
- `sleep infinity`
- `dig @ns1.example.com www.example.com`
- `git pull --no-edit && git add . && { git commit "-m$(date +%s)" || :; } && git push`
- `find -type d -name .git | while read -r i; do echo "${i:0:-5}"; done`
- `git describe --tags --exact-match`, `git describe --tags --dirty`
- `[ -z "$(git status -s)" ]`
- `git log --follow --format=%H myfile.txt | while read -r i; do echo -n "$i,$(git show -s --format=%aI "$i"),"; grep -ci 'mypattern' <(git show "$i:./myfile.txt"); done`
- `ssh-keygen -t ed25519 -C mydevice -f ~/.ssh/id_ed25519`, `ssh-keygen -t rsa -b 4096 -C mydevice -f ~/.ssh/id_rsa`
- `ansible-playbook -Kk -i hosts.yml playbook.yml -t tags --list-tasks`
- `withprefix() { while read -r i; do echo "$1$i"; done }`
- `echo Message | mail -s Subject recipient@example.com`
- `iostat -o JSON`
- `S_COLORS=always watch -d -n.5 --color iostat`
- `systemctl -a | grep -Fi myunit` (`-a` = also dead ones), `systemctl list-unit-files | grep -Fi myunit` (also disabled ones)
- `systemctl list-timers`
- `: "${myvar:=myvalue}"`, `export MY_ENV_VAR="${MY_ENV_VAR:-myvalue}"`
- `ssh-keygen -R [myserver.example.com]:2222`
- `socat - TCP:example.com:80`
- `socat UNIX-LISTEN:/tmp/my.sock,mode=777,fork -`, `date | socat - UNIX-CONNECT:/tmp/my.sock`
- `export XDG_RUNTIME_DIR=/run/user/$UID` to use `systemctl --user` as a linger-enabled user
- `nano -\$v filename`, `vim -R filename`
- `while read -r i; do vboxmanage controlvm myvm keyboardputstring "$i"; vboxmanage controlvm myvm keyboardputscancode 1C 9C; done`
- `ssh-keygen -lf <(cat /etc/ssh/ssh_host_*_key.pub)`
- `echo 'Hello $USER!' | envsubst`
- `sudo tcpdump -wfile.pcap`, `termshark -rfile.pcap`
- `bash <(curl -fsSL https://sh.rustup.rs/) -y && . ~/.cargo/env`, `rustup update`, `cargo install rust-script`
- `export RUSTUP_HOME=~/my-portable-rust/rustup CARGO_HOME=~/my-portable-rust/cargo`, `bash <(curl -fsSL https://sh.rustup.rs/) -y --no-modify-path`, `~/my-portable-rust/cargo/bin/cargo run`
- `mkfifo mypipe; while :; do date | tee mypipe; done`
- `date | curl -sSXPOST "https://api.telegram.org/bot${1#bot}/sendMessage" -dchat_id="$2" --data-urlencode text@- --fail-with-body -w'\n'`
- `for i in 192.168.1.1{01..19}; do ping "$i" & done | grep -i 'bytes from .*: icmp_seq='`
- `find . -iname \*.mp3 -printf '%P\n' | { echo '#EXTM3U'; while read -r i; do echo "#EXTINF:0,$(basename "${i%.*}")"; echo "file://$HOME/Music/$i"; done; }`
- `for i in var_01 VAR_02; do read -rsp "$i: " "${i?}"; if [[ "$i" = [[:upper:]]* ]]; then export "${i?}"; fi; done`
- `shuf -en1 Alice Bob Carl`, `shuf -i1-10 -n1`
- `tr -cd '0-9A-Za-z' < /dev/random | head -c64; echo`, `tr -cd '0-9a-f' < /dev/random | for i in {1..10}; do head -c8; echo; done | LC_ALL=C sort -u | shuf`
- `myvar=$'string \\ with\nsome\nspecial \'chars\' to "escape"'; echo "${myvar@Q}"`
- `find . -iname \*.mp3 -printf '%P\n' | while read -r i; do [[ "$i" =~ ^[0-9A-Za-z\ .\(\)\'/_+-]+$ ]] || echo "$i"; done`
- `venv/bin/python3 -mpip install -U --progress-bar=off -r requirements.txt`
- `escape_if_any() { echo "${1:+${1@Q}}"; }`
- `arr=(one two three); echo "${arr[@]@Q}"; echo "${arr[*]@Q}"`
- `vlc -vvv -Idummy --no-audio screen:// --screen-fps=10 --sout='#transcode{vcodec=MJPG,scale=0.5}:standard{access=http,mux=mpjpeg,dst=:8080/}' --sout-http-mime='multipart/x-mixed-replace;boundary=--7b3cc56e5f51db803f790dad720ed50a' --live-caching=100`
- `modprobe -r mymod01 mymod02`, `echo -e 'blacklist mymod01\nblacklist mymod02' > /etc/modprobe.d/blacklist-mymod.conf`
- `bind -x '"\e": mycommand'`
- `sudo iptables -nvL`
- `curl https://api.ipify.org/`
- `socat TCP4-LISTEN:9000,fork,reuseaddr - >/dev/null`, `dd if=/dev/zero bs=1M count=1024 status=progress | socat - TCP:192.168.0.2:9000`
- `curl -fLo ~/.local/bin/kubectl "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x ~/.local/bin/kubectl`
- `sudo dd if=/dev/mmcblk2 status=progress | gzip -c | split -b4GB - mmcblk2.img.gz.part`
  - `md5sum mmcblk2.img.gz.part* > MD5SUMS`
  - `cat mmcblk2.img.gz.part* | gunzip -c | sudo dd of=/dev/mmcblk2 status=progress`

```bash
install -m600 <(echo 'ACTION=="add", SUBSYSTEM=="pci",' \
    'ATTR{vendor}=="0x1234", ATTR{device}=="0x5678", ATTR{remove}="1"') \
    /etc/udev/rules.d/99-disable-pci-example.rules
udevadm trigger -vcadd -spci -avendor=0x1234 -adevice=0x5678
install -m600 <(echo 'ACTION=="add", SUBSYSTEM=="usb",' \
    'ATTR{idVendor}=="1a2b", ATTR{idProduct}=="3c4d", ATTR{remove}="1"') \
    /etc/udev/rules.d/99-disable-usb-example.rules
udevadm trigger -vcadd -susb -aidVendor=1a2b -aidProduct=3c4d
```

```bash
user_id=1001; user_name=myuser

loginctl enable-linger "$user_name"
for i in {10..1}; do
    [ -e "/run/user/$user_id/systemd/private" ] && break
    echo "Waiting for systemd user session to initialize (max ${i}s)"
    sleep 1
done
[ -e "/run/user/$user_id/systemd/private" ] ||
    { echo 'Timeout waiting for systemd user session' >&2; exit 1; }
```

## Shell snippets for Docker

- `docker ps -a --format {{.Names}}`
- `docker rm -fv mycontainer`
- `docker run --rm -v myvolume:/v --log-driver=none docker.io/library/busybox tar -cvzC/v . > mybackup.tar.gz`
- `docker run --rm -v myvolume:/v -i docker.io/library/busybox tar -xvzC/v < mybackup.tar.gz`
- `docker create --name=tmp01 docker.io/library/busybox`
  - `docker cp tmp01:/bin - | gzip > mybin.tar.gz`
  - `docker cp tmp01:/bin/sh - | tar -xv`
  - `docker rm -v tmp01`
- `docker run -it --rm -p8080:8080 -v "$PWD:/v" php:8 -S '0.0.0.0:8080' -t /v`
- `docker run --rm -v "$PWD:/v" -u "$(id -u):$(id -g)" ghcr.io/plantuml/plantuml -tsvg /v`

```bash
docker build -t img-sshsrv01:latest - << 'EOF'
FROM docker.io/library/debian:12
RUN apt-get update && \
    apt-get install -y sudo openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/sshd
# Warning: leaving the generated host keys in place!
EXPOSE 22
RUN useradd -UGsudo -ms/bin/bash mainuser && \
    echo 'mainuser ALL=(ALL) NOPASSWD: ALL' | \
        install -m440 /dev/stdin /etc/sudoers.d/mainuser-nopassword && \
    echo mainuser:changeme | chpasswd # Warning: very bad password!
ENTRYPOINT ["/usr/sbin/sshd", "-De"]
EOF

docker run -d --name=sshsrv01 -p2222:22 img-sshsrv01:latest
```

```bash
docker build -t img-unpriv01:latest - << 'EOF'
FROM docker.io/library/debian:12
RUN apt-get update && \
    apt-get install -y sudo \
        git nano tmux tree wget zip curl socat procps jq \
        iputils-ping iproute2 && \
    rm -rf /var/lib/apt/lists/*
RUN useradd -UGsudo -ms/bin/bash mainuser && \
    echo 'mainuser ALL=(ALL) NOPASSWD: ALL' | \
        install -m440 /dev/stdin /etc/sudoers.d/mainuser-nopassword && \
    echo mainuser:changeme | chpasswd # Warning: very bad password!
USER mainuser
ENV USER=mainuser HOME=/home/mainuser
WORKDIR /home/mainuser
EOF

docker run -d --name=unpriv01 img-unpriv01:latest sleep infinity
```

## Shell snippets for Podman

- `sudo XDG_RUNTIME_DIR=/run/user/1001 -iu myuser`
- `podman ps -ap`
- `systemctl --user status podman-kube@$(systemd-escape ~/kube.yaml)`
- `journalctl --user -u podman-kube@$(systemd-escape ~/kube.yaml)`
- `ls -la ~/.local/share/containers/storage/volumes`
- `(read -rsp 'Password: ' && echo -e "{\"main\":\"$(echo -n "$REPLY" | base64 -w0)\"}") | podman secret create mypassword -`
- `echo -e "{\"main\":\"$(base64 -w0 < mykey.pem)\"}" | podman secret create mykey -`
- `podman image ls -a`, `podman image prune -af`

## Shell snippets for Kubernetes

- `kubectl get all -A`, `kubectl get pod -owide`, `kubectl get pod -w`
- `kubectl run mypod --image=docker.io/library/debian:12 sleep infinity`
- `kubectl exec -it mypod -- bash`
- `kubectl delete pod/mypod`
- `kubectl config current-context`, `kubectl config use-context mycontext`
- `kubectl --context=mycontext -n mynamespace get pod`
- `kubectl port-forward pod/mypod '8080:80'`
- `kubectl get secret/mysecret -ojsonpath={.data.password} | base64 -d; echo`
- `kubectl cordon mynode`, `kubectl drain --ignore-daemonsets --delete-emptydir-data mynode`
- `kubectl rollout restart sts/mysts`
- `time kubectl api-resources --verbs=list -oname | xargs -n1 kubectl get -A -owide --show-kind --ignore-not-found`
- `helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update`
- `helm --kube-context=mycontext -n mynamespace list`

```bash
kubectl apply -f- << 'EOF'
---
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: main
      image: docker.io/library/debian:12
      args: [sleep, infinity]
      volumeMounts: [{ mountPath: /v, name: v, readOnly: true }]
  volumes:
    - name: v
      persistentVolumeClaim: { claimName: mypvc, readOnly: true }
EOF
```

## Git Bash (Windows)

- `export MSYS_NO_PATHCONV=1`
- `winpty rclone ncdu .`
- `choco list --local-only`
- `sudo choco upgrade -y all`
- `sudo choco install -y rclone winfsp && rclone mount myremote: X:`
- `[[ "$(uname)" = MINGW* ]]; echo $?`

## Prometheus queries

- `abs(mymetric - mymetric offset 1m)`
