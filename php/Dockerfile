# Name ctsmedia/baseimage-web-php
# Change version to create differen tags like for php5
# FROM php:5.6-fpm
FROM php:7.0-fpm

MAINTAINER ctsmedia <info@cts-media.eu>

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxml2-dev \
        zlib1g-dev libicu-dev g++ \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-install xml
RUN docker-php-ext-configure intl && docker-php-ext-install intl
RUN pecl install xdebug \
    && echo 'zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so' >> /usr/local/etc/php/php.ini
RUN docker-php-ext-install pdo_mysql



ADD config/php-cts.ini /usr/local/etc/php/conf.d/cts-default.ini
