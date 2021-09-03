#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ $# < 5 ]]
then
  echo "Usage: $0 {read|write} NUM_PROCS NUM_PARTITIONS NUM_MSGS MSG_SIZE [KAFKA_BOOTSTRAP_SERVER]"
  exit
fi

if [ -f ${CWD}/env.sh ]
then
  source ${CWD}/env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

mode=$1
num_procs=$2
num_partitions=$3
num_msgs=$4
msg_size=$5
if [[ $# > 5 ]]
then
  kafka_bootstrap_server=$6
fi

output=""
for i in `seq 1 ${num_procs}`
do
  if [[ ${mode} == "write" ]]
  then
    ${KAFKA_ROOT_DIR}/bin/kafka-producer-perf-test.sh --topic simple-perf-test-${num_partitions} --throughput -1 --num-records ${num_msgs} --record-size ${msg_size} --producer-props acks=all bootstrap.servers=${kafka_bootstrap_server} > /dev/shm/output_${i} 2>&1 &
  elif [[ ${mode} == "read" ]]
  then
    ${KAFKA_ROOT_DIR}/bin/kafka-consumer-perf-test.sh --topic simple-perf-test-${num_partitions} --messages ${num_msgs} --bootstrap-server=${kafka_bootstrap_server} | jq -R .|jq -sr "map(./\",\")|transpose|map(join(\": \"))[]" > /dev/shm/output_${i} 2>&1 &
  fi
done
wait

for i in `seq 1 ${num_procs}`
do
  cat /dev/shm/output_${i}
done

rm -f /dev/shm/output_*
