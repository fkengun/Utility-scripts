#!/bin/bash

PWD=$(pwd)
SERVERS=`cat servers | awk '{print $1}'`
PORT_BASE=7000

./stop.sh

i=0
for server in ${SERVERS[@]}
do
  ((port=$PORT_BASE+$i))
  rm -rf $PWD/$port/*.aof $PWD/$port/*.rdb $PWD/$port/nodes.conf
  ((i=i+1))
done
echo "Previous Redis is cleaned"
