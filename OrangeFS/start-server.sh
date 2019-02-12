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
CWD="$MRVIZ_HOME/orangefs_scripts"

servers=`awk '{printf("%s,",$1)}' servers`
number=`awk 'END{print NR}' servers`

mpssh -f $CWD/servers "$PVFS2_BIN $CWD/pvfs2-${number}N.conf -f"
mpssh -f $CWD/servers "$PVFS2_BIN $CWD/pvfs2-${number}N.conf"
mpssh -f $CWD/servers "ps -ef | grep pvfs2-server"

sleep 5
$PVFS2_PING -m $MOUNT_POINT
