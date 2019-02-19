#!/bin/bash

if [ -f env.sh ]
then
  source env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

PVFS2_GENCONFIG="$PVFS2_HOME/bin/pvfs2-genconfig"
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

servers=`awk '{printf("%s,",$1)}' servers`
number=`awk 'END{print NR}' servers`

$PVFS2_GENCONFIG --quiet --protocol tcp --ioservers $servers --metaservers $servers --storage $PVFS2_LOCAL_PATH/pvfs2-storage-space --metadata $PVFS2_LOCAL_PATH/pvfs2-storage-space --logfile $TMPFS_PATH/orangefs-server.log $CWD/pvfs2-${number}N.conf

if [ "$1" == "sync" ]
then
    sed -i "s/TroveSyncData.*/TroveSyncData yes/" $CWD/pvfs2-${number}N.conf
fi

clients=`cat clients | awk '{print $1}'`
count=0
for client in ${client[@]}
do
  metadata_server=`head -$count servers | tail -1`
  ssh client "echo 'tcp://$metadata_server:3334/orangefs $MOUNT_POINT pvfs2 defaults,auto 0 0' > \$PVFS2TAB_FILE"
  ((count=$count+1))
done

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
