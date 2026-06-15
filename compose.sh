#!/bin/bash

if [ -z "$(which docker)" ]; then
  echo -e '\n[FATAL] Please install the latest docker!\n'
  exit 1
fi

cd $(dirname $(readlink -f $0))

docker compose --project-name=cpto $@