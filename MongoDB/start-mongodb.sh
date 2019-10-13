#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -f ${CWD}/env.sh ]
then
  source ${CWD}/env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

source ~/.bash_aliases

echo -e "${GREEN}Preparing config files ...${NC}"
sed -i "s|dbPath:.*|dbPath: ${mongod_local_path}|" ${MONGOD_CONF_FILE}
sed -i "s|path: .*|path: ${TMPFS_PATH}/${MONGOD_LOG_FILE}|" ${MONGOD_CONF_FILE}
sed -i "s|port: .*|port: ${MONGO_PORT}|" ${MONGOD_CONF_FILE}
sed -i "s|dbPath:.*|dbPath: ${mongos_local_path}|" ${MONGOS_CONF_FILE}
sed -i "s|path: .*|path: ${TMPFS_PATH}/${MONGOS_LOG_FILE}|" ${MONGOS_CONF_FILE}
sed -i "s|port: .*|port: ${MONGO_PORT}|" ${MONGOS_CONF_FILE}

server_list=`cat ${CWD}/servers | awk '{print $1}'`
for server in ${server_list[@]}
do
  rsync -az ${CWD}/${MONGOD_CONF_FILE} ${server}:${SERVER_LOCAL_PATH}/${MONGOD_CONF_FILE} &
done
wait
client_list=`cat ${CWD}/clients | awk '{print $1}'`
for client in ${client_list[@]}
do
  rsync -az ${CWD}/${MONGOS_CONF_FILE} ${client}:${CLIENT_LOCAL_PATH}/${MONGOS_CONF_FILE} &
done

mpssh -f ${CWD}/servers "mkdir -p ${mongod_local_path}" > /dev/null
mpssh -f ${CWD}/clients "mkdir -p ${mongos_local_path}" > /dev/null

echo -e "${GREEN}Starting config nodes ...${NC}"
config_server_list=`head -${CONFIG_SERVER_COUNT} ${CWD}/servers | awk '{print $1}'`
for config_server in ${config_server_list[@]}
do
  ssh ${config_server} "sed -i 's|clusterRole: .*|clusterRole: configsvr|' ${SERVER_LOCAL_PATH}/${MONGOD_CONF_FILE}" &
  ssh ${config_server} "sed -i 's|replSetName: .*|replSetName: \"${CONFIG_REPL_NAME}\"|' ${SERVER_LOCAL_PATH}/${MONGOD_CONF_FILE}" &
done
wait

for config_server in ${config_server_list[@]}
do
  ssh ${config_server} "numactl --interleave=all mongod --config ${SERVER_LOCAL_PATH}/${MONGOD_CONF_FILE} --fork" &
done
wait
sleep 5

echo -e "${GREEN}Initializing config replica set ...${NC}"
first_config_server=`head -1 ${CWD}/servers`
second_config_server=`head -2 ${CWD}/servers | tail -1`
sed -i "s|_id : 0, host : \"ares-comp-.*|_id : 0, host : \"${first_config_server}:${MONGO_PORT}\" },|" conf_replica_init.js
sed -i "s|_id : 1, host : \"ares-comp-.*|_id : 1, host : \"${second_config_server}:${MONGO_PORT}\" }|" conf_replica_init.js
mongo --host ${first_config_server} --port ${MONGO_PORT} < conf_replica_init.js > conf_replica_init.log
cat conf_replica_init.log | grep -i ok
mongo --host ${first_config_server} --port ${MONGO_PORT} --eval "rs.isMaster()" > conf_replica_init.log
cat conf_replica_init.log | grep -i "ismaster\|configsvr"
mongo --host ${first_config_server} --port ${MONGO_PORT} --eval "rs.status()" > conf_replica_init.log
cat conf_replica_init.log | grep -i "ok\|\"name\"\|stateStr"

echo -e "${GREEN}Starting shard nodes ...${NC}"
shard_server_list=`awk "NR > ${CONFIG_SERVER_COUNT} && NR <= $((SHARD_SERVER_COUNT+CONFIG_SERVER_COUNT))" ${CWD}/servers | awk '{print $1}'`
for shard_server in ${shard_server_list}
do
  ssh ${shard_server} "sed -i 's|clusterRole: .*|clusterRole: shardsvr|' ${SERVER_LOCAL_PATH}/${MONGOD_CONF_FILE}" &
  ssh ${shard_server} "sed -i 's|replSetName: .*|replSetName: \"${SHARD_REPL_NAME}\"|' ${SERVER_LOCAL_PATH}/${MONGOD_CONF_FILE}" &
done
wait
for shard_server in ${shard_server_list}
do
  ssh ${shard_server} "numactl --interleave=all mongod --config ${SERVER_LOCAL_PATH}/${MONGOD_CONF_FILE} --fork" &
done
wait

echo -e "${GREEN}Initializing shard replica set ...${NC}"
truncate -s 0 shard_replica_init.js
printf "rs.initiate(\n{\n" > shard_replica_init.js
printf "\t_id : \"${SHARD_REPL_NAME}\",\n" >> shard_replica_init.js
printf "\tmembers: [" >> shard_replica_init.js
count=0
for shard_server in ${shard_server_list}
do
  if [[ ${count} != $((SHARD_SERVER_COUNT-1)) ]]
  then
    printf "\t\t{ _id : %s, host : \"%s\" },\n" ${count} ${shard_server} >> shard_replica_init.js
  else
    printf "\t\t{ _id : %s, host : \"%s\" }\n" ${count} ${shard_server} >> shard_replica_init.js
  fi
  count=$((count+1))
done
printf "\t]\n}\n)" >> shard_replica_init.js
mongo --host ${shard_server} --port ${MONGO_PORT} < shard_replica_init.js > shard_replica_init.log
cat shard_replica_init.log | grep -i ok

echo -e "${GREEN}Starting router nodes ...${NC}"
router_server_list=`head -${ROUTER_SERVER_COUNT} ${CWD}/clients | awk '{print $1}'`
mongos_cmd="mongos --configdb \"${CONFIG_REPL_NAME}/"
for config_server in ${config_server_list[@]}
do
  mongos_cmd="${mongos_cmd}${config_server}:${MONGO_PORT},"
done
mongos_cmd=`echo ${mongos_cmd} | sed 's/,$/"/'`
mongos_cmd="${mongos_cmd} --config ${CLIENT_LOCAL_PATH}/${MONGOS_CONF_FILE} --fork"
echo $mongos_cmd
for router_server in ${router_server_list[@]}
do
  ssh ${router_server} "${mongos_cmd}" &
done
wait

echo -e "${GREEN}Adding shards to mongos/query router ...${NC}"
truncate -s 0 add_shard_to_mongos.js
for shard_server in ${shard_server_list}
do
  echo "sh.addShard(\"${SHARD_REPL_NAME}/${shard_server}:${MONGO_PORT}\")" >> add_shard_to_mongos.js
done
echo "sh.status()" >> add_shard_to_mongos.js
mongo --host ${router_server} --port ${MONGO_PORT} < add_shard_to_mongos.js >> add_shard_to_mongos.log
cat add_shard_to_mongos.log | grep -i ok

echo -e "${GREEN}Checking mongod ...${NC}"
mpssh -f ${CWD}/servers 'pgrep -la mongod' | sort
echo -e "${GREEN}Checking mongos ...${NC}"
mpssh -f ${CWD}/clients 'pgrep -la mongos' | sort

echo -e "${GREEN}Done starting MongoDB${NC}"
