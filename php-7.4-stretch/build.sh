#!/bin/bash

set -e

BASE_IMAGE_NAME=scottsmith/php:7.4-stretch
DEVTOOLS_IMAGE_NAME=scottsmith/php:7.4-stretch-devtools

NODE_VERSION=13

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
  --build-arg BASE_IMAGE_NAME=$BASE_IMAGE_NAME \
  .
#
echo ----------
echo Done
