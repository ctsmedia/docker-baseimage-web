# Name ctsmedia/baseimage-web-php
# Change version to create differen tags like for php5
#FROM php:5.6-fpm
#FROM php:7.0-fpm
FROM php:7.1-fpm

MAINTAINER ctsmedia <info@cts-media.eu>

ENV COMPOSER_HOME /var/www/composer

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

### composer 1.4.1
RUN apt-get -qq update && apt-get install -qqy curl wget zip
RUN curl -sS https://getcomposer.org/download/1.4.1/composer.phar > composer.phar
RUN chmod +x composer.phar
RUN mv composer.phar /usr/local/bin/composer
RUN mkdir -p /var/www/composer
# composer may not get run as root, so the home needs to be writable for all
RUN chmod +rw /var/www/composer

#### Install the symfony dump file globally
RUN composer global require symfony/var-dumper



ADD config/php-cts.ini /usr/local/etc/php/conf.d/cts-default.ini
