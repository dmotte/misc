# syntax=docker/dockerfile:1

# Tested with docker.io/library/alpine:3.23.4
FROM docker.io/library/alpine:latest

RUN apk add --no-cache tini bash su-exec sudo

COPY --chown=root:root --chmod=755 *.sh /opt/userngo/

ENTRYPOINT ["/sbin/tini", "--", "/bin/bash", "/opt/userngo/userngo.sh", \
    "/bin/bash", "/opt/userngo/start.sh"]
