#! /bin/bash
echo "Stopping all running docker containers"
docker stop $(docker ps -a -q)
echo "Removing all docker containers"
docker rm -f $(docker ps -a -q)
echo "Removing all dangling docker images"
docker rmi $(docker images -f "dangling=true" -q)
clear
echo "*****************************"
echo "Here are the remaining images"
echo "*****************************"
docker images
echo "*****************************"
echo "...and the remaining running containers"
echo "*****************************"
docker ps -a