#!/bin/bash

echo "Script for deployment: $CD_DEPLOY_SCRIPT v16"

if [ -z $CD_DEPLOY_SCRIPT ]; then
  echo "Script for deployment is not defined"
  exit 0
fi

if [ -z $CD_DEPLOY_ENV ]; then
  echo "Deployment environment not specified [e.g. development|staging|production]"
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
if [ -z $CD_DEPLOY_ALL ] && [ "$CD_REF_NAME" != "master" ] && [[ "$CD_REF_NAME" != *"release"* ]]; then
  echo "Docker image for $CD_REF_SLUG won't be deployed"
  exit 0
fi

echo "Docker image $CD_REF_SLUG:$CD_REF_NAME is being deployed for $CD_DEPLOY_ENV"

# The actual script should be pulled from an external repository
if [ ! -z $CD_GITHUB_OAUTH_TOKEN ]; then
  echo "Script from a github private repo: $CD_DEPLOY_SCRIPT"
  curl -H "Authorization: token $CD_GITHUB_OAUTH_TOKEN" -H "Accept: application/vnd.github.v3.raw" -H "Cache-Control: no-cache" -L $CD_DEPLOY_SCRIPT > deploy.sh
  chmod +x deploy.sh
  ./deploy.sh
else
  echo "Script from a any other public repo: $CD_DEPLOY_SCRIPT"
  wget -O - $CD_DEPLOY_SCRIPT | bash $CD_DEPLOY_ENV $CD_REF_SLUG $CD_REF_NAME
fi
