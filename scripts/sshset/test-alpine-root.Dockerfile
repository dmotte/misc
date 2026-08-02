# syntax=docker/dockerfile:1

# Tested with docker.io/library/alpine:3.24.1
FROM docker.io/library/alpine:latest

RUN <<'EOF' /bin/sh -e
    apk add --no-cache tini bash coreutils findutils \
        openssh-client openssh-server

    install -dvm755 /opt/sshset /opt/sshset/data

    adduser -Ds/bin/sh alice
    adduser -Ds/bin/sh bob
    # Needed because the OpenSSH Server does not use PAM by default on
    # Alpine Linux, so users with the password field set to "!" in /etc/shadow
    # are considered disabled
    printf '%s\n' 'alice:*' 'bob:*' | chpasswd -e
EOF

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:977ab60310f3882f34874a828413b5711f7632b229226668b2bb5b45ff0783e8 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/sshset/sshset.sh \
#     /opt/sshset/main.sh
COPY --chown=root:root --chmod=755 sshset.sh /opt/sshset/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

ENTRYPOINT ["/sbin/tini", "--", "/bin/bash", "/opt/app.sh"]
