#!/bin/bash

mpssh > /dev/null 2>&1 || { echo >&2 "mpssh is not found.  Aborting."; exit 1; }

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SERVER_LOCAL_PATH="/home/kfeng/mongodb"
CLIENT_LOCAL_PATH="/home/kfeng/mongodb"
TMPFS_PATH="/dev/shm"
mongod_local_path=${SERVER_LOCAL_PATH}/mongod
mongos_local_path=${SERVER_LOCAL_PATH}/mongos
MONGOD_CONF_FILE=mongod.conf
MONGOS_CONF_FILE=mongos.conf
MONGOD_LOG_FILE=mongod.log
MONGOS_LOG_FILE=mongos.log
MONGO_PORT=27017
CONFIG_REPL_NAME=replconfig01
SHARD_REPL_NAME=shardreplica01
CONFIG_SERVER_COUNT=2
SHARD_SERVER_COUNT=6
ROUTER_SERVER_COUNT=8
