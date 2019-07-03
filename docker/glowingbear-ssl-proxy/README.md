# Glowing Bear SSL proxy image

[![Docker Build Status](https://img.shields.io/docker/pulls/thehyve/glowingbear-ssl-proxy.svg)](https://hub.docker.com/r/thehyve/glowingbear-ssl-proxy)

Nginx-based Docker image to provide an SSL proxy for Glowing Bear
and (optionally) Keycloak.

## Configuration

The following SSL files should be mounted as volumes: 
- `/etc/nginx/server.pem`: the server certificate chain, valid for both hostnames
- `/etc/nginx/server.key`: the private key for the server

The service redirects traffic to the hostname configured in `GLOWINGBEAR_HOSTNAME`
to port `9080` on the same machine and traffic to the hostname in `KEYCLOAK_HOSTNAME`
to port `8080`. It assumes that Glowing Bear is hosted at port `9080` and Keycloak
is running at port `8080`.

The proxy is only created for the hostnames that are specified. I.e., if only
`GLOWINGBEAR_HOSTNAME` is set, but not `KEYCLOAK_HOSTNAME`, then only a proxy to
Glowing Bear is created.

`http` traffic is redirected to `https`. 

| URL                               | Target
|:--------------------------------- |:------------------------
| `https://${GLOWINGBEAR_HOSTNAME}` | `http://172.17.0.1:9080`
| `https://${KEYCLOAK_HOSTNAME}`    | `http://172.17.0.1:8080`
| `http://${GLOWINGBEAR_HOSTNAME}`  | `https://${GLOWINGBEAR_HOSTNAME}`
| `http://${KEYCLOAK_HOSTNAME}`     | `https://${KEYCLOAK_HOSTNAME}`


## Development

### Build and publish

Build the image and publish it to [Docker Hub](https://hub.docker.com/r/thehyve/glowingbear-ssl-proxy).

```bash
# Build image
VERSION="0.0.1"
docker build -t "thehyve/glowingbear-ssl-proxy:${VERSION}" . --no-cache
# Publish image to Docker Hub
docker login
docker push "thehyve/glowingbear-ssl-proxy:${VERSION}"
```
