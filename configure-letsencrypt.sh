#!/bin/sh

#
# Script to generate configuration for the Let's encrypt service.
# It requires the SSL_PROXY_HOSTNAMES and LOCAL_DOCKER_IP variables set.
# Example:
# SSL_PROXY_HOSTNAMES=glowingbear.example.com:9080,keycloak.example.com:8080
# LOCAL_DOCKER_IP=172.17.0.1
#
# Start with docker-compose -f letsencrypt.yml up -d
#

set -e

mkdir -p letsencrypt/nginx/site-confs/

echo "Configuring Let's Encrypt for the following hosts: ${SSL_PROXY_HOSTNAMES}"

if [ -z "${LOCAL_DOCKER_IP}" ]; then
  echo "Please configure LOCAL_DOCKER_IP. Check the docker IP address with ifconfig. It is probably 172.17.0.1."
  exit 1
fi

if [ -n "${SSL_PROXY_HOSTNAMES}" ]; then
  hosts=$(echo "${SSL_PROXY_HOSTNAMES}" | tr "," "\n")
  for host in $hosts
  do
    host_name=$(echo "${host}" | cut -f 1 -d ':')
    host_port=$(echo "${host}" | cut -f 2 -d ':')

    cat > "letsencrypt/nginx/site-confs/${host_name}.conf" <<EndOfMessage
server {
  listen 443 ssl;
  server_name           ${host_name};
  include               /config/nginx/ssl.conf;
  index                 index.html;
  location / {
    proxy_pass            http://${LOCAL_DOCKER_IP}:${host_port}/;
    proxy_read_timeout    90s;
    proxy_connect_timeout 90s;
    proxy_send_timeout    90s;
    proxy_set_header      X-Real-IP \$remote_addr;
    proxy_set_header      X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header      X-Forwarded-Proto \$scheme;
    proxy_set_header      Proxy "";
    proxy_set_header      Host \$host;
    proxy_http_version    1.1;
    proxy_set_header      Upgrade \$http_upgrade;
    proxy_set_header      Connection "Upgrade";
    proxy_redirect        default;
  }
}
EndOfMessage
    cat > "letsencrypt/nginx/site-confs/fw-${host_name}.conf" <<EndOfMessage
server {
  listen 80;
  server_name ${host_name};
  return 301 https://${host_name}\$request_uri;
}
EndOfMessage
  done
fi
