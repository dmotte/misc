# syntax=docker/dockerfile:1

# Tested with docker.io/library/alpine:3.24.1
FROM docker.io/library/alpine:latest

RUN <<'EOF' /bin/sh -e
    apk add --no-cache tini bash su-exec doas

    install -dvm755 /opt/userngo

    # Src: https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user#doas
    echo 'permit persist :wheel' > /etc/doas.d/20-wheel.conf
EOF

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:8575aee5f1fa387ce870cade5cba02a063beb910fc2d17ab50d11a81182b3fde \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/userngo/userngo-alpine.sh \
#     /opt/userngo/main.sh
COPY --chown=root:root --chmod=755 userngo-alpine.sh /opt/userngo/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

ENTRYPOINT ["/sbin/tini", "--", "/bin/bash", "/opt/userngo/main.sh", \
    "/bin/bash", "/opt/app.sh"]
