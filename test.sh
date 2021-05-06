#!/bin/bash

cd "$(dirname $(readlink -f $0))"
source ./.env

unset http_proxy https_proxy socks_proxy socks4_proxy socks5_proxy

echo -e "\n\e[90mCMD: curl -s https://checkip.amazonaws.com\e[0m"
echo -e "Your home WAN IP: \e[33m$(curl -s https://checkip.amazonaws.com || echo '\e[31mERROR')\e[0m\n"

echo -e "\e[90mCMD: curl -s --proxy http://127.0.0.1:${HTTP_PROXY_PORT} https://checkip.amazonaws.com\e[0m"
echo -e "IP through HTTP Proxy (port: ${HTTP_PROXY_PORT}): \e[33m$(curl -s --proxy http://127.0.0.1:${HTTP_PROXY_PORT} https://checkip.amazonaws.com || echo '\e[31mERROR')\e[0m\n"

echo -e "\e[90mCMD: curl -s --proxy socks4://127.0.0.1:${SOCKS_PROXY_PORT} https://checkip.amazonaws.com\e[0m"
echo -e "IP through SOCKS4 Proxy (port: ${SOCKS_PROXY_PORT}): \e[33m$(curl -s --proxy socks4://127.0.0.1:${SOCKS_PROXY_PORT} https://checkip.amazonaws.com || echo '\e[31mERROR')\e[0m\n"

echo -e "\e[90mCMD: curl -s --proxy socks5://127.0.0.1:${SOCKS_PROXY_PORT} https://checkip.amazonaws.com\e[0m"
echo -e "IP through SOCKS5 Proxy (port: ${SOCKS_PROXY_PORT}): \e[33m$(curl -s --proxy socks5://127.0.0.1:${SOCKS_PROXY_PORT} https://checkip.amazonaws.com || echo '\e[31mERROR')\e[0m\n"
