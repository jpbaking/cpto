FROM alpine:latest

RUN set -xv; \
    apk --update add --no-cache haproxy;

COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg

ENTRYPOINT [ "/usr/sbin/haproxy", "-W", "-db", "-f", "/etc/haproxy/haproxy.cfg" ]
