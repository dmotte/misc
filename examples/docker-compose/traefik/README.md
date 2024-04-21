# traefik

This directory contains some examples for the **Traefik** proxy and load-balancer.

For each example, the recommended command to start the docker-compose stack is:

```bash
docker-compose down && docker-compose up
```

## Useful notes

To generate the passwords for the **digest authentication**, [use the `htdigest` command](https://doc.traefik.io/traefik/middlewares/digestauth/). If you are on _Debian_ and the `htdigest` command is not installed, you can run:

```bash
sudo apt-get update && sudo apt-get install -y apache2-utils
```

Similar packages exist for other operating systems.

## example-01

Features:

- uses **HTTP** only (port **80**), no HTTPS
- **two Docker containers** are served, respectively at http://foo.lvh.me/ and http://bar.lvh.me/
- the Traefik **dashboard** is active and in [**secure mode**](https://doc.traefik.io/traefik/operations/dashboard/#secure-mode) at http://dashboard.lvh.me/
  - the login **credentials** are `admin:admin`

## example-02

Before starting this stack, you have to generate a **custom certificate** (`server.crt` and `server.key` files). To do so, you can use the _OpenSSL_ utility:

```bash
openssl req -newkey rsa:2048 -nodes -keyout server.key \
    -x509 -days 365 -subj "/C=IT/ST=Italy/L=/O=MyOrganization/OU=/CN=*.example.com" -out server.crt
```

Features:

- uses **HTTPS** (port **443**)
- the **URLs** to access the containers are https://foo.example.com/ and https://bar.example.com/
- every request made to **port 80 is redirected to the HTTPS port** at the same path
- there is a **custom permanent redirect** from https://example.com/ to https://www.example.com/
- containers use the **main `bridged` Docker network** (`docker0`) instead of the default docker-compose stack network
- container **labels** are used as dynamic configuration provider for Traefik
- the Traefik **dashboard** is available at https://dashboard.example.com/

**Note**: it's a good thing to set the `traefik.http.routers.<name>.entryPoints=websecure` label for every container in this case, because otherwise the Traefik routers would bind to all the `entryPoint`s including `web`, which isn't secure because it uses HTTP.

## example-03

Before starting this stack, you have to create an **empty file named `acme.json`** with **`600` permissions**:

```bash
touch acme.json
chmod 600 acme.json
```

It will be used to store the keys and certificates issued by _Let's Encrypt_.

Features:

- uses HTTPS with automatically-generated certificates, using **Let's Encrypt**
- **DNS domains** will be **automatically assigned** to the containers based on their name
- the **`foo` container** listens on **port 8080** instead of 80

## example-04

Similar to [example-01](#example-01), but:

- container **labels** are used as dynamic configuration provider for Traefik
- the Traefik **dashboard** is served on **port 8080**, which is bound to **localhost only** in the `docker-compose.yml` file
- the Traefik **dashboard** is accessible **without authentication**

## Additional tips

:bulb: You can specify **multiple domains** in a single `Host` router rule with: ``Host(`foo.example.com`, `bar.example.com`)``

:bulb: You can use a **regular expression** to match domains with: ``HostRegexp(`example.com`, `{subdomain:.+}.example.com`)``. See https://doc.traefik.io/traefik/routing/routers/#rule for further details

:bulb: If you use _Let's Encrypt_ as the certificate resolver and you want a router to handle all the possible subdomains (with `HostRegexp`) but, for some reason, you cannot use the _ACME DNS-01_ challenge and you are fine with enabling _Let's Encrypt_ only for some subdomains, you can **manually** specify the details of the HTTPS certificate **for each domain** with something like this:

```yaml
http:
  routers:
    myrouter:
      entryPoints: [websecure]
      rule: >
        HostRegexp(
          `example.com`,
          `{subdomain:.+}.example.com`,
        )
      tls:
        certResolver: letsencrypt
        domains:
          - main: example.com
            sans: [www.example.com]
          - main: www01.example.com
          - main: www02.example.com
          - main: www03.example.com
      service: myservice
```

## Links

- https://hub.docker.com/_/traefik
- https://github.com/traefik/traefik/blob/master/traefik.sample.yml
- https://doc.traefik.io/traefik/migration/v1-to-v2/
- https://doc.traefik.io/traefik/migration/v1-to-v2/#dashboard
- https://doc.traefik.io/traefik/migration/v1-to-v2/#http-to-https-redirection-is-now-configured-on-routers
- https://doc.traefik.io/traefik/routing/routers/#entrypoints
- https://doc.traefik.io/traefik/migration/v1-to-v2/#acme-letsencrypt
- https://doc.traefik.io/traefik/https/acme/
- https://doc.traefik.io/traefik/routing/providers/docker/#services
- https://doc.traefik.io/traefik/middlewares/redirectregex/
- https://doc.traefik.io/traefik/routing/routers/#rule
