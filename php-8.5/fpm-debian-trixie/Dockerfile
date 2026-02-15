ARG BASE_IMAGE=php:8.5.3-fpm-trixie

FROM $BASE_IMAGE

# persistent / runtime deps
RUN set -eux; \
    apt update && \
    apt install -y \
      nginx \
      nginx-extras \
      libnginx-mod-http-brotli-filter \
      supervisor \
      git \
      libreadline8 \
      libcurl4; \
    apt-mark auto '.*' > /dev/null; \
    rm -rf /var/lib/apt/lists/*;

# install extensions
RUN apt update && \
    apt install -y \
      build-essential \
      libicu-dev \
      libpq-dev \
      libcurl4-openssl-dev \
      libzip-dev \
      libxml2-dev \
      libxslt1-dev \
      libssl-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      libwebp-dev \
      libfreetype6-dev \
      libssl-dev \
    && \
    savedAptMark="$(apt-mark showmanual)" \
    && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-configure exif --enable-exif && \
    docker-php-ext-install -j$(nproc)  \
      gd \
      pdo \
      pdo_pgsql \
      pgsql \
      pdo_mysql \
      mysqli \
      curl \
      xml \
      pcntl \
      exif \
      soap \
      zip \
      intl \
      bcmath \
      ftp \
      sockets \
    \
    && \
    \
    apt remove --purge -y $savedAptMark && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-source delete

# install redis and xdebug
RUN set -eux; \
    pecl channel-update pecl.php.net && \
    # \
    # install pecl redis and enable \
    pecl install -o -f redis && \
    # \
    pecl install xdebug && \
    # \
    rm -rf /tmp/pear ~/.pearrc && \
    # \
    docker-php-ext-enable redis

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/bin --filename=composer && chmod +x /usr/bin/composer

COPY nginx.conf /etc/nginx/nginx.conf
COPY default-site.conf /etc/nginx/sites-available/default

COPY fpm-www.conf /usr/local/etc/php-fpm.d/www.conf
COPY fpm-docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY php.ini "$PHP_INI_DIR/php.ini"
RUN rm /usr/local/etc/php-fpm.d/www.conf.default
RUN rm /usr/local/etc/php-fpm.d/zz-docker.conf

COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN mkdir -p /var/www/app
RUN mkdir /var/run/php/
RUN chown www-data:www-data /var/run/php

# Temp storage for fastcgi buffer files
RUN mkdir -p /tmp/nginx/client_body \
    /tmp/nginx/fastcgi \
    && chown -R www-data:www-data /tmp/nginx

COPY docker-php-helpers /usr/local/bin/

EXPOSE 80
