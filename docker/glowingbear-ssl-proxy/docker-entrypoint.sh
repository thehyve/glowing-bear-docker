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
       proxy_pass            http://glowing-bear:9080/;
       proxy_read_timeout    90s;
       proxy_connect_timeout 90s;
       proxy_send_timeout    90s;
       proxy_set_header      X-Real-IP \$remote_addr;
       proxy_set_header      X-Forwarded-For \$proxy_add_x_forwarded_for;
       proxy_set_header      Proxy "";
       proxy_redirect        default;
     }
   }
EndOfMessage
cat > /etc/nginx/sites-enabled/fw-glowingbear.conf <<EndOfMessage
   server {
     listen 80;
     server_name ${GLOWINGBEAR_HOSTNAME};
     return 301 https://${GLOWINGBEAR_HOSTNAME}\$request_uri;
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
       proxy_pass            http://keycloak:8080/;
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
cat > /etc/nginx/sites-enabled/fw-keycloak.conf <<EndOfMessage
   server {
     listen 80;
     server_name ${KEYCLOAK_HOSTNAME};
     return 301 https://${KEYCLOAK_HOSTNAME}\$request_uri;
   }
EndOfMessage
fi

sync

unset KEYCLOAK_HOSTNAME
unset GLOWINGBEAR_HOSTNAME

exec nginx -g 'daemon off;'
