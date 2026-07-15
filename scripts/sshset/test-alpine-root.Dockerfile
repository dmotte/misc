# syntax=docker/dockerfile:1

# Tested with docker.io/library/alpine:3.24.1
FROM docker.io/library/alpine:latest

RUN <<'EOF' /bin/sh -e
    apk add --no-cache tini bash openssh-server

    install -dvm755 /opt/sshset
EOF

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/sshset/sshset-alpine.sh \
#     /opt/sshset/main.sh
COPY --chown=root:root --chmod=755 sshset-alpine.sh /opt/sshset/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

ENTRYPOINT ["/sbin/tini", "--", "/bin/bash", "/opt/app.sh"]
