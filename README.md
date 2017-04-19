[![](https://img.shields.io/github/license/ctsmedia/docker-baseimage-web.svg?style=flat-square)](https://github.com/ctsmedia/docker-baseimage-web)

# CTS Base Docker Image

Configurable base Docker Setup for web projects.

## What's inside

### A abstract image you can build on

Based on the great [phusion/baseimage](http://phusion.github.io/baseimage-docker/) with some useful additions for
your daily web work

 - Composer
 - php CLI
 - mysql-client
 - crons
 - Mail (postfix)

### Apache Container

An apache container ready to run your project via php fpm

### Nginx Container

Coming soon

### php Container
We offer a php fpm container with some of required php extensions in projects for contao, drupal, symfony and magento and also for debugging with xdebug. Use:
```
image: ctsmedia/baseimage-web-php:7.0-fpm
```
instead of
```
image: php:7.0-fpm
```
in the php section of you docker-compose file.

It also provides composer and symfony var dumper component globally pre installed 


### Compose Examples

See the [compose-examples](compose-examples) dir for some examples getting you started within minutes.
Variable compositions of php 7.0, 7.1, 5, apache, mysql or mariadb, phpmyadmin and more.

**Find on Docker:**
- <https://hub.docker.com/r/ctsmedia/baseimage-web-abstract/>
- <https://hub.docker.com/r/ctsmedia/baseimage-web-apache/>


## How to setup

1. Grab one of the example composes files and put it into you project root / repository
2. Rename it to `docker-compose.yml`
3. Adjust the compose file to your likings (documentation inside)
4. Run `docker-compose up -d`
5. Access the container ip (gets shown in Kitematic output log of web container)
or set an entry in your hosts file with the configured DOCKER_DOMAIN mapping to the Container IP

## Mailing
This image comes with postfix installed. On development environments you sometimes work with data from a production systems.
It's not so cool if customers of an eshop get mails from your docker dev instance by accident.

To only allow mails send to specific whitelisted domains add the following to your docker instance:

```
### postfix
RUN echo "smtpd_recipient_restrictions = check_recipient_access hash:/etc/postfix/recipient_domains, reject" >> /etc/postfix/main.cf
RUN echo "transport_maps = hash:/etc/postfix/transport"  >> /etc/postfix/main.cf
ADD config/postfix_recipient_domains /etc/postfix/recipient_domains
ADD config/postfix_transport /etc/postfix/transport
RUN postmap /etc/postfix/recipient_domains
RUN postmap /etc/postfix/transport
```

The config files have to look like this:

`config/postfix_transport`
```
cts-media.eu :
cts-media.com :
* error: Recipient not whitelisted.
```

`config/postfix_recipient_domains`
```
cts-media.com OK
cts-media.eu OK
```

## FAQ

### I cannot access my containers IP via ping or Browser
Your most likely on Windows. You need to add a route for the created compose network.
```
route add  172.17.0.0 MASK 255.255.0.0 10.0.75.2
```
The **17** depends on the created network. Take the part from the container ip. If the container ip is `172.22.0.4` for example use
```
route add  172.22.0.0 MASK 255.255.0.0 10.0.75.2
```


`:wq`
