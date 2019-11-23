#!/bin/bash

image_name=cambioscience/greenlight
image_version=release-v2

cd /home/ubuntu/greenlight

echo "Building image: $image_name for version: $image_version"

./scripts/image_build.sh $image_name $image_version

echo "End of building image $image_name:$image_version"

echo "Stopping containers"
sudo docker-compose down

echo "Removing dangling images"
sudo docker rmi $(sudo docker images -f dangling=true -q)

echo "Running containers"
sudo docker-compose up -d

echo "Restaring nginx"
sudo service nginx restart

echo "End of deployment"
