# syntax=docker/dockerfile:1

FROM docker.io/library/debian:13

RUN <<'EOF' /bin/bash -e
    apt-get update; apt-get install -y tini openssh-client openssh-server
    rm -rf /var/lib/apt/lists/*

    rm -fv /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub

    install -dvm755 /opt/sshset{,/data}

    useradd -Ums/bin/bash alice
    useradd -Ums/bin/bash bob
EOF

# ADD --chown=root:root --chmod=755 \
#     --checksum=sha256:373fd70b06f37bdf92d1cd70eda4a91894a62b43427d0ff4705bbd02a67d4ef1 \
#     https://raw.githubusercontent.com/dmotte/misc/refs/heads/main/scripts/sshset/sshset.sh \
#     /opt/sshset/main.sh
COPY --chown=root:root --chmod=755 sshset.sh /opt/sshset/main.sh

COPY --chown=root:root --chmod=755 app.sh /opt/app.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash", "/opt/app.sh"]
