# glowing-bear-docker
Docker compose script for Glowing Bear and its dependencies. 


## Configuration

The default environment variables are defined in the [`.env`](.env) file.

### Authentication

Applications use Keycloak for authentication, however it is not a part of this script. 
The assumption is that there is already a Keycloak server running, connection to which is configured
by setting the variables below:

Variable              | Description
:-------------------- |:---------------
`KEYCLOAK_SERVER_URL` | URL of the Keycloak server e.g. `https://keycloak-dwh-test.thehyve.net`
`KEYCLOAK_REALM`      | Keycloak realm, e.g. `transmart-dev`
`KEYCLOAK_CLIENT_ID`  | Keycloak client id, e.g. `transmart-client`

Current configuration supports Keycloak version <= `4.5`.

### Connection

Configuring a connection over either HTTP, or HTTPS is supported.
[Nginx](https://www.nginx.com/) is used as a reverse proxy.
The following variables are required to be specified:

Variable                | Description
:---------------------- |:--------------------------
`NGINX_HOST`            | Name of the server (default: `localhost`)
`NGINX_PORT`            | `80` if applications should be available via HTTP or <br/>`443 ssl` if applications should be available via HTTPS

#### SSL

To configure SSL, follow the steps below:
1. Set the `NGINX_PORT` to `443 ssl`.
2. Add the following volumes:
    - volume with a signed server certificate: `./nginx/server.crt:/etc/nginx/server.crt`
    - volume with a private key: `./nginx/server.key:/etc/nginx/server.key`
    - volume with a ssl configuration: `./nginx/ssl.conf:/etc/nginx/ssl.conf`

The `ssl.conf` file is expected to contain two directives - `ssl_certificate` and `ssl_certificate_key`. 
For the example above it should be:

```
ssl_certificate /etc/nginx/server.crt;
ssl_certificate_key /etc/nginx/server.key;
```

To generate a self-signed certificate run, e.g.:
```bash
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out nginx/server.crt -keyout nginx/server.key -subj "/C=NL/ST=Utrecht/L=Utrecht/O=The Hyve/CN=localhost"
```


## Run

Install [docker-compose](https://docs.docker.com/compose/install/) and run:
```bash
docker-compose up -d
```

This starts:
 - web server serving [Glowing Bear](https://github.com/thehyve/glowing-bear/tree/dev/docker),
 - [TranSMART API server with a database](https://github.com/thehyve/transmart-core/tree/dev/docker),
 - [Gb Backend with a database](https://github.com/thehyve/gb-backend/tree/dev/docker)
 - [transmart-packer](https://github.com/thehyve/transmart-packer).


Glowing Bear and the the APIs of other services can be reached using the following urls:

Application                | URL
:------------------------- |:--------------------------
Glowing Bear               | `$HOSTNAME`
TranSMART Api Server       | `$HOSTNAME`/api/transmart-api-server
TranSMART Packer           | `$HOSTNAME`/api/transmart-packer
Gb Backend                 | `$HOSTNAME`/api/gb-backend

Where the `$HOSTNAME` is defined based on `$NGINX_HOST` and `$NGINX_PORT` variables: (e.g.: `https://localhost`).

Additionally, the TranSMART database server will be exposed at port `9432`.

### Logs

Logs are written to `journald`. The logs can be inspected with
```bash
journalctl -f -u docker.service
```
and for individual services with `docker logs <service-name> -f`, e.g.,
```bash
docker logs transmart-api-server -f
```


## Development

The project tasks and [known issues](https://github.com/thehyve/glowing-bear-docker/issues) are managed on the [project board](https://github.com/thehyve/glowing-bear-docker/projects/1).


## License

MIT &copy; 2019 The Hyve.
