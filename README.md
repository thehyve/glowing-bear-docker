# glowing-bear-docker

Docker compose scripts for Glowing Bear and its dependencies. 

This repository contains `docker-compose` scripts for running:
- Glowing Bear and its backend services `transmart-api-server`, `gb-backend` and `transmart-packer`,
  and their databases;
- Keycloak and its database;
- An SSL proxy for Glowing Bear and Keycloak.

The Glowing Bear application and the backend services use Keycloak for authentication.
Currently, Keycloak version <= `4.5` is supported.
It is preferred to have a Keycloak instance at organisation level,
instead of installing it on the same machine as Glowing Bear, but we also provide
[instructions on how to set up Keycloak](#setting-up-keycloak) on a single machine together with Glowing Bear.

Please ensure that you have a recent version of Docker (>= `18`).
If you do not have `docker-compose` installed,
follow the instructions to [install docker-compose](https://docs.docker.com/compose/install/).


## Deploying Glowing Bear and backend services

The environment variables for the docker-compose script are defined in the `.env` file:

Variable              | Description
:-------------------- |:---------------
`KEYCLOAK_SERVER_URL` | URL of the Keycloak server e.g. `https://keycloak.example.com`
`KEYCLOAK_REALM`      | Keycloak realm, e.g. `transmart`
`KEYCLOAK_CLIENT_ID`  | Keycloak client id, e.g. `transmart-client`

1. Create a `.env` file:
    ```properties
    KEYCLOAK_SERVER_URL=https://keycloak.example.com
    KEYCLOAK_REALM=transmart
    KEYCLOAK_CLIENT_ID=transmart-client
    ```
2. Run:
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
Glowing Bear               | `http://localhost:9080`
TranSMART Api Server       | `http://localhost:9080/api/transmart-api-server`
TranSMART Packer           | `http://localhost:9080/api/transmart-packer`
Gb Backend                 | `http://localhost:9080/api/gb-backend`

Additionally, the TranSMART database server will be exposed at port `9432`.


## Setting up Keycloak

Here we describe how to set up Keycloak on a single machine together with Glowing Bear.
There is a separate docker-compose script for Glowing Bear and its components and one for Keycloak.
We use Nginx for setting up a reverse proxy with SSL. We assume that there is a valid SSL
certificate available for two hostnames, one for Glowing Bear and one for Keycloak, which are
aliases for the same machine.

Add the following variables to the `.env` file.

Variable            | Description
:------------------ |:---------------
`KEYCLOAK_HOSTNAME` | FQDN of the Keycloak server, e.g., `keycloak.example.com`.
`KEYCLOAK_USER`     | Admin user name (default: `admin`)
`KEYCLOAK_PASSWORD` | Password for the admin user. Please choose a strong password, generated using a password manager.

1. Create a `.env` file, or add these to an existing `.env` file:
    ```properties
    KEYCLOAK_USER=admin
    KEYCLOAK_PASSWORD=generate a strong password
    KEYCLOAK_HOSTNAME=keycloak.example.com
    ```
2. Run:
    ```bash
    docker-compose -f keycloak.yml up -d
    ```

### Configure a realm

To configure Keycloak for use with Glowing Bear and TranSMART, import the
[example realm configuration](keycloak/transmart-realm.json) into Keycloak. 
More information about how to set up Keycloak, see the
 [TranSMART API server documentation](https://github.com/thehyve/transmart-core/tree/dev/transmart-api-server)


## Setting up an SSL proxy

To enable SSL, we use Nginx as a proxy.
Copy the certificate, named `server.pem`, and the certificate key, named `server.key` to the `ssl` directory.
To generate a self-signed certificate for hostname `example.com`
with aliases `keycloak.example.com` and `glowingbear.example.com`, run, e.g.:
```bash
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
  -out ssl/server.pem -keyout ssl/server.key \
  -subj "/C=NL/ST=Utrecht/L=Utrecht/O=The Hyve/CN=example.com" \
  -addext "subjectAltName=DNS:keycloak.example.com,DNS:glowingbear.example.com"
```

In case of a self-signed certificate, copy the file `ssl/server.pem` to
`ssl/extra_certs.pem` to have the certificate accepted by the services.
This is for instance needed for the backend services to verify
an access token with Keycloak. 

Add the following variables to the `.env` file.

Variable               | Description
:--------------------- |:---------------
`GLOWINGBEAR_HOSTNAME` | FQDN of the Glowing Bear server, e.g., `glowingbear.example.com`.
`KEYCLOAK_HOSTNAME`    | FQDN of the Keycloak server, e.g., `keycloak.example.com`.

1. Prepare the `.env` file:
    ```properties
    GLOWINGBEAR_HOSTNAME=glowingbear.example.com
    KEYCLOAK_HOSTNAME=keycloak.example.com
    ```
2. Prepare the `ssl/server.pem` and `ssl/server.key` files.
3. `cp ssl/server.pem ssl/extra_certs.pem` 
4. Run:
    ```bash
    docker-compose -f glowingbear-ssl-proxy.yml up -d
    ```

Glowing Bear should now be accessible via `https://glowingbear.example.com` and Keycloak via
`https://keycloak.example.com`.

The services can be stopped with `./stopall`.


## Glowing Bear, Keycloak and the SSL proxy combined

1. Prepare a single `.env` file:
    ```properties
    KEYCLOAK_SERVER_URL=https://keycloak.example.com
    KEYCLOAK_REALM=transmart
    KEYCLOAK_CLIENT_ID=transmart-client
    
    GLOWINGBEAR_HOSTNAME=glowingbear.example.com
    KEYCLOAK_HOSTNAME=keycloak.example.com
    
    KEYCLOAK_USER=admin
    KEYCLOAK_PASSWORD=choose a strong password
    ```
2. Prepare the `ssl/server.pem` and `ssl/server.key` files.
3. `cp ssl/server.pem ssl/extra_certs.pem` 
4. Run:
    ```bash
    ./startall
    ```


## Logs

Logs are written to `journald` by default. The logs can be inspected with
```bash
journalctl -f -u docker.service
```
and for individual services with `docker logs <service-name> -f`, e.g.,
```bash
docker logs transmart-api-server -f
```

If `journald` is not available (e.g., on MacOS),
add `DOCKER_LOGGING_DRIVER=json-file` to the `.env` file.
Logs can then still be inspected with `docker logs`, but not with `journalctl`.


## Development

The project tasks and [known issues](https://github.com/thehyve/glowing-bear-docker/issues) are managed on the [project board](https://github.com/thehyve/glowing-bear-docker/projects/1).


## License

MIT &copy; 2019 The Hyve.
