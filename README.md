# glowing-bear-docker
Docker scripts for Glowing Bear and its dependencies.

## Run

Install [docker-compose](https://docs.docker.com/compose/install/) and run
```bash
docker-compose up
```

This starts web server serving [Glowing Bear](https://github.com/thehyve/glowing-bear/tree/dev/docker), [TranSMART API server with a database](https://github.com/thehyve/transmart-core/tree/dev/docker), [Gb Backend with a database](https://github.com/thehyve/gb-backend/tree/dev/docker) 
and [transmart-packer](https://github.com/thehyve/transmart-packer).

Applications use Keycloak for authentication. The following environment variables
can be used to configure Keycloak:

Variable              | Default value
----------------------|---------------
`KEYCLOAK_SERVER_URL` | https://keycloak-dwh-test.thehyve.net
`KEYCLOAK_REALM`      | transmart-dev
`KEYCLOAK_CLIENT_ID`  | transmart-client

For a current setup urls of TranSMART API server, Gb Backend and transmart-packer should be configured, 
 what cab be done using the following environment variables:

Variable                   | Default value
---------------------------|---------------------------
`TRANSMART_API_SERVER_URL` | http://localhost:9081
`TRANSMART_PACKER_URL`     | http://localhost:8999
`GB_BACKEND_URL`           | http://localhost:9083

The default values are defined in the [`.env`](../.env) file.

### Ports

The following ports will be exposed:

Value    | Type  | Description
---------|-------|-----------------
9080     | `tcp` | The Glowing Bear UI
9083     | `tcp` | The Gb Backend
9081     | `tcp` | The TranSMART API Server
9432     | `tcp` | PostgreSQL database server for TranSMART
8999     | `tcp` | transmart-packer


The Glowing Bear application is available at http://localhost:9080.

## :construction: Under development

This repository is still under development.
Currently, a [design document](Design.md) is being created.
The project tasks are managed on the [project board](https://github.com/thehyve/glowing-bear-docker/projects/1).


## License

MIT &copy; 2019 The Hyve.
