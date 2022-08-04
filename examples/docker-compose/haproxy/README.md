# haproxy

```bash
docker-compose up -d
```

Then you can visit http://localhost:8080/

To trigger a configuration file reload:

```bash
docker-compose kill -s SIGHUP haproxy
```

To check the _HAProxy_ configuration file:

```bash
docker-compose run --rm haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg
```
