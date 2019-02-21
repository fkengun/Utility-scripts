#!/bin/bash

if [ -f env.sh ]
then
  source env.sh
else
  echo "env.sh does not exist, quiting ..."
  exit
fi

source ~/.bash_aliases

mpssh -f $CWD/servers "killall -9 pvfs2-server"
mpssh -f $CWD/servers "ps -ef | grep pvfs2-server"

