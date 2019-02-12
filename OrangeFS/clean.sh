#!/bin/bash

source stop-server.sh

mpssh -f $CWD/servers "rm -rf $TMPFS_PATH/orangefs-server.log"
mpssh -f $CWD/servers "rm -rf $PVFS2_LOCAL_PATH/pvfs2-storage-space/*"

