#!/bin/sh
set -e

mkdir -p /etc/nginx/sites-enabled

if [[ ! -z ${GLOWINGBEAR_HOSTNAME} ]]; then
cat > /etc/nginx/sites-enabled/glowingbear.conf <<EndOfMessage
   server {
     listen 443 ssl;

     server_name           ${GLOWINGBEAR_HOSTNAME};

     ssl_certificate       /etc/nginx/server.pem;
     ssl_certificate_key   /etc/nginx/server.key;

     index                 index.html;

     location / {
       proxy_pass            http://172.17.0.1:9080;
       proxy_read_timeout    90s;
       proxy_connect_timeout 90s;
       proxy_send_timeout    90s;
       proxy_set_header      Host \$host;
       proxy_set_header      X-Real-IP \$remote_addr;
       proxy_set_header      X-Forwarded-For \$proxy_add_x_forwarded_for;
       proxy_set_header      Proxy "";
       proxy_set_header      X-Forwarded-Proto https;
       proxy_redirect        off;
     }
   }
EndOfMessage
fi
if [[ ! -z ${KEYCLOAK_HOSTNAME} ]]; then
cat > /etc/nginx/sites-enabled/keycloak.conf <<EndOfMessage
   server {
     listen 443 ssl;

     server_name           ${KEYCLOAK_HOSTNAME};

     ssl_certificate       /etc/nginx/server.pem;
     ssl_certificate_key   /etc/nginx/server.key;

     index                 index.html;

     location / {
       proxy_pass            http://172.17.0.1:8080;
       proxy_read_timeout    90s;
       proxy_connect_timeout 90s;
       proxy_send_timeout    90s;
       proxy_set_header      Host \$host;
       proxy_set_header      X-Real-IP \$remote_addr;
       proxy_set_header      X-Forwarded-For \$proxy_add_x_forwarded_for;
       proxy_set_header      Proxy "";
       proxy_set_header      X-Forwarded-Proto https;
       proxy_redirect        off;
     }
   }
EndOfMessage
fi

sync

unset KEYCLOAK_HOSTNAME
unset GLOWINGBEAR_HOSTNAME

exec nginx -g 'daemon off;'
