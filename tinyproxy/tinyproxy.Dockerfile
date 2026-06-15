FROM alpine:latest

RUN set -exvo pipefail; \
    apk --update add --no-cache tinyproxy;

COPY ./tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]