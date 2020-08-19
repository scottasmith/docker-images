@ECHO OFF

SET BASE_IMAGE_NAME=scottsmith/php:7.4-stretch
SET DEVTOOLS_IMAGE_NAME=scottsmith/php:7.4-stretch-devtools

SET NODE_VERSION=13

ECHO Building docker image %BASE_IMAGE_NAME%
docker build -t %BASE_IMAGE_NAME% .
ECHO ----------
ECHO Done

ECHO Building docker image %DEVTOOLS_IMAGE_NAME%
docker build -t %DEVTOOLS_IMAGE_NAME% -f Dockerfile.devtools --build-arg NODE_VERSION=%NODE_VERSION% --build-arg BASE_IMAGE_NAME=%BASE_IMAGE_NAME% .
ECHO ----------
ECHO Done
