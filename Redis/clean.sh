#!/bin/bash

LOCAL_DIR=/mnt/hdd/kfeng/redis
PWD=$(pwd)
SERVERS=`cat servers | awk '{print $1}'`
PORT_BASE=7000

./stop.sh

i=0
for server in ${SERVERS[@]}
do
  ((port=$PORT_BASE+$i))
  ssh $server "rm -rf $LOCAL_DIR/$port/*.aof $LOCAL_DIR/$port/*.rdb $LOCAL_DIR/$port/nodes.conf $LOCAL_DIR/$port/file.log"
  ((i=i+1))
done
echo "Previous Redis is cleaned"
