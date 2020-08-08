#!/bin/bash

set -e

BASE_IMAGE_NAME=scottsmith/php:8.0-rc-buster
DEVTOOLS_IMAGE_NAME=scottsmith/php:8.0-rc-buster-devtools

NODE_VERSION=12.18.3
YARN_VERSION=latest

echo "Building docker image ${BASE_IMAGE_NAME}"
#
docker build \
  -t $BASE_IMAGE_NAME \
  -f Dockerfile \
  .
#
echo ----------
echo Done

echo Building docker image $DEVTOOLS_IMAGE_NAME
#
docker build \
  -t $DEVTOOLS_IMAGE_NAME \
  -f Dockerfile.devtools \
  --build-arg NODE_VERSION=$NODE_VERSION \
  --build-arg YARN_VERSION=$YARN_VERSION \
  --build-arg BASE_IMAGE_NAME=$BASE_IMAGE_NAME \
  .
#
echo ----------
echo Done

echo Uploading to registry
#
docker push $BASE_IMAGE_NAME
docker push $DEVTOOLS_IMAGE_NAME
#
echo ----------
echo Done
