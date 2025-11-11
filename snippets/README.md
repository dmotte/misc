# snippets

Some pieces of code I find useful for some reason.

## Bash

- `install -DTvm600 src.txt dst.txt`, `install -Tvm700 src.sh dst.sh`
- `install -vm600 -t ~/.ssh mykey_ed25519`
- `install -omyuser -gmygroup -dvm700 mydir`, `install -dv -omyuser -gmygroup mydir`
- `tmux new-session -As0`
- `tmux setw -g mouse on`
- `eval "$(ssh-agent)"`, `ssh-add -t1800` (30 minutes), `ssh-add -l`, `eval "$(ssh-agent -k)"`
- `git init -bmain myrepo`, `git init --bare -bmain myrepo.git`
- `git log --graph --oneline`
- `git fsck --strict`
- `git clone --depth=1 ...`
- `git tag v1.2.3 && git push --tags`
- `git diff --no-index dir1/ dir2/`
- `git diff --cached > my.patch`, `git apply my.patch`
- `git diff --quiet HEAD^ HEAD -- .`
- `git clean -dfnX`
- `git remote set-url origin git@github.com:octocat/hello-world.git`
- `git config --global credential.helper "cache --timeout=$((10*365*24*60*60))"`
- `git lfs track '*.mp3'`, `git lfs ls-files`
- `reporoot=$(git rev-parse --show-toplevel)`
- `latest_commit=$(git rev-parse HEAD)`
- `grep -IRi --exclude-dir=.git pattern`
- `tig`, `tig blame myfile.txt`
- `type python3`
- `unset HISTFILE`
- `tar -cvzf myarchive.tar.gz mydir`, `tar -xvzf myarchive.tar.gz`
- `tar -cvzf myarchive.tar.gz -g snapshot.snar -C mydir .`, `tar -xvzf myarchive.tar.gz -g snapshot.snar -C mydir`
- `curl --skip-existing -fLO https://...`, `curl -fLo target.zip https://...`
- `curl -I https://example.com/`, `curl -i https://example.com/`
- `top` and then press `xcV`. Then `W` to save the config
- `cd "$(dirname "$0")"` or `basedir=$(dirname "$0")`, useful in a _Bash_ script
- `sudo blkid -sUUID -ovalue /dev/sdb1`
- `ffmpeg -i input.mp4 -ss 97 -t 10 output.mp4`
- `ffmpeg -i input.jpg -vf 'scale=iw*1/2:ih*1/2' output.jpg`
- `( ow=640; oh=360; ffmpeg -i input.mp4 -vf "scale=$ow:$oh:force_original_aspect_ratio=decrease,pad=$ow:$oh:(ow-iw)/2:(oh-ih)/2" output.mp4 )`
- `for i in *.mp3; do echo "$i"; ffmpeg -i "$i" -af volumedetect -vn -sn -dn -f null /dev/null 2>&1 | grep -E '^\[Parsed_volumedetect.+_volume: .+$'; done`
- `ffmpeg -i input.mp3 -filter:a 'dynaudnorm=p=0.9:s=5' output.mp3`
- `ffmpeg -i input.mp3 -map 0:a -c:a copy -map_metadata -1 output.mp3`
- `watch -n.2 date`, `watch -pn3 'date && sleep 2'`
- `scp myfile.txt user@hostname:/home/user/myfile.txt`
- `ipfs daemon &`, `jobs`, `fg 1`, `kill %1`
- `nohup ping localhost > myoutput.txt & disown`, `pgrep -fx 'ping localhost'`, `pkill -fx 'ping localhost'`, `nohup sleep infinity >/dev/null 2>&1 & disown`
- `pgrep -fxu"$EUID" '^python3 '"$HOME"'/myscript\.py$'`
- `find mydir -mindepth 1 -printf '%y %T@ %s %P\n' | LC_ALL=C sort -k4`
- `find mydir -type d -printf 'DIR -1 %P/\n' -o -type f -printf '%T@ %s %P\n' | LC_ALL=C sort -k3`
- `find . -type f -exec sha256sum {} +`
- `tree -paugh --inodes`
- `find . | grep -i pattern`, `find . -iname '*pattern*'`
- `find . \( \( -type d ! -perm 755 \) -o \( -type f ! -perm 644 \) \) -exec ls -dl {} +`
- `find . \( -type d -perm 775 -exec chmod 755 {} \; \) -o \( -type f -perm 664 -exec chmod 644 {} \; \)`
- `git ls-files --full-name '*pattern*'`
- `git ls-files | xargs -rd\\n sha256sum`
- `cp -Rvt/media/destdisk /media/sourcedisk/mydir`
- `ss -tulpn`
- `df -h`
- `free -htvw`
- `du -sh`
- `file -b --mime-type myfile.txt`, `xdg-mime query filetype myfile.txt`
- `stat -c%Y myfile.txt`, `stat -c%s myfile.txt`
- `zip -r myarchive.zip mydir`, `unzip -oq myarchive.zip -d mydir`
- `7z a myarchive.7z mydir`, `7z a myarchive.zip mydir`, `7z a dummy -tzip -so mydir > myarchive.zip`
- `7z e myarchive.7z mydir/myfile.txt -so`
- `7z l myarchive.7z`
- `7z x -aoa myarchive.7z`, `7z x myarchive.7z -osomedir`, `7z x myarchive.7z -o\*`
- `date -ur myfile.txt +%Y-%m-%d-%H%M%S`, `date +%s`, `date +%s.%N`, `date -Ins`
- `less myfile.txt`
- `last`, `lastb`, `lastlog`
- `read -rsp 'Password: ' MYPASSWORD && export MYPASSWORD`, `set -o ignoreeof; exit() { echo 'Use "builtin exit" to exit'; }`
- `read -rsp 'Press ENTER to continue...'; echo`
- `diff <(ls -l) <(ls -la)`
- `ps -aux --sort -pcpu | head -n10`
- `strings /proc/1234/environ | grep -i MY_ENV_VAR`
- `export SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh`
- `SSH_AUTH_SOCK= ssh myuser@192.168.0.123`
- `python3 -mhttp.server`
- `php -S 127.0.0.1:8080 -t mydir`
- `dig @ns1.example.com www.example.com`
- `git pull --no-edit && git add . && { git commit "-m$(date +%s)" || :; } && git push`
- `find . -type d -name .git | while read -r i; do echo "${i:0:-5}"; done`
- `git describe --tags --exact-match`, `git describe --tags --dirty`
- `[ -z "$(git status -s)" ]`
- `git reset --soft HEAD^ && git push --force`
- `git log --follow --format=%H myfile.txt | while read -r i; do echo -n "$i,$(git show -s --format=%aI "$i"),"; grep -ci 'mypattern' <(git show "$i:./myfile.txt"); done`
- `ssh-keygen -t ed25519 -C mydevice -f ~/.ssh/id_ed25519`, `ssh-keygen -t rsa -b 4096 -C mydevice -f ~/.ssh/id_rsa`
- `ssh-keygen -yf ~/.ssh/id_ed25519`
- `ssh-copy-id myuser@192.168.0.123`
- `ssh-keygen -R [myserver.example.com]:2222`
- `ssh-keygen -lf <(cat /etc/ssh/ssh_host_*_key.pub)`, `ssh-keygen -lF '[192.168.0.123]:2222'`
- `ansible-playbook -Kk -i hosts.yml playbook.yml -t tags --list-tasks`
- `withprefix() { while read -r i; do echo "$1$i"; done }`
- `echo Message | mail -s Subject recipient@example.com`
- `iostat -o JSON`
- `S_COLORS=always watch -dpn.5 --color iostat`
- `systemctl -a | grep -Fi myunit` (`-a` = also dead ones), `systemctl list-unit-files | grep -Fi myunit` (also disabled ones)
- `systemctl is-active -q myunit; echo $?`
- `systemctl list-timers`
- `systemd-analyze calendar '*-*-* 6,18:00' --iterations 10`
- `: "${myvar:=myvalue}"`, `export MY_ENV_VAR="${MY_ENV_VAR:-myvalue}"`
- `socat - TCP:example.com:80`
- `socat UNIX-LISTEN:/tmp/my.sock,mode=666,fork,unlink-early -`, `date | socat - UNIX-CONNECT:/tmp/my.sock`
- `export XDG_RUNTIME_DIR=/run/user/$UID` to use `systemctl --user` as a linger-enabled user
- `nano -Sav filename`, `vim -R filename`
- `nano -AEJ80 -ST4 -ailmq filename`
- `vboxmanage startvm myvm --type=headless`
- `vboxmanage controlvm myvm acpipowerbutton`
- `while read -r i; do vboxmanage controlvm myvm keyboardputstring "$i"; vboxmanage controlvm myvm keyboardputscancode 1C 9C; done`
- `vboxmanage getextradata global GUI/SuppressMessages`, `vboxmanage setextradata global GUI/SuppressMessages all`
- `echo 'Hello $USER!' | envsubst`
- `sudo tcpdump -wfile.pcap`, `termshark -rfile.pcap`
- `curl -fsSL https://sh.rustup.rs/ | RUSTUP_INIT_SH_PRINT=arch bash`
- `bash <(curl -fsSL https://sh.rustup.rs/) -y && . ~/.cargo/env`, `rustup update`, `cargo install rust-script`
- `export RUSTUP_HOME=~/my-portable-rust/rustup CARGO_HOME=~/my-portable-rust/cargo`, `bash <(curl -fsSL https://sh.rustup.rs/) -y --no-modify-path`, `~/my-portable-rust/cargo/bin/cargo run`
- `mkfifo mypipe; while :; do date | tee mypipe; done`
- `date | curl -sSXPOST "https://api.telegram.org/bot${1#bot}/sendMessage" -dchat_id="$2" --data-urlencode text@- --fail-with-body -w'\n'`
- `for i in 192.168.1.1{01..19}; do ping "$i" & done | grep -i 'bytes from .*: icmp_seq='`
- `find . -iname \*.mp3 -printf '%P\n' | ( echo '#EXTM3U'; while read -r i; do bn=${i##*/}; echo "#EXTINF:0,${bn%.*}"; echo "file://$HOME/Music/$i"; done )`
- `for i in var_01 VAR_02; do read -rsp "$i: " "${i?}"; if [[ "$i" = [[:upper:]]* ]]; then export "${i?}"; fi; done`
- `shuf -en1 Alice Bob Carl`, `shuf -i1-10 -n1`
- `tr -cd '0-9A-Za-z' < /dev/random | head -c64; echo`, `tr -cd ' -~' < /dev/random | head -c64; echo`, `tr -cd '0-9a-f' < /dev/random | for i in {1..10}; do head -c8; echo; done | LC_ALL=C sort -u | shuf`
- `myvar=$'string \\ with\nsome\nspecial \'chars\' to "escape"'; echo "${myvar@Q}"`
- `venv/bin/python3 -mpip install -U --progress-bar=off -r requirements.txt`
- `escape_if_any() { echo "${1:+${1@Q}}"; }`
- `json_min_escape() { jq -c . | jq -Rrs 'rtrimstr("\n") | @json'; }`
- `arr=(one two 'three four'); escaped_items=("${arr[@]@Q}"); echo "${escaped_items[0]}"; escaped_str="${arr[*]@Q}"; echo "$escaped_str"`
- `bash -ec 'echo "${0@Q} - ${*@Q}"' bash hey 'hello world'`
- `mapfile -t arr < <(echo 'hey "hello world"' | xargs -n1)`
- `printf '%s\n' "${arr[@]}"`
- `vlc -vvv -Idummy --no-audio screen:// --screen-fps=10 --sout='#transcode{vcodec=MJPG,scale=0.5}:standard{access=http,mux=mpjpeg,dst=:8080/}' --sout-http-mime='multipart/x-mixed-replace;boundary=--7b3cc56e5f51db803f790dad720ed50a' --live-caching=100`
- `modprobe -r mymod01 mymod02`, `printf 'blacklist %s\n' mymod01 mymod02 > /etc/modprobe.d/blacklist-mymod.conf`
- `printf 'blacklist %s\n' uas usb_storage > /etc/modprobe.d/blacklist-usb-storage.conf`
- `bind -x '"\e": mycommand'`
- `sudo iptables -nvL`
- `sudo iptables -t nat -F OUTPUT`
- `curl https://api.ipify.org/`
- `ping my.dns.domain.10-0-0-1.nip.io`, `ping my.dns.domain.lvh.me`
- `socat TCP4-LISTEN:9000,fork,reuseaddr /dev/null`, `dd if=/dev/zero bs=1M count=1024 status=progress | socat - TCP:192.168.0.2:9000`
- `curl -fLo ~/.local/bin/proot https://proot.gitlab.io/proot/bin/proot && chmod +x ~/.local/bin/proot`
- `curl -fLo ~/.local/bin/kubectl "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x ~/.local/bin/kubectl`
- `curl -fL https://get.helm.sh/helm-v3.17.2-linux-amd64.tar.gz | tar -xvz --strip-components=1 -C ~/.local/bin linux-amd64/helm`
- `curl -fL https://github.com/derailed/k9s/releases/download/v0.40.10/k9s_Linux_amd64.tar.gz | tar -xvzC ~/.local/bin k9s`
- `curl -fL https://downloads.rclone.org/rclone-current-linux-amd64.zip | bsdtar -xOf- 'rclone-*-linux-amd64/rclone' | install -Tv /dev/stdin ~/.local/bin/rclone`
- `curl -fL https://github.com/restic/restic/releases/latest/download/restic_0.18.0_linux_amd64.bz2 | bunzip2 -c | install -Tv /dev/stdin ~/.local/bin/restic`
- `curl -fLo/tmp/rustdesk.deb https://github.com/rustdesk/rustdesk/releases/download/1.4.2/rustdesk-1.4.2-x86_64.deb && sudo apt-get update && sudo apt-get install -y libegl1 /tmp/rustdesk.deb`
- `curl -fLo/tmp/rpi-imager.deb https://downloads.raspberrypi.com/imager/imager_latest_amd64.deb && sudo apt-get update && sudo apt-get install -y /tmp/rpi-imager.deb`
- `rustdesk --get-id`, `sudo rustdesk --password MyPassword1234` (while RustDesk is running)
- `sudo dd if=/dev/mmcblk2 status=progress | gzip -c | split -b4GB - mmcblk2.img.gz.part`
  - `md5sum mmcblk2.img.gz.part* > MD5SUMS`
  - `cat mmcblk2.img.gz.part* | gunzip -c | sudo dd of=/dev/mmcblk2 status=progress`
