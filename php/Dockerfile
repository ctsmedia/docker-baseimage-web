# Name ctsmedia/php
ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

MAINTAINER ctsmedia <info@cts-media.eu>

ENV COMPOSER_HOME /var/www/composer
ENV PROJECT_PATH /var/www/share/project
ENV PHP_FPM_USER_FIX "true"

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        zlib1g-dev libicu-dev g++ \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

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


# >= php 7.2 (mcrypt was replaced by sodium)
RUN set -e; \
    /bin/bash -c '\
    if [[ "${PHP_VERSION}" =~ "7." && ! ( "${PHP_VERSION}" =~ "7.1" || "${PHP_VERSION}" =~ "7.0" ) ]]; then  \
        echo "Installing php 7.2+ extensions"; \
        apt-get update && apt-get install -y \
            libsodium-dev \
        && docker-php-ext-install -j$(nproc) sodium \
        && pecl install xdebug; \
    fi;\
    '


RUN docker-php-ext-install xml
RUN docker-php-ext-configure intl && docker-php-ext-install intl
RUN pecl install redis-3.1.2 \
    && docker-php-ext-enable redis
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install zip

### tools
RUN apt-get -qq update && apt-get install -qqy \
        vim \
        wget \
        curl \
        git \
        zip
COPY config/bash_additions /tmp/bash_additions
RUN cat /tmp/bash_additions >> ~/.bashrc

#### gosu
ENV GOSU_VERSION 1.10
RUN set -x \
  && curl -sSLo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

### composer 1.6.3
RUN curl -sS https://getcomposer.org/download/1.6.3/composer.phar > composer.phar
RUN chmod +x composer.phar
RUN mv composer.phar /usr/local/bin/composer
RUN mkdir -p /var/www/composer
### composer may not get run as root, so the home needs to be writable for all
RUN chmod -R 777 /var/www/composer

### Install the symfony dump file globally
RUN composer global require symfony/var-dumper
### composer may not get run as root, so the home needs to be writable for all
RUN chmod -R 777 /var/www/composer

### Add prepared php ini
ADD config/php-cts.ini /usr/local/etc/php/conf.d/cts-default.ini

### Set Entrypoint
RUN mkdir -p $PROJECT_PATH \
    && chmod 777 $PROJECT_PATH
COPY info.php $PROJECT_PATH

WORKDIR $PROJECT_PATH

COPY ./init /docker-entrypoint-init.d/
COPY docker-php-entrypoint.sh /usr/local/bin/docker-php-entrypoint
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php-fpm"]
