# Name ctsmedia/baseimage-web-abstract:1.1.0
FROM phusion/baseimage:0.9.19
MAINTAINER ctsmedia <info@cts-media.eu>

################################################################################
# Config
################################################################################

ENV DOCKER_DOMAIN dev.ctsmedia.local
ENV PHPFPM_HOST php7fpm
ENV DOCROOT htdocs

ENV HOME /root
ENV COMPOSER_HOME /var/www/composer
ENV DEBIAN_FRONTEND noninteractive

################################################################################
# Base
################################################################################

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get -qq update && apt-get install -qqy curl wget git zip postfix bsd-mailx

################################################################################
# CTS build instructions
################################################################################

### initialization
COPY scripts/bash_additions /tmp/bash_additions
RUN cat /tmp/bash_additions >> ~/.bashrc

### php7
### we install php cli for composer and xml because it's needed often in cli tasks
RUN apt-get install -qqy php-cli php-xml

## sqlite, other db services like maria db or mysql should be used via container
RUN apt-get install -qqy sqlite

## install a mysql-client
RUN apt-get install -qqy mysql-client

### Setup webserver (non project specific)
RUN mkdir -p /var/www/share/project
RUN mkdir /var/www/share/phpmyadmin
COPY scripts/phpinfo.php /var/www/share/info.php

### composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN mkdir -p /var/www/composer

#### Install the symfony dump file globally
RUN composer global require symfony/var-dumper

### Init Project Skeleton
RUN mkdir -p /etc/my_init.d
ADD scripts/init.sh /etc/my_init.d/01_init.sh

### Open Ports
EXPOSE 80 443

### Set WORKDIR
WORKDIR /var/www/share

################################################################################
# Clean up APT when done.
################################################################################
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
