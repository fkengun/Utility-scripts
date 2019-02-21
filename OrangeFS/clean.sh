#!/bin/bash

if [ -f env.sh ]
then
  source env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

source stop-server.sh

mpssh -f $CWD/servers "rm -rf $TMPFS_PATH/orangefs-server.log"
mpssh -f $CWD/servers "rm -rf $SERVER_LOCAL_PATH/pvfs2-storage-space/*"

