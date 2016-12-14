# Name ctsmedia/baseimage-web-apache:1.1.1
FROM ctsmedia/baseimage-web-abstract:1.1.1
MAINTAINER ctsmedia <info@cts-media.eu>

### LAMP Setup
RUN apt-get -qq update && apt-get -qqy install apache2

### Setup Apache (non project specific)
RUN mkdir /etc/apache2/certs

COPY config/vhost /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default.conf
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod proxy_fcgi
RUN a2enmod headers

### Init Project Skeleton
ADD scripts/prepare-project.sh /etc/my_init.d/00_prepare-project.sh
RUN chmod +x /etc/my_init.d/00_prepare-project.sh
### Init Container
ADD scripts/init.sh /etc/my_init.d/02_init.sh
RUN chmod +x /etc/my_init.d/02_init.sh
