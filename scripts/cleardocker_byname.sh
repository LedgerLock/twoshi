#! /bin/bash

sudo docker ps -a | grep $1 | awk '{print $1}' | xargs --no-run-if-empty sudo docker rm
clear
echo "*****************************"
echo "Here are the remaining images"
echo "*****************************"
sudo docker images
echo "*****************************"
echo "...and the remaining running containers"
echo "*****************************"
sudo docker ps -a