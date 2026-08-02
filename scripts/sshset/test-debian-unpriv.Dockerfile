# syntax=docker/dockerfile:1

FROM docker.io/library/debian:13

RUN <<'EOF' /bin/bash -e
    apt-get update; apt-get install -y tini openssh-client openssh-server
    rm -rf /var/lib/apt/lists/*

    rm -fv /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub

    install -dvm755 /opt/sshset{,/data}

    useradd -Ums/bin/bash user
EOF

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:977ab60310f3882f34874a828413b5711f7632b229226668b2bb5b45ff0783e8 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/sshset/sshset.sh \
#     /opt/sshset/main.sh
COPY --chown=root:root --chmod=755 sshset.sh /opt/sshset/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

USER user

ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash", "/opt/app.sh"]
