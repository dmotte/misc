# ansible-local

This is an example of how to **test an Ansible playbook locally** (without any remote host) using a **Debian Docker container**.

```bash
docker build -t img-debian-ansible - << 'EOF'
FROM docker.io/library/debian:12
RUN apt-get update && \
    apt-get install -y ansible && \
    rm -rf /var/lib/apt/lists/*
EOF

docker run -it --rm -v "$PWD:/pwd" img-debian-ansible ansible-playbook /pwd/playbook.yml
```
