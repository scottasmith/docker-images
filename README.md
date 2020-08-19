# Docker images

A collection of docker images that are on [Docker Hub](https://hub.docker.com/)

# PHP
The PHP image(s) are a custom version of the official PHP images [here](https://github.com/docker-library/php)

## PHP 7.4 Stretch
Apache
```
$ docker run --rm -it -vcomposer-cache:/home/.composer -vnpm-cache:/home/.npm -v`pwd`:/var/www -eUID=`id -u` -eGID=`id -g` scottsmith/php:7.4-stretch-devtools
```

Bash
```
$ docker run --rm -it -vcomposer-cache:/home/.composer -vnpm-cache:/home/.npm -v`pwd`:/var/www -eUID=`id -u` -eGID=`id -g` scottsmith/php:7.4-stretch-devtools sh
```

PHP
```
$ docker run --rm -it -vcomposer-cache:/home/.composer -vnpm-cache:/home/.npm -v`pwd`:/var/www -eUID=`id -u` -eGID=`id -g` scottsmith/php:7.4-stretch-devtools cli
```

## PHP 7.4 Buster
Apache
```
$ docker run --rm -it -vcomposer-cache:/home/.composer -vnpm-cache:/home/.npm -v`pwd`:/var/www -eUID=`id -u` -eGID=`id -g` scottsmith/php:7.4-buster-devtools
```

Bash
```
$ docker run --rm -it -vcomposer-cache:/home/.composer -vnpm-cache:/home/.npm -v`pwd`:/var/www -eUID=`id -u` -eGID=`id -g` scottsmith/php:7.4-buster-devtools sh
```

PHP
```
$ docker run --rm -it -vcomposer-cache:/home/.composer -vnpm-cache:/home/.npm -v`pwd`:/var/www -eUID=`id -u` -eGID=`id -g` scottsmith/php:7.4-buster-devtools cli
``` 
