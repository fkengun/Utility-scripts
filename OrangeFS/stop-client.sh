#!/bin/bash

if [ -f env.sh ]
then
  source env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

source ~/.bash_aliases

clients=`awk '{printf("%s,",$1)}' clients`


if [[ ! -z $PVFS2_SRC_HOME ]]
then
  #unmount pvfs2
  mpssh -f $CWD/clients "sudo umount -l $MOUNT_POINT"
  mpssh -f $CWD/clients "sudo umount -f $MOUNT_POINT"
  mpssh -f $CWD/clients "sudo umount $MOUNT_POINT"
  #Kill client process
  mpssh -f $CWD/clients "sudo killall -9 pvfs2-client"
  mpssh -f $CWD/clients "sudo killall -9 pvfs2-client-core"
  # remove pvfs2 from kernel
  mpssh -f $CWD/clients "sudo rmmod pvfs2"
else
  mpssh -f $CWD/clients "sudo kill-pvfs2-client"
fi

