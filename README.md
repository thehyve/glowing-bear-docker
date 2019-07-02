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
`KEYCLOAK_SERVER_URL` | URL of the Keycloak server e.g. `https://keycloak.example.com`
`KEYCLOAK_REALM`      | Keycloak realm, e.g. `transmart`
`KEYCLOAK_CLIENT_ID`  | Keycloak client id, e.g. `transmart-client`

Current configuration supports Keycloak version <= `4.5`.

It is preferred to set up a Keycloak instance at organisation level, but we provide
[instructions on how to set up Keycloak](keycloak) on a single machine together with Glowing Bear.

### Connection

Configuring a connection over either HTTP, or HTTPS is supported.
[Nginx](https://www.nginx.com/) is used as a reverse proxy.
The following variables are required to be specified:

Variable                | Description
:---------------------- |:--------------------------
`NGINX_HOST`            | Name of the server (default: `localhost`)
`NGINX_PORT`            | `80` if applications should be available via HTTP or <br/>`443 ssl` if applications should be available via HTTPS (default: `80`)

The file `nginx/ssl.conf` should always exist and can be empty if `NGINX_PORT` is `80`.

#### SSL

To configure SSL, follow the steps below:
1. Set the `NGINX_PORT` to `443 ssl`.
2. Configure `nginx/ssl.conf` to contain two directives: `ssl_certificate` and `ssl_certificate_key`: 
    ```nginx
    ssl_certificate /etc/nginx/server.crt;
    ssl_certificate_key /etc/nginx/server.key;
    ```
3. Copy the certificate and the certificate key to the `nginx` directory.
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

Where the `$HOSTNAME` is defined based on `$NGINX_HOST` and `$NGINX_PORT` variables: (e.g.: `http://localhost`).

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
