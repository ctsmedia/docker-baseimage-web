# Name ctsmedia/baseimage-web-abstract
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
RUN apt-get install -qqy php-cli

## sqlite, other db services like maria db or mysql should be used via container
RUN apt-get install -qqy sqlite

### Setup webserver (non project specific)
RUN mkdir -p /var/www/share/project
RUN mkdir /var/www/share/phpmyadmin
COPY scripts/phpinfo.php /var/www/share/info.php

### phpmyadmin
RUN wget  -qP /var/www/share/phpmyadmin https://github.com/phpmyadmin/phpmyadmin/archive/STABLE.zip
RUN unzip -q /var/www/share/phpmyadmin/STABLE.zip -d /var/www/share/phpmyadmin
RUN mv /var/www/share/phpmyadmin/phpmyadmin-STABLE /var/www/share/phpmyadmin/htdocs
COPY config/phpmyadmin.config.php /var/www/share/phpmyadmin/htdocs/config.inc.php
RUN mkdir /var/www/share/phpmyadmin/data
RUN mkdir /var/www/share/phpmyadmin/data/mysql
RUN rm /var/www/share/phpmyadmin/STABLE.zip

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
