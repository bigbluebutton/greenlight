#!/bin/bash

################################################################################
# For this script to work properly it is required to define some environment variables
# in the CI/CD Env variable declaration, while others should be passed as parameters.
#
#------------------------------------------------------------------------------
# Defined as part of the CD/CI Env Variables:
#
# CD_DOCKER_USERNAME
# A DockerHub username to be used for uploading the build.
#
# CD_DOCKER_PASSWORD
# A DockerHub password to be used for uploading the build.
#
# CD_DOCKER_REPO
# A DockerHub repository. By default the CD_REF_SLUG is also used as the docker repo.
#
# CD_BUILD_ALL
# As the build is supposed to be done only for master (for a nightly deployments) and for releases
# (like 'release-2.0.5' for production deployments), it is additionally required to include this
# variable in order to build any other brnach, as it may be required for testing or reviewing work
# as part of the development process.
#

display_usage() {
  echo "This script should be used as part of a CI strategy."
  echo -e "Usage:\n  build_image.sh [ARGUMENTS]"
  echo -e "\nMandatory arguments \n"
  echo -e "  repo_slug     The git repository  (e.g. bigbluebutton/greenlight)"
  echo -e "\nOptional arguments \n"
  echo -e "  branch | tag  The branch (e.g. master | release-2.0.5)"
}

# if less than two arguments supplied, display usage
if [ $# -le 0 ]; then
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
if [ -z $CD_REF_NAME ]; then
  export CD_REF_NAME=$(git branch | grep \* | cut -d ' ' -f2)
fi

if [ "$CD_REF_NAME" != "master" ] && [[ "$CD_REF_NAME" != *"release"* ]] && ( [ -z "$CD_BUILD_ALL" ] || [ "$CD_BUILD_ALL" != "true" ] ); then
  echo "#### Docker image for $CD_REF_SLUG:$CD_REF_NAME won't be built"
  exit 0
fi

# Include sqlite for production
sqliteCount="$(grep "gem 'sqlite3'" Gemfile | wc -l)"

if [ $sqliteCount -lt 2 ]; then
  sed -i "/^group :production do/a\ \ gem 'sqlite3', '~> 1.3.6'" Gemfile
fi

# Set the version tag when it is a release or the commit sha was included.
if [[ "$CD_REF_NAME" == *"release"* ]]; then
  export CD_VERSION_CODE=${CD_REF_NAME:8}
else
  export CD_VERSION_CODE="$CD_REF_NAME ($(expr substr $(git rev-parse HEAD) 1 7))"
fi

# Build the image
if [ -z $CD_DOCKER_REPO ]; then
  export CD_DOCKER_REPO=$CD_REF_SLUG
fi
echo "#### Docker image $CD_DOCKER_REPO:$CD_REF_NAME is being built"
docker build --build-arg version_code="${CD_VERSION_CODE}" -t $CD_DOCKER_REPO:$CD_REF_NAME .

if [ -z "$CD_DOCKER_USERNAME" ] || [ -z "$CD_DOCKER_PASSWORD" ]; then
  echo "#### Docker image for $CD_DOCKER_REPO can't be published because CD_DOCKER_USERNAME or CD_DOCKER_PASSWORD are missing (Ignore this warning if running outside a CD/CI environment)"
  exit 0
fi

# Publish the image
docker login -u="$CD_DOCKER_USERNAME" -p="$CD_DOCKER_PASSWORD"
echo "#### Docker image $CD_DOCKER_REPO:$CD_REF_NAME is being published"
docker push $CD_DOCKER_REPO

# Publish image as latest and v2 if it is a release (excluding alpha and beta)
if [[ "$CD_REF_NAME" == *"release"* ]] && [[ "$CD_REF_NAME" != *"alpha"* ]] && [[ "$CD_REF_NAME" != *"beta"* ]]; then
  docker_image_id=$(docker images | grep -E "^$CD_DOCKER_REPO.*$CD_REF_NAME" | awk -e '{print $3}')
  docker tag $docker_image_id $CD_DOCKER_REPO:latest
  docker push $CD_DOCKER_REPO:latest
  docker tag $docker_image_id $CD_DOCKER_REPO:v2
  docker push $CD_DOCKER_REPO:v2
fi
exit 0
