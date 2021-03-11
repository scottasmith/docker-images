# Based on and tweaked from the official https://github.com/docker-library/php

FROM debian:buster-slim

LABEL maintainer="Scott Smith <smitherz82@gmail.com>"

# Sort out bash history ignorespace and ignoredups
ENV HISTCONTROL=ignoreboth

# prevent Debian's PHP packages from being installed
RUN set -eux; \
    { \
        echo 'Package: php*'; \
        echo 'Pin: release *'; \
        echo 'Pin-Priority: -1'; \
    } > /etc/apt/preferences.d/no-debian-php;

# dependencies required for running "phpize"
ENV PHPIZE_DEPS \
        autoconf \
        dpkg-dev \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkg-config \
        re2c

# persistent / runtime deps
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        xz-utils \
        libgmp10 \
        libssh2-1 \
        libmemcachedutil2 \
        libmcrypt4 \
        cron \
        libzip4 \
        supervisor \
        python \
        iputils-ping \
        gosu \
        libpng-dev \
        unzip \
    ; \
    rm -rf /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
    mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
    [ ! -d /var/www/public ]; \
    mkdir -p /var/www/public; \
    chown www-data:www-data /var/www/public; \
    chmod 777 /var/www/public; \
    rm -rf /var/www/html;

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends apache2; \
    rm -rf /var/lib/apt/lists/*; \
    \
# generically convert lines like
#   export APACHE_RUN_USER=www-data
# into
#   : ${APACHE_RUN_USER:=www-data}
#   export APACHE_RUN_USER
# so that they can be overridden at runtime ("-e APACHE_RUN_USER=...")
    sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' "$APACHE_ENVVARS"; \
    \
# setup directories and permissions
    . "$APACHE_ENVVARS"; \
    for dir in \
        "$APACHE_LOCK_DIR" \
        "$APACHE_RUN_DIR" \
        "$APACHE_LOG_DIR" \
    ; do \
        rm -rvf "$dir"; \
        mkdir -p "$dir"; \
        chown "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
        chmod 777 "$dir"; \
    done; \
    \
# delete the "index.html" that installing Apache drops in here
    rm -rvf /var/www/html/*; \
    \
# logs should go to stdout / stderr
    ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log"; \
    ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log"; \
    ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"; \
    chown -R --no-dereference "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$APACHE_LOG_DIR"

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

# Apache mudules we use
RUN a2enmod rewrite

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN { \
        echo '<FilesMatch \.php$>'; \
        echo '\tSetHandler application/x-httpd-php'; \
        echo '</FilesMatch>'; \
        echo; \
        echo 'DirectoryIndex disabled'; \
        echo 'DirectoryIndex index.php index.html'; \
        echo; \
        echo '<Directory /var/www/>'; \
        echo '\tOptions -Indexes'; \
        echo '\tAllowOverride All'; \
        echo '</Directory>'; \
    } | tee "$APACHE_CONFDIR/conf-available/docker-php.conf" \
    && a2enconf docker-php

ENV PHP_EXTRA_BUILD_DEPS apache2-dev
ENV PHP_EXTRA_CONFIGURE_ARGS --with-apxs2 --disable-cgi

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# Adds GNU HASH segments to generated executables (this is used if present, and is much faster than sysv hash; in this configuration, sysv hash is also generated)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV GPG_KEYS 1729F83938DA44E27BA0F4D3DBDB397470D12172 BFDDD28642824F8118EF77909B67A5C12229118F

ENV PHP_VERSION 8.0.0RC2
ENV PHP_URL="https://www.php.net/distributions/php-8.0.2.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-8.0.2.tar.xz.asc"
ENV PHP_SHA256="84dd6e36f48c3a71ff5dceba375c1f6b34b71d4fa9e06b720780127176468ccc" PHP_MD5=""

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends gnupg dirmngr; \
    rm -rf /var/lib/apt/lists/*; \
    \
    mkdir -p /usr/src; \
    cd /usr/src; \
    \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    \
    if [ -n "$PHP_SHA256" ]; then \
        echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
    fi; \
    if [ -n "$PHP_MD5" ]; then \
        echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
    fi; \
    \
    if [ -n "$PHP_ASC_URL" ]; then \
        curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
        export GNUPGHOME="$(mktemp -d)"; \
        echo "disable-ipv6" >> $GNUPGHOME/dirmngr.conf; \
        for key in $GPG_KEYS; do \
            gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
        done; \
        gpg --batch --verify php.tar.xz.asc php.tar.xz; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME"; \
    fi; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY docker-php-source docker-php-ext-* /usr/local/bin/

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        apache2-dev \
        libargon2-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libonig-dev \
        libsodium-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        zlib1g-dev \
        libicu-dev \
        libxml2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libgmp-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libssh2-1-dev \
        libxslt1-dev \
        libzip-dev \
        libldap2-dev \
        ${PHPIZE_DEPS:-} \
        ${PHP_EXTRA_BUILD_DEPS:-} \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    export \
        CFLAGS="$PHP_CFLAGS" \
        CPPFLAGS="$PHP_CPPFLAGS" \
        LDFLAGS="$PHP_LDFLAGS" \
    ; \
    \
    docker-php-source extract; \
    \
    cd /usr/src/php; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
# https://bugs.php.net/bug.php?id=74125
    if [ ! -d /usr/include/curl ]; then \
        ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
    fi; \
    ./configure \
        --build="$gnuArch" \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        \
# make sure invalid --configure-flags are fatal errors intead of just warnings
        --enable-option-checking=fatal \
        --with-mhash \
        --enable-ftp \
        --enable-mbstring \
        --enable-mysqlnd \
        --with-password-argon2 \
        --with-sodium=shared \
        --with-pdo-sqlite=/usr \
        --with-sqlite3=/usr \
        --with-curl \
        --with-pear \
        --with-libedit \
        --with-openssl \
        --with-zlib \
        --with-zip \
        --enable-intl \
        --enable-calendar \
        --enable-bcmath \
        --enable-pcntl \
        --with-zip \
        --enable-soap \
        --enable-fileinfo \
        --with-pdo-mysql \
        --with-xsl \
        --with-gmp \
        --with-iconv \
        --enable-gd \
        --with-ldap \
        --with-jpeg \
        --with-freetype \
        --enable-sockets \
        \
        $(test "$gnuArch" = 's390x-linux-gnu' && echo '--without-pcre-jit') \
        --with-libdir="lib/$debMultiarch" \
        --with-apxs2 \
        --disable-cgi \
    && \
    make -j "$(nproc)" && \
    find -type f -name '*.a' -delete && \
    make install && \
    find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true && \
    make clean && \
    \
    cp -v php.ini-* "$PHP_INI_DIR/" && \
    \
    pecl channel-update pecl.php.net && \
    pecl install xdebug-3.0.3 && \
    printf "\n" | pecl install --nodeps mcrypt-1.0.4 && \
    printf "\n" | pecl install redis-5.3.3 && \
    printf "\n" | pecl install memcached-3.1.5 && \
    printf "\n" | pecl install mongodb && \
    \
# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
    docker-php-ext-enable mcrypt sodium && \
    \
    cd / && \
    docker-php-source delete && \
    \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark && \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    \
    pecl update-channels && \
    \
    rm -rf /tmp/pear ~/.pearrc && \
# smoke test
    php --version

COPY docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

COPY apache2-foreground /usr/local/bin/
COPY custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY vhost.conf /etc/apache2/sites-available/000-default.conf

RUN echo 'export PHP_IDE_CONFIG=${PHP_IDE_CONFIG}' >> /etc/environment && \
    echo ". /etc/environment" >> /etc/apache2/envvars

# Update the www-data user so its home directory is not /var/www
RUN set -e; \
    usermod -d /home www-data; \
    chown -R www-data:www-data /home;

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

WORKDIR /var/www

EXPOSE 80
CMD ["apache2-foreground"]
