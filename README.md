# glowing-bear-docker

Docker compose scripts for Glowing Bear and its dependencies. 

This repository contains `docker-compose` scripts for running:
- Glowing Bear and its backend services `transmart-api-server`, `gb-backend` and `transmart-packer`,
  and their databases;
- Keycloak and its database;
- An SSL proxy for Glowing Bear and Keycloak.

The Glowing Bear application and the backend services use Keycloak for authentication.
It is preferred to have a Keycloak instance at organisation level,
instead of installing it on the same machine as Glowing Bear, but we also provide
[instructions on how to set up Keycloak](#setting-up-keycloak) on a single machine together with Glowing Bear.

Please ensure that you have a recent version of Docker (>= `18`).
If you do not have `docker-compose` installed,
follow the instructions to [install docker-compose](https://docs.docker.com/compose/install/).


## Deploying Glowing Bear and backend services

The environment variables for the docker-compose script are defined in the `.env` file:

Variable                   | Description
:------------------------- |:---------------
`INSTANCE_ID`              | A unique instance identifier, e.g., `DWH1`
`KEYCLOAK_SERVER_URL`      | URL of the Keycloak server e.g. `https://keycloak.example.com`
`KEYCLOAK_REALM`           | Keycloak realm, e.g. `transmart`
`KEYCLOAK_CLIENT_ID`       | Keycloak client id, e.g. `transmart-client`
`DENY_ACCESS_WITHOUT_ROLE` | Only allow access to users with a role (default: `false`).

1. Create a `.env` file:
    ```properties
    INSTANCE_ID=DWH1
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
There can be 2 different types of your certificates:

* Self-signed certificates: you can generate your own certificates for development purposes.
Be aware that in production your self-signed certificates will not be accepted by the users browser.

* Certificates signed by one of CA (certificate authorities).
That can be commercial ones or free (like Let's encrypt), or your organisation CA.

### Self-signed certificates

To generate a self-signed certificate for hostname `example.com`
with aliases `keycloak.example.com` and `glowingbear.example.com`, run, e.g.:
```bash
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
  -out ssl/server.pem -keyout ssl/server.key \
  -subj "/C=NL/ST=Utrecht/L=Utrecht/O=The Hyve/CN=example.com" \
  -addext "subjectAltName=DNS:keycloak.example.com,DNS:glowingbear.example.com"
```

This requires OpenSSL 1.1.1 or newer.

### Certificates signed by CA

CA usually provide you with 4 files of following types:

* certificate file for your hostname (eg. `cert.pem`);

* private key file for your hostname (eg. `privkey.pem`);

* chain file (eg. `chain.pem`) - this file contains a certificate chain of CA

    ```bash
    -----BEGIN CERTIFICATE-----
      Certificate of Root CA
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
      Certificate of CA(1) signed by Root CA
    -----END CERTIFICATE-----
    ...
    -----BEGIN CERTIFICATE-----
      Certificate of CA(n) signed by CA(n-1)
    -----END CERTIFICATE-----
    ```

    in the simplest scenario that may contain just 1 certificate;

* full-chain file (eg. `fullchain.pem`) - this file is a concatenation of `cert.pem` and `chain.pem` files;

Sometimes you don't have a full-chain file, but that is not a problem, since it is possible to create one by yourself:

```bash
cp cert.pem fullchain.pem
cat chain.pem >> fullchain.pem
```

From those 4 files this solution requires `cert.pem` and `full-chain.pem` files.
Copy them to `ssl` directory:

```bash
cp privkey.pem ssl/server.key
cp fullchain.pem ssl/server.pem
```

### Common tasks

You should also copy the file `ssl/server.pem` to
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
    INSTANCE_ID=DWH1

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

## Running variant store connector

The `startall` script has a flag `--connector` that allows you to run your setup together with variant store connector.
If you run this script without any flag or with `--no-connector`, your setup will run without variant store connector.

Before running variant store connector be sure that your `.env` file contains all variables declaration as described previously.
You should also add additional variable to that file, so variant store connector will be able to find variant store instance and transmart server instance:
```properties
VARIANT_STORE_URL=https://variant-store.example.com
```

Be sure that you did all steps required for working with SSL proxy.

After all run:
```bash
./startall --connector
```


## Running the docker-compose scripts locally

If you want to try these scripts locally, without having separate DNS records
for Glowing Bear and Keycloak pointing to your machine, some additional steps are
required:

1. Add hostnames to your `etc/hosts` file:
    ```
    127.0.0.1       keycloak
    127.0.0.1       glowingbear
    ```
2. Add `extra_hosts` to the `transmart-api-server`, `gb-backend` and `transmart-packer`
   services in `docker-compose.yml` (and to `transmart-variant-store-connector` in `connector.yml` if running with `--connector` flag):
    ```yaml
    extra_hosts:
      - "keycloak:172.17.0.1"
    ```
3. Set these local aliases as host names in the `.env` file:
    ```properties
    KEYCLOAK_SERVER_URL=https://keycloak
    GLOWINGBEAR_HOSTNAME=glowingbear
    KEYCLOAK_HOSTNAME=keycloak
    ```
4. Use `localhost`, `keycloak` and `glowingbear` when generating the certificate: 
    ```bash
    openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
      -out ssl/server.pem -keyout ssl/server.key \
      -subj "/C=NL/ST=Utrecht/L=Utrecht/O=The Hyve/CN=localhost" \
      -addext "subjectAltName=DNS:keycloak,DNS:glowingbear"
    ```


## Running multiple instances on a single host

In order to run multiple instances, a unique instance id and different ports need to be configured for
Glowing Bear, the TranSMART database and, optionally Keycloak and the variant store connector.
Since the SSL proxy always listens on port 443 (the default https port),
running multiple SSL proxies is not supported.
Please set up your own SSL proxy for multiple instances instead. 
Create a directory per instance with a `.env` file containing the configuration for that instance.

An example of such configuration in the `/var/data-warehouses/dhw2/.env` file:
```properties
INSTANCE_ID=DWH2
GLOWING_BEAR_PORT=9080
TRANSMART_DATABASE_PORT=9432
KEYCLOAK_PORT=8080
TRANSMART_VARIANT_STORE_CONNECTOR_PORT=9060
```

Start the instance `DWH2`:
```bash
docker-compose -f docker-compose.yml --project-directory /var/data-warehouses/dwh2 up
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
