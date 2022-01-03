#!/bin/bash

set -e

IMAGE_NAME=scottsmith/node:16-vuecli

echo "Building docker image ${IMAGE_NAME}"

docker build \
  -t $IMAGE_NAME \
  -f Dockerfile \
  .

echo ----------
echo Done

