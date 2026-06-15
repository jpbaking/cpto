FROM alpine:latest

RUN set -xv; \
    apk --update add --no-cache openvpn;

COPY ./entrypoint.sh /entrypoint.sh

RUN set -xv; \
    chmod +x /entrypoint.sh;

WORKDIR /.openvpn

ENTRYPOINT [ "/entrypoint.sh" ]
