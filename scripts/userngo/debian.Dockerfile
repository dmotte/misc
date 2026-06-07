# syntax=docker/dockerfile:1

FROM docker.io/library/debian:13

RUN <<'EOF' /bin/bash -e
    apt-get update; apt-get install -y tini gosu sudo
    rm -rf /var/lib/apt/lists/*
EOF

COPY --chown=root:root --chmod=755 *.sh /opt/userngo/

ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash", "/opt/userngo/userngo.sh", \
    "/bin/bash", "/opt/userngo/start.sh"]
