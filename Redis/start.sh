#!/bin/bash

REDIS_DIR=~/pkg_src/redis-3.2.13
REDIS_VER=`$REDIS_DIR/src/redis-server -v | awk '{print $3}' | cut -d'=' -f2`
CONF_FILE=redis.conf
HOSTNAME_POSTFIX=-40g
PWD=$(pwd)
SERVERS=`cat servers | awk '{print $1}'`
PORT_BASE=7000

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

n_server=`cat servers | wc -l`
if [ $((n_server%2)) -ne 0 ]
then
  echo "Even number of servers are required, exiting ..."
  exit
fi

if [[ $n_server < 6 ]]
then
  echo "At least 6 servers are required, exiting ..."
  exit
fi

# Prepare configuration for each server
i=0
for server in ${SERVERS[@]}
do
  server_ip=$(getent ahosts $server$HOSTNAME_POSTFIX | grep STREAM | awk '{print $1}')
  ((port=$PORT_BASE+$i))
  mkdir -p $port
  rm -rf $port/$CONF_FILE
  echo "port $port" >> $port/$CONF_FILE
  echo "cluster-enabled yes" >> $port/$CONF_FILE
  echo "cluster-config-file nodes.conf" >> $port/$CONF_FILE
  echo "cluster-node-timeout 5000" >> $port/$CONF_FILE
  echo "appendonly yes" >> $port/$CONF_FILE
  echo "protected-mode no" >> $port/$CONF_FILE
  echo "logfile $PWD/$port/file.log" >> $port/$CONF_FILE
  ((i=i+1))
done

# Start server
i=0
for server in ${SERVERS[@]}
do
  ((port=$PORT_BASE+$i))
  echo Starting redis on $server:$port ...
  ssh $server "sh -c \"cd $PWD/$port; $REDIS_DIR/src/redis-server ./$CONF_FILE > /dev/null 2>&1 &\""
  ((i=i+1))
done

# Verify server
mpssh -f servers 'pgrep -l redis-server'

# Connect servers
# for Redis 5 the command should be like redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 --cluster-replicas 1
# for Redis 3 and 4, the command looks like ./redis-trib.rb create --replicas 1 127.0.0.1:7000 127.0.0.1:7001
i=0
if version_gt $REDIS_VER "5.0"
then
  echo "Redis 5.x, using redis-cli ..."
  cmd="$REDIS_DIR/src/redis-cli --cluster create "
else
  echo "Redis 3.x/4.x, using redis-trib.rb ..."
  cmd="$REDIS_DIR/src/redis-trib.rb create --replicas 1 "
fi

for server in ${SERVERS[@]}
do
  server_ip=$(getent ahosts $server$HOSTNAME_POSTFIX | grep STREAM | awk '{print $1}')
  ((port=$PORT_BASE+$i))
  cmd="${cmd}${server_ip}:${port} "
  ((i=i+1))
done
if version_gt $REDIS_VER "5.0"
then
  cmd="${cmd}--cluster-replicas 1"
fi
$cmd
