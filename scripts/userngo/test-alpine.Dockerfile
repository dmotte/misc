# syntax=docker/dockerfile:1

# Tested with docker.io/library/alpine:3.23.4
FROM docker.io/library/alpine:latest

RUN apk add --no-cache tini bash su-exec doas

# Src: https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user#doas
RUN echo 'permit persist :wheel' > /etc/doas.d/20-wheel.conf

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:7ad246472844df9a5c1a2d203555db210b113b531f8e1621680274f499f566c1 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/userngo/userngo-alpine.sh \
#     /opt/userngo/main.sh
COPY --chown=root:root --chmod=755 userngo-alpine.sh /opt/userngo/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

ENTRYPOINT ["/sbin/tini", "--", "/bin/bash", "/opt/userngo/main.sh", \
    "/bin/bash", "/opt/app.sh"]
