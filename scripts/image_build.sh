#!/bin/bash

display_usage() {
  echo "This script should be used as part of a CI strategy."
  echo -e "Usage:\n  build_image.sh [ARGUMENTS]"
  echo -e "\nMandatory arguments \n"
  echo -e "  repo_slug        The git repository  (e.g. bigbluebutton/greenlight)"
  echo -e "  branch | tag     The branch (e.g. master | release-2.0.5)"
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

REF_SLUG=$1
REF_NAME=$2

if [ ! -z $CD_BUILD_ALL ] || [ "$REF_NAME" == "master" ] || [[ "$REF_NAME" == *"release"* ]]; then
  echo "Docker image $REF_SLUG:$REF_NAME is being built"
  if [[ "$REF_NAME" == *"release"* ]]; then
    VERSION="$(expr substr $REF_NAME 9)"
  elif [ ! -z $CD_COMMIT_SHA ]; then
    VERSION="$REF_NAME ($(expr substr $CD_COMMIT_SHA 1 8))"
  else
    VERSION="$REF_NAME (manual)"
  fi
  echo $VERSION
  sed -i "s/VERSION =.*/VERSION = \"$VERSION\"/g" config/initializers/version.rb
  docker build -t $REF_SLUG:$REF_NAME .
else
  echo "Docker image for $REF_SLUG won't be built"
  exit 0
fi

if [ ! -z "$CD_DOCKER_USERNAME" ] && [ ! -z "$CD_DOCKER_PASSWORD" ]; then
  docker login -u="$CD_DOCKER_USERNAME" -p="$CD_DOCKER_PASSWORD"
  echo "Docker image $REF_SLUG:$REF_NAME is being published"
  docker push $REF_SLUG:$REF_NAME
else
  echo "Docker image for $REF_SLUG can't be published because CD_DOCKER_USERNAME or CD_DOCKER_PASSWORD are missing"
  exit 0
fi
