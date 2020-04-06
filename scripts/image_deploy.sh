#!/bin/bash

################################################################################
# For this script to work properly it is required to define some environment variables
# in the CI/CD Env variable declaration, while others should be passed as parameters.
#
#------------------------------------------------------------------------------
# Defined as part of the CD/CI Env Variables:
#
# CD_DEPLOY_SCRIPT
# The script to be used for the actual deployment. If a private repo is used, also the corresponding
# OAuth token will be required. e.g CD_GITHUB_OAUTH_TOKEN when the script is stored in GitHub.
#
# CD_GITHUB_OAUTH_TOKEN
# A GitHub token for granting access to https://github.com/blindsidenetworks/bn-cloud-scripts
#
# CD_DEPLOY_ALL
# As the deployment is supposed to be normaly done only for master (for a nightly deployments) and
# for releases(like 'release-2.0.5' for production deployments), it is additionally required to
# include this variable in order to deploy any other brnach, as it may be required for testing
# or reviewing work as part of development process.
#

echo "v2019022601"

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

if [ -z "$CD_DEPLOY_SCRIPT" ]; then
  echo "#### Script for deployment is not defined, it has to be defined as an ENV variable. [e.g. CD_DEPLOY_SCRIPT=https://example.com/scripts/deploy.sh]"
  exit 0
fi
echo "#### Script for deployment: $CD_DEPLOY_SCRIPT"

export CD_REF_SLUG=$1
export CD_REF_NAME=$2
export CD_COMMIT_SHA=$3
export CD_COMMIT_BEFORE_SHA=$4

if [ -z $CD_REF_SLUG ]; then
  echo "#### Repository not included, it should have been passed as an argument. [e.g. bigbluebutton/greenlight]"
  exit 0
fi

if [ -z $CD_REF_NAME ]; then
  echo "#### Neither branch nor tag were included, the name should have been passed as an argument. [e.g. master|release-2.0.5]"
  exit 0
fi

if [ -z $CD_DOCKER_REPO ]; then
  export CD_DOCKER_REPO=$CD_REF_SLUG
fi

if [ "$CD_REF_NAME" != "master" ] && [[ "$CD_REF_NAME" != *"release"* ]] && ( [ -z $CD_DEPLOY_ALL ] || [ "$CD_DEPLOY_ALL" != "true" ] ); then
  echo "#### Docker image for $CD_DOCKER_REPO won't be deployed. The conditions for running this build were not met."
  exit 0
fi
echo "#### Docker image $CD_DOCKER_REPO:$CD_REF_NAME is being deployed"


# The actual script should be pulled from an external repository
if [ ! -z $CD_GITHUB_OAUTH_TOKEN ]; then
  echo "Script from a github private repo: $CD_DEPLOY_SCRIPT"
  curl -H "Authorization: token $CD_GITHUB_OAUTH_TOKEN" -H "Accept: application/vnd.github.v3.raw" -H "Cache-Control: no-cache" -L $CD_DEPLOY_SCRIPT > deploy.sh
else
  echo "Script from a any other public repo: $CD_DEPLOY_SCRIPT"
  curl -L $CD_DEPLOY_SCRIPT > deploy.sh
fi
chmod +x deploy.sh
./deploy.sh $CD_DOCKER_REPO $CD_REF_NAME $CD_COMMIT_SHA $CD_COMMIT_BEFORE_SHA

exit 0
