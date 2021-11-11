# PHP 8.0.*
The PHP image(s) are a custom version of the official PHP images [here](https://github.com/docker-library/php)

This comprises of two images. One being for servers (live, dev, stg) and one for local.

- **scottsmith/php:8.8.\*** - These two contain all of the features on this page
- **scottsmith/php:8.0.\*-devtools** - Everything in the above plus NodeJS and Composer

Both images allow to bind the the `/var/www` directory

The devtools image allows to bind the following mountpoints for caching:
- /home/.composer
- /home/.npm

eg.

`docker run --rm -it -vcomposer-cache:/home/.composer -vnpm-cache:/home/.npm -v $(pwd):/var/www scottsmith/php:8.0-stretch-devtools`

There are two entrypoints to override the default apache:

`docker run --rm -it -vcomposer-cache:/home/.composer -vnpm-cache:/home/.npm -v $(pwd):/var/www scottsmith/php:8.0-stretch-devtools bash`

for bash, and

`docker run --rm -it -vcomposer-cache:/home/.composer -vnpm-cache:/home/.npm -v $(pwd):/var/www scottsmith/php:8.0-stretch-devtools php`

for php cli

## Environment Variables
`XDEBUG_ENABLED`

Default: `false`
This is optional and when set displays xdebug

`XDEBUG_CLIENT_HOST`

Default: `host.docker.internal`
Set to the location (host or IP) of the IDE

`XDEBUG_CLIENT_PORT`

Default: `48000`
Set to the port the IDE is listening on

`XDEBUG_DISCOVER_CLIENT_HOST`

Default: `false`

If enabled, Xdebug will first try to connect to the client that made the HTTP request

`XDEBUG_IDE_KEY`

Default: `PHPSTORM`

`OPCACHE_ENABLED`

Default: `false`

`MONGODB_ENABLED`

Default: `false`

`REDIS_ENABLED`

Default: `false`

`MEMCACHED_ENABLED`

Default: `false`

`UID` and `GID`

Default: 33 and 33
Override the uid and/or gid for the www-data user and/or group
