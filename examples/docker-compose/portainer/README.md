# portainer

```bash
docker-compose up -d
```

Then you can visit the _Portainer_ **Web UI** at https://localhost:9443/. Login with username `admin` and password `changeme`.

To generate the hash value for the `--admin-password` CLI argument I used the following command:

```bash
docker run --rm httpd:2.4-alpine htpasswd -nbB admin changeme
```

The `debian01` container is just a sample _Debian_ container.

## Links

- [Install Portainer with Docker on Linux](https://docs.portainer.io/start/install/server/docker/linux)
- [Portainer admin password in a docker-compose environment](https://gist.github.com/deviantony/62c009b41bde5e078b1a7de9f11f5e55)
