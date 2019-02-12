#!/bin/bash

if [ -z $PVFS2TAB_FILE ]
then
  echo "env PVFS2TAB_FILE is not found"
  exit 1
fi
mpssh > /dev/null 2>&1 || { echo >&2 "mpssh is not found.  Aborting."; exit 1; }

PVFS2_HOME="/mnt/common/jji/orangefs-install"
PVFS2_SRC_HOME="/export/home/jji/orangefs_sourcecode/orangefs-2.8.8"
PVFS2_LOCAL_PATH="/home/jji"
TMPFS_PATH="/dev/shm"
PVFS2TAB_FILE=$PVFS2TAB_FILE
MRVIZ_HOME="/mnt/common/jji/RHadoop/hadoop-2.5.0-cdh5.3.3"
MOUNT_POINT="/home/jji/mount_point"

