#!/bin/bash

PVFS2TAB_FILE=/home/kfeng/pkg_src/orangefs-2.9.7/OrangeFS_scripts/pvfs2tab
if [ -z $PVFS2TAB_FILE ]
then
  echo "env PVFS2TAB_FILE is not found"
  exit 1
fi
mpssh > /dev/null 2>&1 || { echo >&2 "mpssh is not found.  Aborting."; exit 1; }

PVFS2_HOME="/home/kfeng/install"
PVFS2_SRC_HOME="/home/kfeng/pkg_src/orangefs-2.9.7"
SERVER_LOCAL_PATH="/mnt/hdd/kfeng"
CLIENT_LOCAL_PATH="/mnt/nvme/kfeng"
TMPFS_PATH="/dev/shm"
PVFS2TAB_FILE=$PVFS2TAB_FILE
PARENT_DIR=$PVFS2_SRC_HOME
SCRIPT_DIR="OrangeFS_scripts"
MOUNT_POINT=$CLIENT_LOCAL_PATH"/pvfs2-mount"
