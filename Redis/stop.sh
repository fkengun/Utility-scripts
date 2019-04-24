#!/bin/bash

PWD=~/pkg_src/Utility-scripts/Redis

mpssh -f ${PWD}/servers 'killall redis-server' > /dev/null
echo "Redis is stopped"
