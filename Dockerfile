FROM phusion/baseimage:0.9.17
MAINTAINER ctsmedia <info@cts-media.eu>

################################################################################
# Config
################################################################################

ENV DOCKER_DOMAIN dev.ctsmedia.local
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

################################################################################
# Base
################################################################################

RUN rm -f /etc/service/sshd/down

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get install -y curl wget git zip postfix bsd-mailx

################################################################################
# CTS build instructions
################################################################################



### initialization
COPY scripts/bash_additions /tmp/bash_additions
RUN cat /tmp/bash_additions >> ~/.bashrc

### LAMP Setup
RUN apt-get -qqy install apache2

### phpbrew
RUN apt-get build-dep -y php5
RUN apt-get install -y php5 php5-cgi libapache2-mod-fcgid php5-dev php-pear autoconf automake curl build-essential libxslt1-dev re2c libxml2 libxml2-dev php5-cli bison libbz2-dev libreadline-dev
RUN apt-get install -y libfreetype6 libfreetype6-dev libpng12-0 libpng12-dev libjpeg-dev libjpeg8-dev libjpeg8  libgd-dev libgd3 libxpm4 libltdl7 libltdl-dev
RUN apt-get install -y libssl-dev openssl
RUN apt-get install -y gettext libgettextpo-dev libgettextpo0
RUN apt-get install -y libicu-dev
RUN apt-get install -y libmhash-dev libmhash2
RUN apt-get install -y libmcrypt-dev libmcrypt4
RUN apt-get install -y libmagickwand-dev libmagickcore-dev

RUN curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
RUN chmod +x phpbrew
RUN mv phpbrew /usr/bin/phpbrew
RUN phpbrew init
RUN echo "export PHPBREW_ROOT=/opt/phpbrew" >> ${HOME}/.phpbrew/init
RUN echo "source ${HOME}/.phpbrew/bashrc" >> ${HOME}/.bashrc

ADD scripts/install_php /usr/bin/install_php
ADD config/php-cgi.conf /var/www/php-cgi.conf
RUN chmod +x /var/www/php-cgi.conf
RUN chmod +x /usr/bin/install_php


## mysql
RUN apt-get install -y mysql-server mysql-client php5-mysql

### Setup Apache / webserver (non project specific)
RUN mkdir /var/www/share
RUN mkdir /var/www/share/phpmyadmin
COPY scripts/phpinfo.php /var/www/share/info.php
RUN mkdir /etc/apache2/certs

COPY config/vhost /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default.conf
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod fcgid

### custim php ini
ADD config/php-cts.ini /etc/php5/cgi/conf.d/cts-default.ini

### phpmyadmin
RUN wget -P /var/www/share/phpmyadmin https://github.com/phpmyadmin/phpmyadmin/archive/master.zip
RUN unzip /var/www/share/phpmyadmin/master.zip -d /var/www/share/phpmyadmin
RUN mv /var/www/share/phpmyadmin/phpmyadmin-master /var/www/share/phpmyadmin/htdocs
COPY config/phpmyadmin.config.php /var/www/share/phpmyadmin/htdocs/config.inc.php
RUN mkdir /var/www/share/phpmyadmin/data
RUN mkdir /var/www/share/phpmyadmin/data/mysql
RUN rm /var/www/share/phpmyadmin/master.zip

### composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

### phing
RUN wget http://www.phing.info/get/phing-latest.phar
RUN mv phing-latest.phar /usr/local/bin/phing
RUN chmod +x /usr/local/bin/phing



### Init Project Skeleton
RUN mkdir -p /etc/my_init.d
ADD scripts/prepare-project.sh /etc/my_init.d/00_prepare-project.sh
ADD scripts/init.sh /etc/my_init.d/01_init.sh

### Open Ports
EXPOSE 80 443

### Install Daemons

RUN mkdir /etc/service/mysql
ADD daemons/mysql.sh /etc/service/mysql/run

#RUN mkdir /etc/service/apache2
#ADD daemons/apache2.sh /etc/service/apache2/run

### Set WORKDIR
WORKDIR /var/www/share

################################################################################
# Clean up APT when done.
################################################################################
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
