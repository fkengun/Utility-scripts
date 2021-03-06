#!/bin/bash

if [ -z $PVFS2TAB_FILE ]
then
  echo "env PVFS2TAB_FILE is not found"
  exit 1
fi
mpssh > /dev/null 2>&1 || { echo >&2 "mpssh is not found.  Aborting."; exit 1; }

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PVFS2_HOME="/mnt/common/jji/orangefs-install"
PVFS2_SRC_HOME="/export/home/jji/orangefs_sourcecode/orangefs-2.8.8"
SERVER_LOCAL_PATH="/mnt/hdd/kfeng"
SERVER_LOCAL_STOR_DIR="${SERVER_LOCAL_PATH}/pvfs2-storage-space"
CLIENT_LOCAL_PATH="/mnt/ssd/kfeng"
MOUNT_POINT="${CLIENT_LOCAL_PATH}/pvfs2-mount"
TMPFS_PATH="/dev/shm"
SERVER_LOG_FILE="${TMPFS_PATH}/orangefs-server.log"
PVFS2TAB_FILE_MASTER=""
PVFS2TAB_FILE_CLIENT="/mnt/ssd/kfeng/pvfs2tab"
PVFS2TAB_FILE_SERVER="/mnt/hdd/kfeng/pvfs2tab"
STRIPE_SIZE="65536"
PARENT_DIR=${PVFS2_SRC_HOME}
SCRIPT_DIR="OrangeFS_scripts"
servers=`awk '{printf("%s,",$1)}' ${CWD}/servers`
number=`awk 'END{print NR}' ${CWD}/servers`
hs_hostname_suffix=""
dist_name="simple_stripe"
dist_params="strip_size:${STRIPE_SIZE}"
comm_port="3334"
