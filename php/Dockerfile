# Name ctsmedia/php
ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

MAINTAINER e3n <info@e3n.de>

ENV COMPOSER_HOME /var/www/composer
ENV PROJECT_PATH /var/www/share/project
ENV PHP_FPM_USER_FIX "true"
ENV EDITOR 'vi'

# install libs and tools
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        zlib1g-dev libicu-dev g++ \
        ghostscript libmagickwand-dev \
        wget \
        curl \
        vim \
        git \
        zip \
        wait-for-it \
    && pecl install imagick \
    && docker-php-ext-install -j$(nproc) iconv \
#    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable imagick

# Imagick not supported yet in php8 see: https://github.com/Imagick/imagick/issues/358

# Pre php 7 (xdebug > 2.6 requires php 7)
RUN set -e; \
    /bin/bash -c '\
    if [[ "${PHP_VERSION}" =~ "5." ]]; then \
        echo "Installing specific php 5 extensions"; \
        apt-get update && apt-get install -y \
            libmcrypt-dev \
        && docker-php-ext-install -j$(nproc) mcrypt \
        && pecl install xdebug-2.5.0 \
        && docker-php-ext-enable xdebug; \
    fi;\
    '
# Pre php 7.2
RUN set -e; \
    /bin/bash -c '\
    if [[ "${PHP_VERSION}" =~ "7.0" || "${PHP_VERSION}" =~ "7.1" ]]; then  \
        echo "Installing php 7.0 and 7.1 extensions"; \
        apt-get update && apt-get install -y \
            libmcrypt-dev \
        && docker-php-ext-install -j$(nproc) mcrypt \
        && pecl install xdebug \
        && docker-php-ext-enable xdebug; \
    fi;\
    '


# >= php 7.2 && != 7.4 (mcrypt was replaced by sodium)
RUN set -e; \
    /bin/bash -c '\
    if [[ "${PHP_VERSION}" =~ "7." && ! ( "${PHP_VERSION}" =~ "7.1" || "${PHP_VERSION}" =~ "7.0" || "${PHP_VERSION}" =~ "7.4" ) ]]; then  \
        echo "Installing php 7.2+ extensions"; \
        apt-get update && apt-get install -y \
            libsodium-dev \
        && docker-php-ext-install -j$(nproc) sodium \
        && pecl install xdebug; \
    fi;\
    '

# >= php 7.3 (libzip must be installed separately)
RUN set -e; \
    /bin/bash -c '\
    if [[ "${PHP_VERSION}" =~ "7." && ! ( "${PHP_VERSION}" =~ "7.2" || "${PHP_VERSION}" =~ "7.1" || "${PHP_VERSION}" =~ "7.0" ) ]]; then  \
        echo "Installing php 7.3+ extensions"; \
        apt-get update && apt-get install -y \
            libzip-dev \
        && pecl install xdebug; \
    fi;\
    '

# >= php 8.0 (libzip must be installed separately)
RUN set -e; \
    /bin/bash -c '\
    if [[ "${PHP_VERSION}" =~ "8." ]]; then  \
        echo "Installing php 8.X extensions"; \
        apt-get update && apt-get install -y \
            libzip-dev \
        && pecl install xdebug; \
    fi;\
    '

RUN docker-php-ext-install xml
RUN docker-php-ext-configure intl && docker-php-ext-install intl
#RUN pecl install redis-3.1.2 \
RUN pecl install redis \
    && docker-php-ext-enable redis
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install zip
RUN docker-php-ext-install exif
RUN docker-php-ext-install soap

COPY config/bash_additions /tmp/bash_additions
RUN cat /tmp/bash_additions >> ~/.bashrc

#### gosu
ENV GOSU_VERSION 1.10
RUN set -x \
  && curl -sSLo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

### composer 2.3.5
RUN curl -sS https://getcomposer.org/download/2.3.5/composer.phar > composer.phar
RUN chmod +x composer.phar

RUN mv composer.phar /usr/local/bin/composer
RUN mkdir -p /var/www/composer
### composer may not get run as root, so the home needs to be writable for all
RUN chmod -R 777 /var/www/composer

### Install the symfony dump file globally
RUN composer global require symfony/var-dumper
### composer may not get run as root, so the home needs to be writable for all
RUN chmod -R 777 /var/www/composer

### Add prepared php ini and php fpm config
COPY config/php-cts.ini /usr/local/etc/php/conf.d/cts-default.ini
COPY config/e3n-fpm.conf /usr/local/etc/php-fpm.d/zzz-e3n-fpm.conf

### Fix Imagick
RUN sed -i "s/rights\=\"none\" pattern\=\"PDF\"/rights\=\"read\|write\" pattern\=\"PDF\"/" /etc/ImageMagick-6/policy.xml

### Set Entrypoint
RUN mkdir -p $PROJECT_PATH \
    && chmod 777 $PROJECT_PATH
COPY info.php $PROJECT_PATH

WORKDIR $PROJECT_PATH

COPY ./init /docker-entrypoint-init.d/
COPY docker-php-entrypoint.sh /usr/local/bin/docker-php-entrypoint

# Force xdebug enabled
RUN docker-php-ext-enable xdebug

ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php-fpm", "-R"]