- `sudo parted /dev/sdb -s 'mklabel gpt mkpart "" 0% 100%'`, `sudo mkfs.ext4 /dev/sdb1 -L mylabel`
- `fallocate -vl1G myimage.img`
- `dd if=/dev/random of=myimage.img bs=1M count=1024 status=progress`
- `gzip -tv myfile.txt.gz`
- `dpkg -s python3`, `dpkg -l | grep -Fi pyth`
- `comm <(echo -e 'common\nonlyleft') <(echo -e 'common\nonlyright') --total`
- `sunodl() { curl -fLO https://cdn1.suno.ai/$1.mp3; }`
- `install -DTv <(echo -e '#!/bin/bash\nexec "$(realpath "$(dirname "$0")/../Scripts/python")" "$@"') venv/bin/python3`
- `shred -u myfile.txt`
- `gpg -ac --cipher-algo=AES256 --no-symkey-cache -o encrypted.asc <(date)`, `gpg -d --no-symkey-cache encrypted.asc`
- `date | gpg -ac --batch --cipher-algo=AES256 --no-symkey-cache --passphrase-file=<(echo MyPassphrase) -o encrypted.asc`, `gpg -d --batch --no-symkey-cache --passphrase=MyPassphrase encrypted.asc | sha256sum`
- `gpg --list-packets encrypted.asc`, `gpg -q --list-packets encrypted.asc >/dev/null`
- `gpgconf -v --list-options gpg-agent`
- `echo -e 'default-cache-ttl 0\nmax-cache-ttl 0' >> ~/.gnupg/gpg-agent.conf && gpgconf --reload`
- `rsync -Phavn --delete --stats ~/sourcedir/ ~/targetdir/` (trailing slashes needed!)
- `exec 3<<<mypassword; restic -r my-restic-repo -p/dev/fd/3 init; exec 3<&-`
  - `env -C myfiles restic -r "$(realpath my-restic-repo)" -p<(echo mypassword) backup -vn --skip-if-unchanged .`
  - `export RESTIC_REPOSITORY="$(realpath my-restic-repo)" RESTIC_PASSWORD=mypassword`
  - `restic snapshots`, `restic ls -l latest`, `restic check --read-data`
  - `restic restore latest --delete -vvt myfiles --dry-run`
  - `restic dump latest / -t myarchive.tar`
  - `restic -r sftp://myuser@192.168.0.123:2222//my-restic-repo snapshots`
  - `mkdir -v mymountpoint && restic mount mymountpoint`, `cat mymountpoint/snapshots/latest/myfile.txt`
  - `restic snapshots latest --json | jq -r '.[0].id'`
  - `restic diff --metadata a1b2 c3d4`
  - `GPG_TTY=$(tty) restic --password-command='gpg -dq encrypted.asc' snapshots` (to make `pinentry-curses` work)
