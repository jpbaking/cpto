FROM alpine:latest

RUN apk --update add --no-cache dante-server

COPY ./danted.conf /etc/sockd.conf
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
