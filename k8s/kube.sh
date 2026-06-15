#!/bin/bash

if [ -z "$(which kubectl)" ]; then
  echo -e '\n[FATAL] Please install the latest kubectl!\n'
  exit 1
fi

cd $(dirname $(readlink -f $0))

kubectl --namespace=cpto $@
