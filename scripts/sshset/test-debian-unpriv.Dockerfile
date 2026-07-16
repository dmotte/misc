# syntax=docker/dockerfile:1

FROM docker.io/library/debian:13

RUN <<'EOF' /bin/bash -e
    apt-get update; apt-get install -y tini openssh-server
    rm -rf /var/lib/apt/lists/*

    rm -fv /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub

    install -dvm755 /opt/sshset

    useradd -Ums/bin/bash user
EOF

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/sshset/sshset-debian.sh \
#     /opt/sshset/main.sh
COPY --chown=root:root --chmod=755 sshset-debian.sh /opt/sshset/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

USER user

ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash", "/opt/app.sh"]
