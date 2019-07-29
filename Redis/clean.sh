#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

LOCAL_DIR=/mnt/hdd/kfeng/redis
PWD=~/pkg_src/Utility-scripts/Redis
SERVERS=`cat ${PWD}/servers | awk '{print $1}'`
PORT_BASE=7000

${PWD}/stop.sh

echo -e "${GREEN}Cleaning Redis ...${NC}"
i=0
for server in ${SERVERS[@]}
do
  ((port=$PORT_BASE+$i))
  #ssh $server "rm -rf $LOCAL_DIR/$port/*.aof $LOCAL_DIR/$port/*.rdb $LOCAL_DIR/$port/nodes.conf $LOCAL_DIR/$port/file.log"
  ssh $server "rm -rf $LOCAL_DIR/*"
  ((i=i+1))
done
echo "Previous Redis is cleaned"
