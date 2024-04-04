# coredns

```bash
docker-compose up -d
```

To test it:

```bash
dig @localhost -p15353 foo.example.com
dig @localhost +tcp -p15353 foo.example.com
```

**Note**: instead of a Docker container, you can also download and run _CoreDNS_ as a standalone executable:

```bash
curl -fLO https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_amd64.tgz
tar -xvzf coredns_1.11.1_linux_amd64.tgz
./coredns
```
