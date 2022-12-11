ARG BASE_IMAGE=8.2-fpm-alpine3.16

FROM $BASE_IMAGE

RUN set -eux; \
    \
    # permanent packages
    apk add --no-cache \
        libcurl \
        libzip \
        libpng \
        libwebp \
        libjpeg \
        freetype \
        icu \
        libpq \
        nginx \
        supervisor \
        shadow \
    && \
    \
    # temporary packages
    \
    apk add --no-cache --virtual .build-deps \
        argon2-dev \
        libpq-dev \
        curl-dev \
        libzip-dev \
        libxml2-dev \
        libxslt-dev \
        openssl-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        freetype-dev \
        icu-dev \
    && \
    \
    # install PHP Extensions
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    \
    docker-php-ext-install -j $(nproc) \
        gd \
        pdo \
        pdo_pgsql \
        pgsql \
        pdo_mysql \
        mysqli \
        curl \
        xml \
        pcntl \
        opcache \
        exif \
        soap \
        zip \
        intl \
    && \
    \
    # we don't want opcache on all the time in case we use xdebug
    # this version of docker-php-ext-install enables it by default
    rm /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    \
    docker-php-ext-configure exif --enable-exif && \
    \
    # update pecl
    pecl channel-update pecl.php.net && \
    \
    # install pecl redis and enable
    pecl install -o -f redis && docker-php-ext-enable redis && \
    # install pecl xdebug
    pecl install xdebug && \
    # cleanup
    rm -rf /tmp/pear ~/.pearrc && \
    \
    # cleanup apk
    \
    apk del --no-network .build-deps && \
    ln -s /var/cache/apk /etc/apk/cache && \
    \
    docker-php-source delete

COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY php.ini "$PHP_INI_DIR/php.ini"
COPY nginx.conf /etc/nginx/nginx.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf.default

COPY docker-php-helpers /usr/local/bin/
