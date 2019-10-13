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

source ${CWD}/stop-mongodb.sh

echo -e "${GREEN}Removing MongoDB directories ...${NC}"
mpssh -f ${CWD}/servers "rm -rf ${mongod_local_path}" > /dev/null
mpssh -f ${CWD}/servers "rm -rf ${mongos_local_path}" > /dev/null
mpssh -f ${CWD}/clients "rm -rf ${mongod_local_path}" > /dev/null
mpssh -f ${CWD}/clients "rm -rf ${mongos_local_path}" > /dev/null

echo -e "${GREEN}Removing MongoDB conf files ...${NC}"
mpssh -f ${CWD}/servers "rm -rf ${SERVER_LOCAL_PATH}/${MONGOD_CONF_FILE}" > /dev/null
mpssh -f ${CWD}/servers "rm -rf ${SERVER_LOCAL_PATH}/${MONGOS_CONF_FILE}" > /dev/null
mpssh -f ${CWD}/clients "rm -rf ${SERVER_LOCAL_PATH}/${MONGOD_CONF_FILE}" > /dev/null
mpssh -f ${CWD}/clients "rm -rf ${SERVER_LOCAL_PATH}/${MONGOS_CONF_FILE}" > /dev/null

echo -e "${GREEN}Removing MongoDB log files ...${NC}"
mpssh -f ${CWD}/servers "rm -rf ${TMPFS_PATH}/${MONGOD_LOG_FILE}" > /dev/null
mpssh -f ${CWD}/servers "rm -rf ${TMPFS_PATH}/${MONGOS_LOG_FILE}" > /dev/null

echo -e "${GREEN}Done cleaning MongoDB${NC}"
