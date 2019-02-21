#!/bin/bash

if [ -f env.sh ]
then
  source env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

PVFS2_GENCONFIG="$PVFS2_HOME/bin/pvfs2-genconfig"

$PVFS2_GENCONFIG --quiet --protocol tcp --ioservers $servers --metaservers $servers --storage $SERVER_LOCAL_PATH/pvfs2-storage-space --metadata $SERVER_LOCAL_PATH/pvfs2-storage-space --logfile $TMPFS_PATH/orangefs-server.log $CWD/pvfs2-${number}N.conf

if [ "$1" == "sync" ]
then
    sed -i "s/TroveSyncData.*/TroveSyncData yes/" $CWD/pvfs2-${number}N.conf
fi

client_list=`cat clients | awk '{print $1}'`
count=1
for client in ${client_list[@]}
do
  metadata_server=`head -$count servers | tail -1`
  metadata_server_ip=`getent hosts ${metadata_server}${hs_hostname_suffix} | awk '{print $1}'`
  ssh $client "echo 'tcp://$metadata_server_ip:3334/orangefs $MOUNT_POINT pvfs2 defaults,auto 0 0' > $PVFS2TAB_FILE" &
  ((count=$count+1))
done
wait

# sync files only on Chameleon
if [ "$USER" == "cc" ]
then
  server_list=`cat servers | awk '{print $1}'`
  for node in ${server_list[@]}
  do
    rsync -az $CWD/pvfs2-${number}N.conf $node:$CWD/pvfs2-${number}N.conf
    rsync -az $PVFS2TAB_FILE $node:$PVFS2TAB_FILE
  done
fi
