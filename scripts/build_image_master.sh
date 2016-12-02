#!/bin/bash

docker build -f Dockerfile.prod -t bigbluebutton/greenlight:master .

docker login -e zachary.chai@blindsidenetworks.com -u $DOCKER_USER -p $DOCKER_PASS
docker push bigbluebutton/greenlight:master

docker logout
