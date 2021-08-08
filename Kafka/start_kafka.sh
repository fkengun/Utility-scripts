#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -f ${CWD}/env.sh ]
then
  source ${CWD}/env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

# Start zookeeper
id=1
for zookeeper_server in ${ZOOKEEPER_SERVERS[@]}
do
  ssh ${zookeeper_server} "echo ${id} > ${ZOOKEEPER_DATA_DIR}/myid" &
  ((id=${id}+1))
done
wait

if [[ -f ${ZOOKEEPER_CONF_FILE} ]]
then
  mpssh -f ${ZOOKEEPER_SERVERS_HOSTFILE} "JAVA_TOOL_OPTIONS='-Xmx4G -Xms4G -Djava.net.preferIPv4Stack=true' nohup ${KAFKA_ROOT_DIR}/bin/zookeeper-server-start.sh -daemon ${ZOOKEEPER_CONF_FILE}"
  mpssh -f ${ZOOKEEPER_SERVERS_HOSTFILE} "jps" | sort -u
else
  echo "Zookeeper configuration file ${ZOOKEEPER_CONF_FILE} missing, exiting ..."
  exit
fi

# Start Kafka
num_conf_files=`mpssh -f servers 'ls -l /mnt/nvme/kfeng/kafka/server.properties' 2>&1 | grep server | grep -v cannot | wc -l`
if [[ ${num_conf_files} == ${KAFKA_N_SERVERS} ]]
then
  mpssh -f ${KAFKA_SERVERS_HOSTFILE} "JAVA_TOOL_OPTIONS='-Xmx4G -Xms4G -Djava.net.preferIPv4Stack=true' nohup ${KAFKA_ROOT_DIR}/bin/kafka-server-start.sh -daemon ${KAFKA_CONF_FILE}"
  mpssh -f ${KAFKA_SERVERS_HOSTFILE} "jps" | sort -u
else
  echo "${num_conf_files} Kafka configuration file found, ${KAFKA_N_SERVERS} is expected, exiting ..."
  exit
fi
