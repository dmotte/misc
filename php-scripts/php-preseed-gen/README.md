# php-preseed-gen

:elephant: Simple PHP script that can be used to **generate Debian Preseed** files.

:warning: **Caution**: this project is **highly experimental**. **Not suitable for production use**.

## Usage

> **Important**: this has been tested with **PHP 8.4.16** on **Debian 13** (_trixie_).

```bash
curl -fsSL 'http://localhost:8080/preseed-gen.php?country=IT&hostname=myhostname&disk=/dev/sda'

curl -fsSL 'http://localhost:8080/preseed-gen.php' \
    --url-query country=IT \
    --url-query hostname=myhostname \
    --url-query password=changeme \
    --url-query disk=/dev/sda \
    --url-query tasksel=ssh-server \
    --url-query pkgs=python3 \
    --url-query sshd-port=2222 \
    --url-query sudo-nopasswd=true \
    --url-query ssh-authkeys='ssh-ed25519 AAAAC3Nza...'
```
