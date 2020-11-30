@ECHO OFF

SET BASE_IMAGE_NAME=scottsmith/php:8.0-buster
SET DEVTOOLS_IMAGE_NAME=scottsmith/php:8.0-buster-devtools

SET NODE_VERSION=v12.18.3
SET YARN_VERSION=latest

ECHO Building docker image %BASE_IMAGE_NAME%
docker build -t %BASE_IMAGE_NAME% .
ECHO ----------
ECHO Done

ECHO Building docker image %DEVTOOLS_IMAGE_NAME%
docker build -t %DEVTOOLS_IMAGE_NAME% -f Dockerfile.devtools --build-arg NODE_VERSION=%NODE_VERSION% --build-arg YARN_VERSION=%YARN_VERSION% --build-arg BASE_IMAGE_NAME=%BASE_IMAGE_NAME% .
ECHO ----------
ECHO Done
