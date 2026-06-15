#!/bin/bash

cd $(dirname $(readlink -f $0))

haproxy -W -db -f /root/haproxy.cfg