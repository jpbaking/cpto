FROM alpine:latest AS builder

RUN set -xv; \
    apk --update add --no-cache linux-headers make g++ tar gzip wget;

RUN set -xv; \
    mkdir /tmp/srelay; cd /tmp/srelay; \
    wget -O srelay-src.tar.gz https://udomain.dl.sourceforge.net/project/socks-relay/socks-relay/srelay-0.4.8/srelay-0.4.8p3.tar.gz; \
    tar --strip-components=1 -zxvf srelay-src.tar.gz; \
    ./configure && make;

FROM alpine:latest

COPY --from=builder /tmp/srelay/srelay /usr/sbin/srelay
COPY ./srelay.conf /etc/srelay.conf

ENTRYPOINT [ "/usr/sbin/srelay", "-fvc", "/etc/srelay.conf" ]