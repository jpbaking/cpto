FROM alpine:latest

RUN set -exvo pipefail; \
    apk --update add --no-cache openvpn;

COPY ./entrypoint.sh /entrypoint.sh

RUN set -exvo pipefail; \
    chmod +x /entrypoint.sh;

WORKDIR /.openvpn

ENTRYPOINT [ "/entrypoint.sh" ]
