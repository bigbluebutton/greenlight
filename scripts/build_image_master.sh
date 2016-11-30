#!/bin/bash

docker build -f Dockerfile.prod -t zachblind/castle:master .

docker login -e zachary.chai@blindsidenetworks.com -u $DOCKER_USER -p $DOCKER_PASS
docker push zachblind/castle:master
