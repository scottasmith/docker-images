@ECHO OFF

SET BASE_IMAGE_NAME=scottsmith/php:7.4-stretch
SET DEVTOOLS_IMAGE_NAME=scottsmith/php:7.4-stretch-devtools

SET NODE_VERSION=13
SET YARN_VERSION=1.22.4

ECHO Building docker image %BASE_IMAGE_NAME%
docker build -t %BASE_IMAGE_NAME% .
ECHO ----------
ECHO Done

ECHO Building docker image %DEVTOOLS_IMAGE_NAME%
docker build -t %DEVTOOLS_IMAGE_NAME% -f Dockerfile.devtools --build-arg NODE_VERSION=%NODE_VERSION% --build-arg YARN_VERSION=%YARN_VERSION% --build-arg BASE_IMAGE_NAME=%BASE_IMAGE_NAME% .
ECHO ----------
ECHO Done

ECHO Uploading to registry
docker push %BASE_IMAGE_NAME%
docker push %DEVTOOLS_IMAGE_NAME%
ECHO ----------
ECHO Done
