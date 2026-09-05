# syntax=docker/dockerfile:1

FROM docker.io/library/debian:13

RUN <<'EOF' /bin/bash -e
    apt-get update; apt-get install -y tini gosu sudo
    rm -rf /var/lib/apt/lists/*

    install -dvm755 /opt/userngo
EOF

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:b70d61ebf193b0f2feb3ebf20724f4a1332304ea3ca847ad4e3fdf1401e51ba4 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/userngo/userngo-debian.sh \
#     /opt/userngo/main.sh
COPY --chown=root:root --chmod=755 userngo-debian.sh /opt/userngo/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash", "/opt/userngo/main.sh", \
    "/bin/bash", "/opt/app.sh"]
