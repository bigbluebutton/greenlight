#!/bin/bash

echo "$DOCKER_DEPLOYMENT"

if [ -z $DOCKER_DEPLOYMENT ]; then
  echo "Docker deployment is not enabled"
  exit 0
fi

display_usage() {
	echo "This script should be used as part of a CI strategy."
	echo -e "Usage:\n  deploy_image.sh [ARGUMENTS]"
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

ref_slug=$1
ref_name=$2

if [ -z $DOCKER_DEPLOY_ALL ] && [ "$ref_name" != "master" ] && [[ "$ref_name" != *"release"* ]]; then
  echo "Docker image for $ref_slug won't be deployed"
  exit 0
fi

echo "Docker image $ref_slug:$ref_name is being deployed"

# These variables used for generalizing the deployment should be pulled from an external repo
GKE_PROJECT="greenlight-cloud"

# The code hereafter should be pulled from an external repository

project=$GKE_PROJECT
