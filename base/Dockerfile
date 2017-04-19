# Name ctsmedia/baseimage-web-abstract:2.0.0
FROM phusion/baseimage:0.9.21
MAINTAINER ctsmedia <info@cts-media.eu>

################################################################################
# Config
################################################################################

ENV DOCKER_DOMAIN dev.ctsmedia.local
ENV PHPFPM_HOST php7fpm
ENV DOCROOT htdocs

ENV HOME /root
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

## sqlite, other db services like maria db or mysql should be used via container
RUN apt-get install -qqy sqlite

## install a mysql-client
RUN apt-get install -qqy mysql-client

### Setup webserver (non project specific)
COPY scripts/phpinfo.php /var/www/share/info.php

### Init Project Skeleton
RUN mkdir -p /etc/my_init.d
ADD scripts/init.sh /etc/my_init.d/01_init.sh
RUN chmod +x /etc/my_init.d/01_init.sh

# composer fallback
COPY scripts/composer.sh /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

### Open Ports
EXPOSE 80 443

### Set WORKDIR
WORKDIR /var/www/share

################################################################################
# Clean up APT when done.
################################################################################
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
