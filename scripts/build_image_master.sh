#!/bin/bash

docker build -f Dockerfile.prod -t zachblind/greenlight:master .

docker login -e zachary.chai@blindsidenetworks.com -u $DOCKER_USER -p $DOCKER_PASS
docker push zachblind/greenlight:master

docker logout