- `RCLONE_CONFIG=rclone.conf rclone config`, `rclone config --config=rclone.conf`
- `RCLONE_CONFIG= rclone config file`, `rclone --config= config file`
- `echo -e '[mygdrive]\ntype = drive\nscope = drive\nroot_folder_id = ...' > ~/.config/rclone/rclone.conf`, `rclone config reconnect mygdrive:`
- `echo -e "[mycrypt]\ntype = crypt\nremote = mygdrive\npassword = $(echo mypass | rclone obscure -)" >> ~/.config/rclone/rclone.conf`
- `rclone lsf myremote:`
- `rclone --config= lsf -R --format=pst --time-format=RFC3339 . | sed -E 's/\/;-1;[^;]+$/\/;-1;DIR/' | LC_ALL=C sort -t\; -k1,1`
- `rclone sync -vn --create-empty-src-dirs myremote:/remote-src-dir ./local-dest-dir`
- `export RCLONE_FTP_PASS=$(read -rsp 'Password: ' && echo "$REPLY" | rclone obscure -)`, `rclone --config= sync -vn --create-empty-src-dirs ./www :ftp:/ --ftp-host=myserver.example.com --ftp-user=myuser --ftp-ask-password --ftp-explicit-tls --ftp-no-check-certificate --size-only`
- `rclone --config= sync -vn --create-empty-src-dirs . :sftp,host=192.168.0.123,port=2222,user=myuser:mydir`
- `rclone check -v myremote:/remote-src-dir ./local-dest-dir`
- `rclone --config= serve -v sftp --dir-cache-time=0 --user=myuser --pass=mypass --read-only .`
- `rclone --config= serve -v sftp --dir-cache-time=0 --addr=0.0.0.0:2022 --user=myuser --authorized-keys=<(echo 'ssh-ed25519 AAAAC3Nza...') .`
- `rclone --config= serve -v webdav --dir-cache-time=0 --disable-dir-list --addr=unix:///tmp/my.sock .`
- `curl -fsSL https://api.github.com/repos/OWNER/REPO/releases/latest | sed -En 's/^  "name": "([^"]+)",$/\1/p'`
- `ssh -oServerAliveInterval=30 -oExitOnForwardFailure=yes myuser@192.168.0.123 -p2222 -NvR80:/tmp/my.sock`
- `ssh -oServerAliveInterval=30 -oExitOnForwardFailure=yes myuser@192.168.0.123 -p2222 -NvL/tmp/my.sock:127.0.0.1:8080`
- `ssh -oServerAliveInterval=30 -NvMS~/.ssh/cm-%C myuser@192.168.0.123`, `ssh -S~/.ssh/cm-%C myuser@192.168.0.123`
- `ssh -oServerAliveInterval=30 -NfMS~/.ssh/cm-%C myuser@192.168.0.123`, `ssh -S~/.ssh/cm-%C myuser@192.168.0.123 -Oexit`
- `ssh -GS~/.ssh/cm-%C myuser@192.168.0.123 | sed -En 's/^ControlPath\s+(.+)$/\1/Ip'`
- `ssh -Jmyjumpuser@myjumphost.example.com:2222 myuser@192.168.0.123`
- `LC_ALL=C grep --color '[^ -~]' myfile.txt`, `LC_ALL=C sed -i 's/[^ -~]/?/g' myfile.txt`
- `sed -Ei 's/^#?force_color_prompt=.*$/force_color_prompt=yes/' ~/.bashrc`
- `sed -Ei 's/^(\s+)#\s*(alias [ef]?grep='\''[ef]?grep --color=auto'\'')/\1\2/' ~/.bashrc`
- `{ base64 -w256 myfile.txt; echo; echo 'Hello, World!'; } | { while read -r i; do [ -n "$i" ] || break; echo "$i"; done | base64 -d | cat -A; cat -A; }`
- `bn=${path##*/}` (similar to `basename "$path"`), `dn=${path%/*}` (similar to `dirname "$path"`)
- `gtk-launch myapp.desktop`
- `update-desktop-database -v ~/.local/share/applications`, `xdg-desktop-menu forceupdate`
- `gnome-session-inhibit --app-id org.gnome.Terminal.desktop --reason 'Unsaved work' --inhibit logout:suspend --inhibit-only`
- `dconf watch /`, `dconf dump /`, `dconf write /org/gtk/gtk4/settings/file-chooser/show-hidden true`
- `gsettings list-recursively`, `gsettings list-schemas --print-paths`
- `gsettings describe org.gtk.gtk4.Settings.FileChooser show-hidden`
- `gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true`
- `powerprofilesctl set power-saver`
- `xdg-mime query default audio/mpeg`, `xdg-mime default vlc.desktop audio/mpeg video/mp4`, `cat ~/.config/mimeapps.list`, `grep '^MimeType=' /usr/share/applications/vlc.desktop`
- `inotifywait -cmqr mydir`, `inotifywait -eMODIFY,ATTRIB,CLOSE_WRITE,MOVE,MOVE_SELF,CREATE,DELETE,DELETE_SELF,UNMOUNT -t10 myfile.log`
- `[ -z "$(lsof +D mydir)" ]`
- `echo 'rename oldname newname' | sftp -b- -oControlPath=~/.ssh/cm-%C -P2222 myuser@192.168.0.123`
- `coproc MYPROC { pinentry-gnome3; }; echo -e 'SETPROMPT My prompt\nGETPIN\nBYE' >&"${MYPROC[1]}"; sed -En 's/^D (.+)$/\1/p' <&"${MYPROC[0]}"`
- `upower -e`, `upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E '^\s+energy-full\S*:'`, `upower -d`
- `fdo_notify() { gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify -- "$1" 0 "$2" "$3" "$4" '[]' '{}' -1; }` (see https://specifications.freedesktop.org/notification-spec/1.3/protocol.html#command-notify), `fdo_notify MyApp folder-open MyTitle MyText`, `fdo_notify MyApp ~/myicon.png MyTitle MyText`
- `wine reg add 'HKLM\SOFTWARE\MyApp' /v MyValue /t REG_SZ /d MyData /f /reg:64` (the `/reg:64` part is required for Wine, otherwise the value would be created under `HKLM\SOFTWARE\Wow6432Node\...`)
- `inkscape --export-filename=myimage.png --export-type=png myimage.svg`
- `printf '%s\n' GRUB_TIMEOUT_STYLE=countdown GRUB_TIMEOUT=3 | install -Tvm644 /dev/stdin /etc/default/grub.d/timeout.cfg && update-grub`
- `fwupdmgr get-updates`
- `udisksctl status`, `udisksctl loop-setup -rf myimage.img`, `udisksctl mount -b /dev/loop0 -o ro`, `udisksctl unmount -b /dev/loop0`, `udisksctl loop-delete -b /dev/loop0`

```bash
install -Tvm600 <(echo 'ACTION=="add", SUBSYSTEM=="pci",' \
    'ATTR{vendor}=="0x1234", ATTR{device}=="0x5678", ATTR{remove}="1"') \
    /etc/udev/rules.d/99-disable-pci-example.rules
udevadm trigger -vcadd -spci -avendor=0x1234 -adevice=0x5678
install -Tvm600 <(echo 'ACTION=="add", SUBSYSTEM=="usb",' \
    'ATTR{idVendor}=="1a2b", ATTR{idProduct}=="3c4d", ATTR{remove}="1"') \
    /etc/udev/rules.d/99-disable-usb-example.rules
udevadm trigger -vcadd -susb -aidVendor=1a2b -aidProduct=3c4d
```

```bash
readonly user_id=1001 user_name=myuser

loginctl enable-linger "$user_name"
for i in {10..1}; do
    [ -e "/run/user/$user_id/systemd/private" ] && break
    echo "Waiting for systemd user session to initialize (max ${i}s)"
    sleep 1
done
[ -e "/run/user/$user_id/systemd/private" ] ||
    { echo 'Timeout waiting for systemd user session' >&2; exit 1; }
```

```bash
fallocate -vl1G myimage.img
/usr/sbin/mkfs.ext4 myimage.img

sudo mkdir -v /mnt/myimage
sudo mount -v myimage.img /mnt/myimage

sudo umount -v /mnt/myimage

sudo apt update && sudo apt install -y fuse2fs

mkdir ~/myimage
fuse2fs myimage.img ~/myimage

fusermount -u ~/myimage
```

```bash
gpg --full-gen-key

gpg --batch --gen-key << 'EOF'
Key-Type: EDDSA
Key-Curve: ed25519
Key-Usage: sign
Subkey-Type: ECDH
Subkey-Curve: cv25519
Subkey-Usage: encrypt
Passphrase: abc
Name-Real: mykey
Expire-Date: 0
%commit
EOF

gpg -k && gpg -K

gpg --passwd mykey

gpg -er mykey myfile.txt; gpg -do myfile.txt myfile.txt.gpg
date | gpg -aer mykey -o mymsg.txt.asc; gpg -d mymsg.txt.asc

gpg -ao mykey-pub.asc --export mykey; gpg -ao mykey-sec.asc --export-secret-key mykey
gpg --import mykey-pub.asc mykey-sec.asc

gpg --export-ownertrust > otrust.txt
rm ~/.gnupg/trustdb.gpg && gpg --import-ownertrust otrust.txt
gpg --edit-key 0123456789ABCDEF0123456789ABCDEF01234567 trust quit
echo '0123456789ABCDEF0123456789ABCDEF01234567:6:' | gpg --import-ownertrust

gpg --delete-secret-and-public-key mykey
```

```bash
# In case of swapfiles it's better to use "dd" to fill the file with actual zeros, rather than "fallocate", due to potential issues with older kernels
sudo dd if=/dev/zero of=/swapfile-additional bs=1M count=10240 status=progress
sudo chmod 600 /swapfile-additional
sudo mkswap /swapfile-additional

sudo swapon /swapfile-additional; sudo swapoff /swapfile-additional

echo '/swapfile-additional none swap sw 0 0' | sudo tee -a /etc/fstab
```

```bash
# Inspired by https://wiki.debian.org/DebianUnstable#Installation

sudo cp -Tv /etc/apt/sources.list{,.old-$(date +%Y-%m-%d-%H%M%S)}

sudo tee /etc/apt/sources.list << 'EOF'
deb http://deb.debian.org/debian/ unstable main non-free-firmware
deb-src http://deb.debian.org/debian/ unstable main non-free-firmware
EOF

sudo apt update && sudo apt full-upgrade
```

```bash
# Warning: this is just an example. You should never write plain passwords in commands
hash_pbkdf2=$({ echo mypassword; echo mypassword; } | grub-mkpasswd-pbkdf2)
hash_pbkdf2=$(echo "$hash_pbkdf2" | grep -o 'grub\.pbkdf2\..*')

sudo install -Tvm700 /dev/stdin /etc/grub.d/01_psw << EOF
#!/bin/sh
exec tail -n+3 "\$0"
set superusers="root"
password_pbkdf2 root $hash_pbkdf2
EOF

sudo sed -Ei 's/^(\s+echo "menuentry .+ \$\{CLASS\} )(\\\$menuentry_id_option '\''gnulinux-simple-.+)$/\1--unrestricted \2/' /etc/grub.d/10_linux

sudo update-grub
```

## Shell snippets for Docker

- `docker run -it --rm --log-driver=none docker.io/library/debian:12`
- `docker run -d --name=mydeb01 docker.io/library/debian:12 sleep infinity`, `docker exec -it mydeb01 bash`, `docker rm -f mydeb01`
- `docker ps -a --format {{.Names}}`
- `docker rm -fv mycontainer`
- `docker run --rm -v myvolume:/v --log-driver=none docker.io/library/busybox tar -cvzC/v . > mybackup.tar.gz`
- `docker run --rm -v myvolume:/v -i docker.io/library/busybox tar -xvzC/v < mybackup.tar.gz`
- `docker create --name=tmp01 docker.io/library/busybox`
  - `docker cp tmp01:/bin - | gzip -c > mybin.tar.gz`
  - `docker cp tmp01:/bin/sh - | tar -xv`
  - `docker rm -v tmp01`
- `docker run -d --name=mydind01 --privileged docker.io/library/docker:dind`
- `docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock --log-driver=none docker.io/wagoodman/dive docker.io/library/python:3`
- `docker-compose down -v && docker-compose up -d --build && docker-compose logs -ft`
- `docker-compose exec mycontainer bash`
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
        install -Tvm440 /dev/stdin /etc/sudoers.d/mainuser-nopassword && \
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
        install -Tvm440 /dev/stdin /etc/sudoers.d/mainuser-nopassword && \
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
- `podman ps -qfname=mycontainer; echo $?`
- `systemctl --user status podman-kube@$(systemd-escape ~/kube.yaml)`
- `journalctl --user -u podman-kube@$(systemd-escape ~/kube.yaml)`
- `ls -la ~/.local/share/containers/storage/volumes`
- `(read -rsp 'Password: ' && echo -e "{\"main\":\"$(echo -n "$REPLY" | base64 -w0)\"}") | podman secret create mypassword -`
- `echo -e "{\"main\":\"$(base64 -w0 mykey.pem)\"}" | podman secret create mykey -`
- `podman image ls -a`, `podman image prune -af`

## Shell snippets for Kubernetes

- `kubectl get all -A`, `kubectl get pod -owide`, `kubectl get pod -w`
- `kubectl run mypod --image=docker.io/library/debian:12 sleep infinity`
- `kubectl exec -it mypod -- bash`
- `kubectl delete pod/mypod`
- `kubectl config current-context`, `kubectl config use-context mycontext`
- `kubectl --context mycontext -n mynamespace get pod`
- `kubectl port-forward pod/mypod '8080:80'`
- `kubectl get secret/mysecret -ojsonpath={.data.password} | base64 -d; echo`
- `kubectl cordon mynode`, `kubectl drain --ignore-daemonsets --delete-emptydir-data mynode`
- `kubectl rollout restart sts/mysts`
- `time kubectl api-resources --verbs=list -oname | xargs -n1 kubectl get -A -owide --show-kind --ignore-not-found`
- `helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update`
- `helm --kube-context mycontext -n mynamespace list`, `helm list -Aa`

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

- `export MSYS_NO_PATHCONV=1`, `python -c'import sys;print(sys.argv)' foo bar`
- `winpty rclone ncdu .`
- `choco list`
- `choco install -y gsudo`
- `sudo choco upgrade -y all`
- `sudo choco install -y winfsp rclone`, `rclone mount myremote: X: --volname='Volume label' --vfs-disk-space-total-size=2T`
- `MSYS=winsymlinks:nativestrict sudo ln -Tsv original.txt link.txt`
- `sudo -d mklink link.txt original.txt`, `sudo -d mklink //d dir-link dir-original`
- `[[ "$(uname)" = MINGW* ]]; echo $?`
- `MSYS_NO_PATHCONV=1 '/c/Program Files/VeraCrypt/VeraCrypt.exe' /q /v '\Device\Harddisk1\Partition1' /l X /m ro /m label='My label'`
- `'/c/Program Files/VeraCrypt/VeraCrypt.exe' //q //v '\Device\Harddisk1\Partition1' //l X //m ro //m label='My label'`
- `'/c/Program Files/VeraCrypt/VeraCrypt.exe' //q //d X`
- `create-shortcut ~/apps/myapp.exe ~/Desktop/myapp.lnk`
- `create-shortcut ~/apps/myapp.exe "$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/myapp.lnk"`, `sudo create-shortcut ~/apps/myapp.exe '/c/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/myapp.lnk'`
- `cp -vt "$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup" '/c/ProgramData/Microsoft/Windows/Start Menu/Programs/My App.lnk'`
- `cygpath -w /d/mymusic/*.mp3 | xargs -rd\\n vlc`
- `msg \* MyMessage`, `date | msg \*`
- `reg add 'HKCU\Software\MyApp' //v MyValue //t REG_SZ //d MyData //f`, `sudo -d reg add 'HKLM\SOFTWARE\MyApp' //v MyValue //t REG_SZ //d MyData //f`
- `reg delete 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run' //v MyApp //f`, `sudo -d reg delete 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' //v MyApp //f`

## Termux

- `termux-info`
- `termux-open myimage.jpg`
- `termux-open-url https://example.com/`
- `termux-setup-storage`

## Prometheus queries

- `abs(mymetric - mymetric offset 1m)`
- `(mymetric > 0.50) and on() (4*60+20 <= hour()*60+minute() <= 4*60+40)`

## Python

- `os.chdir(os.path.dirname(os.path.realpath(__file__)))`
