#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

LOCAL_DIR=/mnt/hdd/kfeng/redis
PWD=~/pkg_src/Utility-scripts/Redis
REDIS_DIR=~/pkg_src/redis-3.2.13
SERVERS=`cat ${PWD}/servers | awk '{print $1}'`
PORT_BASE=7000
SERVER_HOST_PREFIX=ares-stor

echo -e "${GREEN}Flushing all data ...${NC}"
servers=`cat ${PWD}/servers | awk '{print $1}'`
nservers=`cat ${PWD}/servers | wc -l`
count=0
for server in ${servers[@]}
do
  ((port=$PORT_BASE+$count))
  echo flushall | ${REDIS_DIR}/src/redis-cli -c -h ${server} -p ${port}
  ((count=$count+1))
done
