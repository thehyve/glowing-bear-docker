FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
