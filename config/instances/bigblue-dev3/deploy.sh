#!/bin/bash

INSTANCE_NAME="bigblue-dev3"
CONTAINER_NAME="bigblue-dev3"
RELEASE_NAME="release-v2"
DEPLOY_ROOT_DIR="/opt/grandbleu"

DEPLOY_DIR="$DEPLOY_ROOT_DIR/$INSTANCE_NAME"
INSTANCE_CONFIG_DIR="$DEPLOY_DIR/config/instances/$INSTANCE_NAME"
CURRENT_DIR=$(pwd)

PUBLIC_DIR="$DEPLOY_DIR/public/"
PUBLIC_DIR_ALL="$PUBLIC_DIR*"
IMAGES_DIR_ALL="$INSTANCE_CONFIG_DIR/images/*"
SASS_VAR_CONFIG="$INSTANCE_CONFIG_DIR/sass/_variables.scss"
SASS_VAR_DEPLOY="$DEPLOY_DIR/app/assets/stylesheets/utilities/_variables.scss"

echo ""
echo "*********************************"
echo "* Deploying bigBLUE instance  : * $INSTANCE_NAME to $DEPLOY_DIR - target container: $CONTAINER_NAME:$RELEASE_NAME ..."
echo "*********************************"
cd $DEPLOY_DIR || { echo "DEPLOY_DIR $DEPLOY_DIR does not exist! Exiting." && exit 1; }

echo ""
echo "  1 - Cleaning ..."
rm -r $PUBLIC_DIR_ALL
rm $SASS_VAR_DEPLOY
git stash

echo "  2 - GIT pull ..."
git pull -a

echo "  3 - Copying from instance config to target locations ..."
cp -r $IMAGES_DIR_ALL $PUBLIC_DIR
cp $SASS_VAR_CONFIG $SASS_VAR_DEPLOY

echo "  4 - Rebuilding and Relaunching Docker Container ..."
cd $DEPLOY_DIR && docker-compose down && ./scripts/image_build.sh $CONTAINER_NAME $RELEASE_NAME && docker-compose up -d

cd $CURRENT_DIR || exit 2

echo ""
echo "..Done."
echo ""
echo "*********************************"

exit 0