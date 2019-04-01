#!/bin/bash

REDIS_DIR=~/pkg_src/redis-5.0.4
CONF_FILE=redis.conf
HOSTNAME_POSTFIX=-40g
PWD=$(pwd)
SERVERS=`cat servers | awk '{print $1}'`
PORT_BASE=7000

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
i=0
cmd="$REDIS_DIR/src/redis-cli --cluster create "
for server in ${SERVERS[@]}
do
  server_ip=$(getent ahosts $server$HOSTNAME_POSTFIX | grep STREAM | awk '{print $1}')
  ((port=$PORT_BASE+$i))
  cmd="${cmd}${server_ip}:${port} "
  ((i=i+1))
done
cmd="${cmd}--cluster-replicas 1"
$cmd
