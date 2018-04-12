# Name ctsmedia/apache:1.0.0
FROM httpd:2.4
MAINTAINER ctsmedia <info@cts-media.eu>

### setup apache
COPY config/httpd-php.conf /usr/local/apache2/conf/httpd-php.conf
COPY config/httpd-php-ssl.conf /usr/local/apache2/conf/extra/httpd-php-ssl.conf
RUN chown root:www-data /usr/local/apache2/conf/httpd-php.conf
RUN echo "Include conf/httpd-php.conf" >> /usr/local/apache2/conf/httpd.conf
COPY scripts/httpd-foreground /usr/local/bin/

ENV PHPFPM_HOST="php"
ENV PHPFPM_PATH="/var/www/share/project"
ENV PHPFPM_PUBLIC_FOLDER=""

### Create ssl cert
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	    openssl

RUN openssl req -x509 -sha256 -days 1240 -nodes -newkey rsa:2048 \
    -keyout /usr/local/apache2/conf/server.key \
    -out /usr/local/apache2/conf/server.crt \
    -subj "/C=DE/ST=NRW/L=COLOGNE/O=CTS/OU=IT/CN=localhost"

### Open Ports
EXPOSE 80 443

### Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*