#!/bin/bash

mpssh -f servers 'killall redis-server'
