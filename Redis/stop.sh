#!/bin/bash

mpssh -f servers 'killall redis-server' > /dev/null
echo "Redis is stopped"
