#!/usr/bin/env bash

display_usage() {
	echo "This script should be used as part of a CI strategy."
	echo -e "Usage:\n  build_image.sh [ARGUMENTS]"
  echo -e "\nMandatory arguments \n"
  echo -e "  repo_slug        The git repository  (e.g. bigbluebutton/greenlight)"
  echo -e "  branch           The branch (e.g. master)"
  echo -e "\nOptional arguments \n"
  echo -e "  tag              The tag that should include the word 'release' (e.g. release-2.0.5)"
}

# if less than two arguments supplied, display usage
if [  $# -le 1 ]; then
	display_usage
	exit 1
fi

# check whether user had supplied -h or --help . If yes display usage
if [[ ( $# == "--help") ||  $# == "-h" ]]; then
	display_usage
	exit 0
fi

REPO_SLUG=$1
BRANCH=$2
TAG=$3

if [ ! -z "$TAG" ] && [ "$TAG" == *"release"* ]; then
  IMAGE=$REPO_SLUG:$TAG
elif [ "$BRANCH" == "master" ]; then
  IMAGE=$REPO_SLUG:$BRANCH
fi

if [ ! -z "$IMAGE" ]; then
  echo "Docker image $IMAGE is being built"
  #docker build -t $IMAGE .
else
  echo "Docker image for $REPO_SLUG won't be built"
fi

if [ ! -z "$DOCKER_USERNAME" ] && [ ! -z "$DOCKER_PASSWORD" ]; then
  docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
  echo "Docker image $IMAGE is being published"
  docker push $IMAGE
else
  echo "Docker image for $REPO_SLUG can't be published"
fi
