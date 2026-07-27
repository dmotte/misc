# syntax=docker/dockerfile:1

# Tested with docker.io/library/alpine:3.24.1
FROM docker.io/library/alpine:latest

RUN <<'EOF' /bin/sh -e
    apk add --no-cache tini bash coreutils findutils \
        openssh-client openssh-server

    install -dvm755 /opt/sshset /opt/sshset/data

    adduser -Ds/bin/sh user
EOF

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:4f7fb153fb68f6b37be6f701f007c3163a82d472408e204fd281f010d2bbcf23 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/sshset/sshset.sh \
#     /opt/sshset/main.sh
COPY --chown=root:root --chmod=755 sshset.sh /opt/sshset/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

USER user

ENTRYPOINT ["/sbin/tini", "--", "/bin/bash", "/opt/app.sh"]
