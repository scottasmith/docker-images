#!/bin/bash

function guess_php_image_version() {
    local IMAGE_LINE=''
    local DOCKER_PHP_VERSION=''
    local PHP_VERSION=''
    local PHP_VERSION_SUFFIX=''
    local REPO_NAME=''

    if [[ "x" = "x$PHP_VERSION" && -f docker-compose.yml ]]; then
        IMAGE_LINE=$(grep -Po 'scottsmith/php:.*$' docker-compose.yml)
        PHP_VERSION=$(echo $IMAGE_LINE | sed 's/scottsmith\/php://' | sed 's/-devtools//')

        if [[ "x" = "x$PHP_VERSION" ]]; then
            IMAGE_LINE=$(grep -Po 'scottsmith/php:.*$' docker-compose.yml)
            PHP_VERSION=$(echo $IMAGE_LINE | sed 's/scottsmith\/php://' | sed 's/-devtools//')
        fi
    fi

    if [[ "x" = "x$PHP_VERSION" && -f "composer.json" ]]; then
        VERSION=$(grep -Po '"php": ".*"' composer.json | sed 's/^"php": "^//' | sed 's/"$//')
        PHP_VERSION="${VERSION}"
        PHP_VERSION_SUFFIX="-bullseye"
    fi

    if [ "x" = "x${PHP_VERSION}" ]; then
        return
    fi

    DOCKER_PHP_VERSION="${PHP_VERSION}${PHP_VERSION_SUFFIX}-devtools"

    echo $DOCKER_PHP_VERSION
}

function phpx() {
    local DOCKER_PHP_VERSION=''
    local DOCKER_OPTIONS=''
    local DOCKER_NETWORKS=''

    DOCKER_PHP_VERSION=$(guess_php_image_version)

    if [ "x" = "x$DOCKER_PHP_VERSION" ]; then
        printf "\n \033[41m                                                           \033[0m"
        printf "\n \033[41m Failed to detect the PHP version in the current directory \033[0m"
        printf "\n \033[41m                                                           \033[0m\n\n"

        printf " Have you considered adding to the composer.json or fixing the image docker-composer.yml?\n\n"
        printf " Please use one the php74|php80|php81\n\n"
        return
    fi

    while getopts "xmrcn:p:" opt; do
        case $opt in
            x) DOCKER_OPTIONS="$DOCKER_OPTIONS -eXDEBUG_ENABLED=true "
            ;;
            m) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMONGODB_ENABLED=true "
            ;;
            r) DOCKER_OPTIONS="$DOCKER_OPTIONS -eREDIS_ENABLED=true "
            ;;
            c) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMEMCACHED_ENABLED=true "
            ;;
            p) DOCKER_OPTIONS="$DOCKER_OPTIONS -p$OPTARG"
            ;;
            n) DOCKER_NETWORKS="$DOCKER_NETWORKS,$OPTARG"
            ;;
            \?) echo "Invalid option -$OPTARG" >&2
            ;;
        esac
    done

    _start_php_container "$DOCKER_PHP_VERSION" "$DOCKER_NETWORKS" "$DOCKER_OPTIONS"
}

function php74() {
    local DOCKER_OPTIONS=''
    local DOCKER_NETWORKS=''

    while getopts "xmrcn:p:" opt; do
        case $opt in
            x) DOCKER_OPTIONS="$DOCKER_OPTIONS -eXDEBUG_ENABLED=true "
            ;;
            m) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMONGODB_ENABLED=true "
            ;;
            r) DOCKER_OPTIONS="$DOCKER_OPTIONS -eREDIS_ENABLED=true "
            ;;
            c) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMEMCACHED_ENABLED=true "
            ;;
            p) DOCKER_OPTIONS="$DOCKER_OPTIONS -p$OPTARG"
            ;;
            n) DOCKER_NETWORKS="$DOCKER_NETWORKS,$OPTARG"
            ;;
            \?) echo "Invalid option -$OPTARG" >&2
            ;;
        esac
    done

    _start_php_container "7.4-buster-devtools" "$DOCKER_NETWORKS" "$DOCKER_OPTIONS"
}

