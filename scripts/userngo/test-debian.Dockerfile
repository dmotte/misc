# syntax=docker/dockerfile:1

FROM docker.io/library/debian:13

RUN <<'EOF' /bin/bash -e
    apt-get update; apt-get install -y tini gosu sudo
    rm -rf /var/lib/apt/lists/*
EOF

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:7ad246472844df9a5c1a2d203555db210b113b531f8e1621680274f499f566c1 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/userngo/userngo-debian.sh \
#     /opt/userngo/main.sh
COPY --chown=root:root --chmod=755 userngo-debian.sh /opt/userngo/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash", "/opt/userngo/main.sh", \
    "/bin/bash", "/opt/app.sh"]
