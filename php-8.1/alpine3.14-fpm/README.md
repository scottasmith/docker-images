# PHP 8.0.*
The PHP image(s) are a custom version of the official PHP images [here](https://github.com/docker-library/php)

This image is the PHP 8.0 based on Alpine 3.13

- **scottsmith/php:8.0-alpine3.14-fpm**

This image allows to bind the the `/var/www` directory

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

Default: 82 and 82
Override the uid and/or gid for the www-data user and/or group