function php80() {
    local DOCKER_OPTIONS=''
    local DOCKER_NETWORKS=''

    while getopts "xmrcn:p:" opt; do
        case $opt in
            x) DOCKER_OPTIONS="$DOCKER_OPTIONS -eXDEBUG_ENABLED=true "
            ;;
            m) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMONGODB_ENABLED=true "
            ;;
            r) DOCKER_OPTIONS="$DOCKER_OPTIONS -eREDIS_ENABLED=true "
            ;;
            c) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMEMCACHED_ENABLED=true "
            ;;
            p) DOCKER_OPTIONS="$DOCKER_OPTIONS -p$OPTARG"
            ;;
            n) DOCKER_NETWORKS="$DOCKER_NETWORKS,$OPTARG"
            ;;
            \?) echo "Invalid option -$OPTARG" >&2
            ;;
        esac
    done

    _start_php_container "8.0-bullseye-devtools" "$DOCKER_NETWORKS" "$DOCKER_OPTIONS"
}

function php81() {
    local DOCKER_OPTIONS=''
    local DOCKER_NETWORKS=''

    while getopts "xmrcn:p:" opt; do
        case $opt in
            x) DOCKER_OPTIONS="$DOCKER_OPTIONS -eXDEBUG_ENABLED=true "
            ;;
            m) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMONGODB_ENABLED=true "
            ;;
            r) DOCKER_OPTIONS="$DOCKER_OPTIONS -eREDIS_ENABLED=true "
            ;;
            c) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMEMCACHED_ENABLED=true "
            ;;
            p) DOCKER_OPTIONS="$DOCKER_OPTIONS -p$OPTARG"
            ;;
            n) DOCKER_NETWORKS="$DOCKER_NETWORKS,$OPTARG"
            ;;
            \?) echo "Invalid option -$OPTARG" >&2
            ;;
        esac
    done

    _start_php_container "8.1-bullseye-devtools" "$DOCKER_NETWORKS" "$DOCKER_OPTIONS"
}

function _start_php_container() {
    PHP_VERSION=$1
    DOCKER_NETWORKS="web,$2,"
    DOCKER_OPTIONS="$3"
    IMAGE="scottsmith/php:${PHP_VERSION}"
    PWD=$(pwd)

    printf "\n\033[1;34mBinding directory to /var/www:\033[0m $PWD\n"
    printf "\033[1;34mUsing Docker image:\033[0m $IMAGE\n\n"
    printf " \033[0;32m* Creating container \033[0m"

    CONTAINER_INSTANCE=$(
    docker run \
        --rm \
        -itd \
        -vcomposer-cache:/home/.composer \
        -vnpm-cache:/home/.npm \
        -v$PWD:/var/www \
        `echo $DOCKER_OPTIONS` \
        -eUID=`id -u` \
        -eGID=`id -g` \
        $IMAGE \
        bash
    )

    printf " \033[0;32m - instance ${CONTAINER_INSTANCE}\033[0m\n"

    if [ "x${DOCKER_NETWORKS}" != "x" ]; then
        printf " \033[0;32m* Adding networks\033[0m\n"
        while IFS= read -r -d ',' DOCKER_NETWORK;
        do
            if [ "x${DOCKER_NETWORK}" != "x" ]; then
                docker network connect $DOCKER_NETWORK $CONTAINER_INSTANCE
            fi
        done < <(echo $DOCKER_NETWORKS)
    fi

    printf " \033[0;32m* Starting container\033[0m\n\n"
    printf "\033[1;34mIf you don't see a comand prompt, please press enter\033[0m\n\n"

    docker start -ai $CONTAINER_INSTANCE
    docker stop $CONTAINER_INSTANCE > /dev/null 2>&1
}

function nodevuecli() {
    IMAGE="scottsmith/node:16-vuecli"
    PWD=$(pwd)

    printf "\n\033[1;34mBinding directory to /var/www:\033[0m $PWD\n"
    printf "\033[1;34mUsing Docker image:\033[0m $IMAGE\n\n"
    printf " \033[0;32m* Creating container \033[0m"

    docker run \
      --rm \
      -it \
      -vnpm-cache:/home/.npm \
      -v$PWD:/var/www \
      -eUID=`id -u` \
      -eGID=`id -g` \
      $IMAGE \
      bash
}

