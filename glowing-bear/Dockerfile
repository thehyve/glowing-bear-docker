FROM nginx:1.16.0-alpine
LABEL maintainer="luk.zim91@gmail.com"

# Build-time environment variables
ENV GB_VERSION 1.3.8
ENV GB_SRC_URL "https://repo.thehyve.nl/content/repositories/releases/nl/thehyve/glowing-bear/${GB_VERSION}/glowing-bear-${GB_VERSION}.tar"

# download and untar application artifacts
COPY config.template.json /usr/share/nginx/html/config.template.json
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN cd /usr/share/nginx/html && \
    chmod +x /docker-entrypoint.sh && \
    wget "${GB_SRC_URL}" -O "glowing-bear-archive.tar" && \
    tar xf "glowing-bear-archive.tar" --strip 1 && \
    rm "glowing-bear-archive.tar" && \
    cd / && \
    rm -rf /tmp/* /var/tmp/* && sync

CMD ["/docker-entrypoint.sh"]
