#!/usr/bin/env bash

#get latest codes
git pull origin master

docker-compose down

#build local image
# (OMG !! only works with sudo ...)
sudo /bin/bash ./scripts/image_build.sh webconf release-v2

#re-launch container with new image
docker-compose up -d --build

# be sur BBB
bbb-conf –restart
service nginx restart