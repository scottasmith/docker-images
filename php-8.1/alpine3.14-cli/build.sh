#!/bin/bash

set -e

BASE_IMAGE_NAME=scottsmith/php:8.1-alpine3.14-cli
DEVTOOLS_IMAGE_NAME=scottsmith/php:8.1-alpine3.14-cli-devtools

echo "Building docker image ${IMAGE_NAME}"
#
docker build \
  -t $BASE_IMAGE_NAME \
  -f Dockerfile \
  .
#
echo Building docker image $DEVTOOLS_IMAGE_NAME
#
docker build \
  -t $DEVTOOLS_IMAGE_NAME \
  -f Dockerfile.devtools \
  --build-arg BASE_IMAGE_NAME=$BASE_IMAGE_NAME \
  .
#
echo ----------
echo Done
