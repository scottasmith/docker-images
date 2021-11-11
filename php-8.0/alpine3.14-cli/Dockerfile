# Based on and tweaked from the official https://github.com/docker-library/php

FROM alpine:3.14

LABEL maintainer="Scott Smith <smitherz82@gmail.com>"

# Sort out bash history ignorespace and ignoredups
ENV HISTCONTROL=ignoreboth

# dependencies required for running "phpize"
# these get automatically installed and removed by "docker-php-ext-*" (unless they're already installed)
ENV PHPIZE_DEPS \
        autoconf \
        dpkg-dev dpkg \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkgconf \
        re2c

# persistent / runtime deps
RUN set -eux; \
    apk add --no-cache \
        ca-certificates \
        curl \
        xz \
        tar \
        libmemcached \
        libzip \
        openssl \
        shadow

# ensure www-data user exists
RUN set -eux; \
	adduser -u 82 -D -S -G www-data -h /home www-data
# 82 is the standard uid/gid for "www-data" in Alpine
# https://git.alpinelinux.org/aports/tree/main/apache2/apache2.pre-install?h=3.14-stable
# https://git.alpinelinux.org/aports/tree/main/lighttpd/lighttpd.pre-install?h=3.14-stable
# https://git.alpinelinux.org/aports/tree/main/nginx/nginx.pre-install?h=3.14-stable

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
    mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
    [ ! -d /var/www/public ]; \
    mkdir -p /var/www/public; \
    chown www-data:www-data /var/www/public; \
    chmod 777 /var/www/public; \
    rm -rf /var/www/html;

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
ENV PHP_URL="https://www.php.net/distributions/php-8.0.12.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-8.0.12.tar.xz.asc"
ENV PHP_SHA256="a501017b3b0fd3023223ea25d98e87369b782f8a82310c4033d7ea6a989fea0a"

RUN set -eux; \
    \
    apk add --no-cache --virtual .fetch-deps gnupg; \
    \
    mkdir -p /usr/src; \
    cd /usr/src; \
    \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    \
    if [ -n "$PHP_SHA256" ]; then \
        echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
    fi; \
    \
    if [ -n "$PHP_ASC_URL" ]; then \
        curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
        export GNUPGHOME="$(mktemp -d)"; \
        for key in $GPG_KEYS; do \
            gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
        done; \
        gpg --batch --verify php.tar.xz.asc php.tar.xz; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME"; \
    fi; \
    \
    apk del --no-network .fetch-deps

COPY docker-php-source docker-php-ext-* /usr/local/bin/

RUN set -eux; \
    \
    apk add --no-cache --virtual .build-deps \
        ${PHPIZE_DEPS:-} \
        argon2-dev \
        coreutils \
        curl-dev \
        readline-dev \
        oniguruma-dev \
        libsodium-dev \
        sqlite-dev \
        openssl-dev \
        libxml2-dev \
        zlib-dev \
        icu-dev \
        libxml2-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libmemcached-dev \
        libxslt-dev \
        libzip-dev \
        libpng-dev \
    ; \
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
    ./configure \
        --build="$gnuArch" \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        \
# make sure invalid --configure-flags are fatal errors intead of just warnings
        --enable-option-checking=fatal \
        --with-mhash \
        --with-pic \
        --enable-ftp \
        --enable-mbstring \
        --enable-mysqlnd \
        --with-mysqli \
        --with-password-argon2 \
        --with-sodium=shared \
        --with-pdo-sqlite=/usr \
        --with-sqlite3=/usr \
        --with-curl \
        --with-pear \
        --with-readline \
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
        --with-iconv \
        --enable-gd \
        --with-jpeg \
        --with-freetype \
        --enable-sockets \
        \
        $(test "$gnuArch" = 's390x-linux-mus1' && echo '--without-pcre-jit') \
    && \
    make -j "$(nproc)" && \
    find -type f -name '*.a' -delete && \
    make install && \
    find \
        /usr/local \
        -type f \
        -perm '/0111' \
        -exec sh -euxc ' \
            strip --strip-all "$@" || : \
        ' --  '{}' + \
    ; \
    make clean && \
    \
    cp -v php.ini-* "$PHP_INI_DIR/" && \
    \
    pecl channel-update pecl.php.net && \
    pecl install xdebug-3.1.1 && \
    printf "\n" | pecl install redis-5.3.4 && \
    printf "\n" | pecl install memcached-3.1.5 && \
    printf "\n" | pecl install mongodb && \
	rm -rf /tmp/pear ~/.pearrc && \
    \
# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
    docker-php-ext-enable sodium && \
    \
    cd / && \
    docker-php-source delete && \
    \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache $runDeps; \
	\
	apk del --no-network .build-deps; \
    \
# smoke test
    php --version

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Update the www-data user so its home directory is not /var/www
RUN set -e; \
    usermod -d /home www-data; \
    chown -R www-data:www-data /home;

COPY docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /var/www

CMD ["php", "-a"]
