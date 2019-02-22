#!/bin/bash

echo "v1"

display_usage() {
  echo "This script should be used as part of a CI strategy."
  echo -e "Usage:\n  build_image.sh [ARGUMENTS]"
  echo -e "\nMandatory arguments \n"
  echo -e "  repo_slug     The git repository  (e.g. bigbluebutton/greenlight)"
  echo -e "  branch | tag  The branch (e.g. master | release-2.0.5)"
  echo -e "  commit_sha    The sha for the current commit (e.g. 750615dd479c23c8873502d45158b10812ea3274)"
}

# if less than two arguments supplied, display usage
if [ $# -le 1 ]; then
	display_usage
	exit 1
fi

# check whether user had supplied -h or --help . If yes display usage
if [[ ($# == "--help") ||  $# == "-h" ]]; then
	display_usage
	exit 0
fi

export CD_REF_SLUG=$1
export CD_REF_NAME=$2
export CD_COMMIT_SHA=$3

if [ "$CD_REF_NAME" != "master" ] && [[ "$CD_REF_NAME" != *"release"* ]] && [ -z $CD_BUILD_ALL ];then
  echo "Docker image for $CD_REF_SLUG won't be built"
  exit 0
fi

# Set the version tag when it is a release or the commit sha was included.
if [[ "$CD_REF_NAME" == *"release"* ]]; then
  sed -i "s/VERSION =.*/VERSION = \"$(expr substr $CD_REF_NAME 9)\"/g" config/initializers/version.rb
elif [ ! -z $CD_COMMIT_SHA ]; then
  sed -i "s/VERSION =.*/VERSION = \"$CD_REF_NAME ($(expr substr $CD_COMMIT_SHA 1 8))\"/g" config/initializers/version.rb
fi
# Build the image
echo "Docker image $CD_REF_SLUG:$CD_REF_NAME is being built"
docker build -t $CD_REF_SLUG:$CD_REF_NAME .

if [ -z "$CD_DOCKER_USERNAME" ] || [ -z "$CD_DOCKER_PASSWORD" ]; then
  echo "Docker image for $CD_REF_SLUG can't be published because CD_DOCKER_USERNAME or CD_DOCKER_PASSWORD are missing"
  exit 0
fi

# Publish the image
docker login -u="$CD_DOCKER_USERNAME" -p="$CD_DOCKER_PASSWORD"
echo "Docker image $CD_REF_SLUG:$CD_REF_NAME is being published"
docker push $CD_REF_SLUG:$CD_REF_NAME

# Publish latest and v2 if it id a release
echo $build_digest
if [[ "$CD_REF_NAME" == *"release"* ]]; then
  docker_image_id=$(docker images | grep -E "^$CD_REF_SLUG.*$CD_REF_NAME" | awk -e '{print $3}')
  docker tag $docker_image_id $CD_REF_SLUG:latest
  docker push $CD_REF_SLUG:latest
  docker tag $docker_image_id $CD_REF_SLUG:v2
  docker push $CD_REF_SLUG:v2
fi
exit 0
