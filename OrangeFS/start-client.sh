#!/bin/bash

if [ -f env.sh ]
then
  source env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

if [ "$#" -eq 1 ]
then
  if [ "$1" == "ib" ]
  then
    proto="ib"
    port=3335
  elif [ "$1" == "tcp" ]
  then
    proto="tcp"
    port=3334
  else
    echo "unrecognized protocol: $1, supported protocols: tcp and ib, quiting ..."
    exit
  fi
else
  proto="tcp"
  port=3334
fi

source ~/.bash_aliases

if [[ ! -z $PVFS2_SRC_HOME ]]
then
  KERNEL_DIR="$PVFS2_SRC_HOME/src/kernel/linux-2.6"
  CLIENT_DIR="$PVFS2_SRC_HOME/src/apps/kernel/linux"
else
  KERNEL_DIR="$PVFS2_HOME/lib/modules/`uname -r`/kernel/fs/pvfs2"
  CLIENT_DIR="$PVFS2_HOME/sbin"
fi

clients=`awk '{print $1}' clients`

#insert pvfs2 module into kernel
mpssh -f $CWD/clients "sudo insmod $KERNEL_DIR/pvfs2.ko"

#start pvfs2 client
mpssh -f $CWD/clients "sudo $CLIENT_DIR/pvfs2-client -p $CLIENT_DIR/pvfs2-client-core"

#mount pvfs2
nservers=`cat servers | wc -l`
i=1
for node in ${clients[@]}
do
  meta_server=`head -$i servers | tail -1`
  ssh $node "sudo mount -t pvfs2 $proto://$meta_server:$port/orangefs $MOUNT_POINT"
  ((i=$i+1))
  if [ "$i" -gt "$nservers" ]
  then
    i=1
  fi
done

#check mounted pvfs2
mpssh -f $CWD/clients "mount | grep pvfs"
