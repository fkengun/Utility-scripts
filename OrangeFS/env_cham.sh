#!/bin/bash

if [ -z $PVFS2TAB_FILE ]
then
  echo "env PVFS2TAB_FILE is not found"
  exit 1
fi
mpssh > /dev/null 2>&1 || { echo >&2 "mpssh is not found.  Aborting."; exit 1; }

PVFS2_HOME="/home/cc/install"
PVFS2_SRC_HOME="/home/cc/pkg_src/orangefs-2.9.5"
PVFS2_LOCAL_PATH="/home/cc"
TMPFS_PATH="/dev/shm"
PVFS2TAB_FILE=$PVFS2TAB_FILE
MRVIZ_HOME="/home/cc/pkg_src/mrviz-with-porthadoop"
MOUNT_POINT="/mnt/orangefs"
