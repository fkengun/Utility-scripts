#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
KAFKA_ROOT_DIR=/mnt/common/kfeng/pkg_src/kafka_2.13-2.8.0
KAFKA_SCRIPTS_DIR=${KAFKA_ROOT_DIR}/scripts

HOSTNAME=`head -1 ${CWD}/servers`
HOSTNAME_POSTFIX=-40g
if [[ ${HOSTNAME} == *comp* ]]
then
  drive="nvme"
elif [[ ${HOSTNAME} == *stor* ]]
then
  drive="hdd"
fi

# Zookeeper
ZOOKEEPER_DATA_DIR=/mnt/${drive}/kfeng/zookeeper
ZOOKEEPER_SERVERS_HOSTFILE=${CWD}/servers
ZOOKEEPER_N_SERVERS=`wc -l ${ZOOKEEPER_SERVERS_HOSTFILE} | cut -d' ' -f1`
ZOOKEEPER_SERVERS=`cat ${ZOOKEEPER_SERVERS_HOSTFILE} | awk '{print $1}'`
ZOOKEEPER_CONF_FILE=${KAFKA_SCRIPTS_DIR}/zookeeper.properties
ZOOKEEPER_CLIENT_PORT=2181
ZOOKEEPER_FOLLOWER_PORT=2888
ZOOKEEPER_ELECTION_PORT=3888

# Kafka
KAFKA_LOG_DIR=/mnt/${drive}/kfeng/kafka
KAFKA_SERVERS_HOSTFILE=${CWD}/servers
KAFKA_N_SERVERS=`wc -l ${KAFKA_SERVERS_HOSTFILE} | cut -d' ' -f1`
KAFKA_SERVERS=`cat ${KAFKA_SERVERS_HOSTFILE} | awk '{print $1}'`
KAFKA_CONF_FILE=${KAFKA_LOG_DIR}/server.properties
KAFKA_PORT=9092
