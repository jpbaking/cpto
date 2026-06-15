FROM alpine:latest

RUN set -exvo pipefail; \
    apk --update add --no-cache tinyproxy;

COPY ./tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

ENTRYPOINT ["/usr/bin/tinyproxy", "-d"]