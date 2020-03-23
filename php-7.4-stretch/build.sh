#!/bin/bash

set -e

BASE_IMAGE_NAME=scottsmith/php:7.4-stretch
DEVTOOLS_IMAGE_NAME=scottsmith/php:7.4-stretch-devtools

NODE_VERSION=13
YARN_VERSION=1.22.4

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
