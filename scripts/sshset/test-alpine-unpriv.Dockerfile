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
#     --checksum=sha256:373fd70b06f37bdf92d1cd70eda4a91894a62b43427d0ff4705bbd02a67d4ef1 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/sshset/sshset.sh \
#     /opt/sshset/main.sh
COPY --chown=root:root --chmod=755 sshset.sh /opt/sshset/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

USER user

ENTRYPOINT ["/sbin/tini", "--", "/bin/bash", "/opt/app.sh"]
