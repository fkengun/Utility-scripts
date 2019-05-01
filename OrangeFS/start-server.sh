#!/bin/bash

if [ -f env.sh ]
then
  source env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

source ~/.bash_aliases

PVFS2_BIN="$PVFS2_HOME/sbin/pvfs2-server"
PVFS2_PING="$PVFS2_HOME/bin/pvfs2-ping"

mpssh -f $CWD/servers "$PVFS2_BIN $CWD/pvfs2-${number}N.conf -f"
mpssh -f $CWD/servers "$PVFS2_BIN $CWD/pvfs2-${number}N.conf"
mpssh -f $CWD/servers "pgrep -a pvfs2-server"

sleep 5
mpssh -f $CWD/clients "export LD_LIBRARY_PATH=$PVFS2_HOME/lib; export PVFS2TAB_FILE=$PVFS2TAB_FILE_CLIENT; $PVFS2_PING -m $MOUNT_POINT | grep 'appears to be correctly configured'" | sort
