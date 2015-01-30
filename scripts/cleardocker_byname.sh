#! /bin/bash

docker ps -a | grep $1 | awk '{print $1}' | xargs --no-run-if-empty docker rm
clear
echo "*****************************"
echo "Here are the remaining images"
echo "*****************************"
docker images
echo "*****************************"
echo "...and the remaining running containers"
echo "*****************************"
docker ps -a