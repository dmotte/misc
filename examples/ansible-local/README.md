# ansible-local

This is an example of how to **test an Ansible playbook locally** (without any remote host) using an **Alpine Podman container**.

```bash
podman build -t img-alpine-ansible:latest - << 'EOF'
# syntax=docker/dockerfile:1

# Tested with docker.io/library/alpine:3.24.1
FROM docker.io/library/alpine:latest

RUN <<'EOF2' /bin/sh -e
    apk add --no-cache ansible
EOF2

WORKDIR /v
EOF

podman run -it --rm -v.:/v img-alpine-ansible ansible-playbook playbook.yml
```
