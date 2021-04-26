#!/usr/bin/env bash

docker-compose down

#build local image
# (OMG !! only works with sudo ...)
sudo /bin/bash ./scripts/image_build.sh webconf release-v2

#re-launch container with new image
docker-compose up -d --build