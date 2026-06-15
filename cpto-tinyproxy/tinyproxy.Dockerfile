FROM alpine:latest

RUN set -xv; \
    apk --update add --no-cache tinyproxy;

COPY ./tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

ENTRYPOINT [ "/usr/bin/tinyproxy", "-d" ]