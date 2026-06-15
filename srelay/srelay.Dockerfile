FROM alpine:latest AS builder

RUN set -exvo pipefail; \
    apk --update add --no-cache linux-headers make g++ tar gzip wget;

RUN set -exvo pipefail; \
    mkdir /tmp/srelay; cd /tmp/srelay; \
    wget -O srelay-src.tar.gz https://master.dl.sourceforge.net/project/socks-relay/socks-relay/srelay-0.4.9/srelay-0.4.9.tar.gz; \
    tar --strip-components=1 -zxvf srelay-src.tar.gz; \
    ./configure CFLAGS="-Wno-incompatible-pointer-types -Wno-int-conversion" && make;

FROM alpine:latest

COPY --from=builder /tmp/srelay/srelay /usr/sbin/srelay
COPY ./srelay.conf /etc/srelay.conf

ENTRYPOINT [ "/usr/sbin/srelay", "-fvc", "/etc/srelay.conf" ]