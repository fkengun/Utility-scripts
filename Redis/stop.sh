#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PWD=~/pkg_src/Utility-scripts/Redis

echo -e "${GREEN}Stopping Redis ...${NC}"
mpssh -f ${PWD}/servers 'killall redis-server' > /dev/null
echo "Redis is stopped"
