#!/bin/sh
set -e

mkdir -p /etc/nginx/sites-enabled

if [ -n "${SSL_PROXY_HOSTNAMES}" ]; then
  hosts=$(echo "${SSL_PROXY_HOSTNAMES}" | tr "," "\n")
  for host in $hosts
  do
    host_name=$(echo "${host}" | cut -f 1 -d ':')
    host_port=$(echo "${host}" | cut -f 2 -d ':')

    cat > "/etc/nginx/sites-enabled/${host_name}.conf" <<EndOfMessage
  server {
    listen 443 ssl;
    server_name           ${host_name};
    ssl_certificate       /etc/nginx/server.pem;
    ssl_certificate_key   /etc/nginx/server.key;
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
      proxy_redirect        default;
    }
  }
EndOfMessage
    cat > "/etc/nginx/sites-enabled/fw-${host_name}.conf" <<EndOfMessage
  server {
    listen 80;
    server_name ${host_name};
    return 301 https://${host_name}\$request_uri;
  }
EndOfMessage
  done
fi

sync

unset hosts
unset host_name
unset host_port
unset SSL_PROXY_HOSTNAMES
unset LOCAL_DOCKER_IP

exec nginx -g 'daemon off;'
