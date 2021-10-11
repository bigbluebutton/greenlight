#!/bin/bash


for i in "$@"; do
  case $i in
    -a=* | --AWS_PROFILE=*)
    AWS_PROFILE="${i#*=}"
    ;;
  *)
    echo "Usage: sudo ./pushToECR.sh -a= <AWS_PROFILE>"
    exit 1
    ;;
  esac
done

if [[ -z $AWS_PROFILE ]]; then
  echo "`date`: sudo ./pushToECR.sh -a= <AWS_PROFILE>"
  exit 0
fi

echo "`date`-Profile=$AWS_PROFILE: docker build -t db-start-up-checker-service . --no-cache"
docker build -t db-start-up-checker-service . --no-cache

echo "`date`-Profile=$AWS_PROFILE: aws ecr get-login"
`AWS_PROFILE=$AWS_PROFILE aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 065145189516.dkr.ecr.us-east-1.amazonaws.com`

echo "`date`-Profile=$AWS_PROFILE: Tagging the Image"
docker tag db-start-up-checker-service:latest 065145189516.dkr.ecr.us-east-1.amazonaws.com/db-start-up-checker-service:latest

echo "`date`-Profile=$AWS_PROFILE: Pushing the Image"
docker push 065145189516.dkr.ecr.us-east-1.amazonaws.com/db-start-up-checker-service:latest