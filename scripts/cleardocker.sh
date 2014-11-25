#! /bin/bash
echo "Stopping all running docker containers"
sudo docker stop $(sudo docker ps -a -q)
echo "Removing all docker containers"
sudo docker rm -f $(sudo docker ps -a -q)
echo "Removing all dangling docker images"
sudo docker rmi $(sudo docker images -f "dangling=true" -q)
echo "Here are the remaining images"
sudo docker images
