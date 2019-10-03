#!/bin/bash

if [ -z $PVFS2TAB_FILE ]
then
  echo "env PVFS2TAB_FILE is not found"
  exit 1
fi
mpssh > /dev/null 2>&1 || { echo >&2 "mpssh is not found.  Aborting."; exit 1; }

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PVFS2_HOME="/opt/ohpc/pub/orangefs"
PVFS2_SRC_HOME=""
SERVER_LOCAL_PATH="/mnt/hdd/kfeng"
CLIENT_LOCAL_PATH="/mnt/nvme/kfeng"
TMPFS_PATH="/dev/shm"
PVFS2TAB_FILE_MASTER="/home/kfeng/pkg_src/Utility-scripts/OrangeFS/pvfs2tab"
PVFS2TAB_FILE_CLIENT="/mnt/nvme/kfeng/pvfs2tab"
PVFS2TAB_FILE_SERVER="/mnt/hdd/kfeng/pvfs2tab"
PARENT_DIR=$PVFS2_SRC_HOME
SCRIPT_DIR="OrangeFS_scripts"
MOUNT_POINT=$CLIENT_LOCAL_PATH"/pvfs2-mount"
servers=`awk '{printf("%s,",$1)}' ${CWD}/servers`
number=`awk 'END{print NR}' ${CWD}/servers`
hs_hostname_suffix="-40g"
