#!/bin/bash

echo "v1.0.1"

if [ -z "$CD_DEPLOY_SCRIPT" ]; then
  echo "Script for deployment is not defined"
  exit 0
fi
echo "Source for deployment script: $CD_DEPLOY_SCRIPT"

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
export CD_COMMIT_BEFORE_SHA=$4


if [ -z $CD_DEPLOY_SCRIPT ]; then
  echo "Source for deployment script is not defined"
  exit 0
fi

if [ -z $CD_REF_SLUG ]; then
  echo "Repository not included [e.g. bigbluebutton/greenlight]"
  exit 0
fi

if [ -z $CD_REF_NAME ]; then
  echo "Neither branch nor tag were included [e.g. master|release-2.0.5]"
  exit 0
fi

# It deploys only master and releases unless CD_DEPLOY_ALL is included
if [ -z $DEPLOY_ALL ] && [ "$CD_REF_NAME" != "master" ] && [[ "$CD_REF_NAME" != *"release"* ]]; then
  echo "Docker image for $CD_REF_SLUG won't be deployed"
  exit 0
fi

echo "Docker image $CD_REF_SLUG:$CD_REF_NAME is being deployed"

# The actual script should be pulled from an external repository
if [ ! -z $CD_GITHUB_OAUTH_TOKEN ]; then
  echo "Script from a github private repo: $CD_DEPLOY_SCRIPT"
  curl -H "Authorization: token $CD_GITHUB_OAUTH_TOKEN" -H "Accept: application/vnd.github.v3.raw" -H "Cache-Control: no-cache" -L $CD_DEPLOY_SCRIPT > deploy.sh
else
  echo "Script from a any other public repo: $CD_DEPLOY_SCRIPT"
  curl -L $CD_DEPLOY_SCRIPT > deploy.sh
fi

chmod +x deploy.sh
./deploy.sh $CD_REF_SLUG $CD_REF_NAME $CD_COMMIT_SHA $CD_COMMIT_BEFORE_SHA

exit 0
