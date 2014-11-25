#! /bin/bash

sudo docker ps -a | grep $1 | awk '{print $1}' | xargs --no-run-if-empty sudo docker rm
