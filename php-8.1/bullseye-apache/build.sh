#!/bin/bash

set -e

BASE_IMAGE_NAME=scottsmith/php:8.1-bullseye
DEVTOOLS_IMAGE_NAME=scottsmith/php:8.1-bullseye-devtools

echo "Building docker image ${BASE_IMAGE_NAME}"

docker build \
  -t $BASE_IMAGE_NAME \
  -f Dockerfile \
  .

echo ----------
echo Done

echo Building docker image $DEVTOOLS_IMAGE_NAME

docker build \
  -t $DEVTOOLS_IMAGE_NAME \
  -f Dockerfile.devtools \
  --build-arg BASE_IMAGE_NAME=$BASE_IMAGE_NAME \
  .

echo ----------
echo Done
