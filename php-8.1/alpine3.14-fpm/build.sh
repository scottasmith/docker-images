#!/bin/bash

set -e

IMAGE_NAME=scottsmith/php:8.1-alpine3.14-fpm

echo "Building docker image ${IMAGE_NAME}"
#
docker build \
  -t $IMAGE_NAME \
  -f Dockerfile \
  .
#
echo ----------
echo Done
