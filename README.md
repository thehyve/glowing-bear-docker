# glowing-bear-docker
Docker compose script for Glowing Bear and its dependencies. 
Currently it supports only ssl connection and requires (self-)signed certificate
to be present in `./nginx` directory.

## Run
1. Rename your server certificate and private key to `server.crt` and `server.key`. 
Move both files to `./nginx` directory.

2. Change the configuration as described below.

3. Install [docker-compose](https://docs.docker.com/compose/install/) and run:
```bash
docker-compose up
```

This starts:
 - web server serving [Glowing Bear](https://github.com/thehyve/glowing-bear/tree/dev/docker), 
 - [TranSMART API server with a database](https://github.com/thehyve/transmart-core/tree/dev/docker), 
 - [Gb Backend with a database](https://github.com/thehyve/gb-backend/tree/dev/docker) 
 - [transmart-packer](https://github.com/thehyve/transmart-packer).

### Configuration 

The default environmental variables are defined  in [`.env`](../.env) file.

Applications use Keycloak for authentication. The following environment variables
can be used to configure Keycloak:

Variable              | Default value
----------------------|---------------
`KEYCLOAK_SERVER_URL` | https://keycloak-dwh-test.thehyve.net
`KEYCLOAK_REALM`      | transmart-dev
`KEYCLOAK_CLIENT_ID`  | transmart-client

Glowing Bear and the the APIs of other services can be reached using the following urls:

Application                | URL
---------------------------|---------------------------
Glowing Bear               | `$HOSTNAME`
TranSMART Api Server       | `$HOSTNAME`/api/transmart-api-server
TranSMART Packer           | `$HOSTNAME`/api/transmart-packer
Gb Backend                 | `$HOSTNAME`/api/gb-backend

Where the `$HOSTNAME` is defined based on `$NGINX_HOST` variable: `https://$NGINX_HOST` (default: `https://localhost`).

Additionally TranSMART database will be exposed at port `9432`.

## :construction: Under development

This repository is still under development.
Currently, a [design document](Design.md) is being created.
The project tasks are managed on the [project board](https://github.com/thehyve/glowing-bear-docker/projects/1).


## License

MIT &copy; 2019 The Hyve.
