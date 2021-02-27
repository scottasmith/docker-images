#!/usr/bin/env bash

function php74() {
    DOCKER_OPTIONS=
    while getopts "xmn:p:" opt; do
        case $opt in
            x) DOCKER_OPTIONS="$DOCKER_OPTIONS -eXDEBUG_ENABLED=true "
            ;;
            m) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMONGODB_ENABLED=true "
            ;;
            p) DOCKER_OPTIONS="$DOCKER_OPTIONS -p$OPTARG"
            ;;
            n) DOCKER_OPTIONS="$DOCKER_OPTIONS --network $OPTARG"
            ;;
            \?) echo "Invalid option -$OPTARG" >&2
            ;;
        esac
    done

    docker run \
        --rm \
        -it \
        -vcomposer-cache:/home/.composer \
        -vnpm-cache:/home/.npm \
        -v`pwd`:/var/www \
        `echo $DOCKER_OPTIONS` \
        -eUID=`id -u` \
        -eGID=`id -g` \
        scottsmith/php:7.4-buster-devtools \
        sh
}

function php80() {
    DOCKER_OPTIONS=
    while getopts "xmn:p:" opt; do
        case $opt in
            x) DOCKER_OPTIONS="$DOCKER_OPTIONS -eXDEBUG_ENABLED=true "
            ;;
            m) DOCKER_OPTIONS="$DOCKER_OPTIONS -eMONGODB_ENABLED=true "
            ;;
            p) DOCKER_OPTIONS="$DOCKER_OPTIONS -p$OPTARG"
            ;;
            n) DOCKER_OPTIONS="$DOCKER_OPTIONS --network $OPTARG"
            ;;
            \?) echo "Invalid option -$OPTARG" >&2
            ;;
        esac
    done

    docker run \
        --rm \
        -it \
        -vcomposer-cache:/home/.composer \
        -vnpm-cache:/home/.npm \
        -v`pwd`:/var/www \
        `echo $DOCKER_OPTIONS` \
        -eUID=`id -u` \
        -eGID=`id -g` \
        scottsmith/php:8.0-buster-devtools \
        sh
}
