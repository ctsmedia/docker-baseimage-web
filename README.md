[![](https://img.shields.io/github/license/ctsmedia/docker-baseimage-web.svg?style=flat-square)](https://github.com/ctsmedia/docker-baseimage-web)

# CTS Docker Web images

Based on the official docker images we did build a setup for easy setting up a local development environment for your php based web projects.  

## What's inside

### PHP FPM

Based on the official php image we added some common things you need in projects based on symfony, magento or contao for example.  
Comes with some comfort stuff which is often used when works needs to be done inside the container and an optimized php ini for development.
The container adjusts the www-data user to match your host user id, so you want get permission problems. It reads the user and group id from your volume mount in the container which should be by default: `/var/www/share/project`. 
If you want to changed that pass the env var: `PROJECT_PATH`. Our docker compose examples work out of the box. 

- Pre installed and activated extensions: 
    - iconv
    - gd
    - xml
    - intl
    - redis
    - pdo_mysql
    - zip
    - mcrypt (sodium for php 7.2)
    - xdebug
    - exif

- Tools
    - Vi(m)
    - git
    - composer globally installed
    - globally installed symfony var dumper
    - gosu

In your docker compose file use: 
```
image: ctsmedia/php:7.2-fpm
```
instead of
```
image: php:7.2-fpm
```

### Apache 2.4

- SSL enabled 
- Zero config for connection to php fpm
- http2 enabled 

### Nginx Container

Coming soon    

### Compose Examples

See the [compose-examples](compose-examples) dir for some examples getting you started within minutes.
Variable compositions of php 7.0, 7.1, 5, apache, mysql or mariadb, phpmyadmin and more.

## How to enable xdebug

xdebug is not enabled by default due tue performance reasons expecially on mac. To enable it pass the following env variable:
`ENABLE_XDEBUG=true`

for example:

`docker run -it -e PHP_FPM_USER_FIX=false -e ENABLE_XDEBUG=true ctsmedia/php:7.2-fpm bash`

See example docker compose files accordingly.

## How to setup

1. Grab one of the example composes files and put it into you project root / repository
2. Rename it to `docker-compose.yml`
3. Adjust the compose file to your likings (documentation inside)
4. Run `docker-compose up -d`
5. Access the http container (in general http://localhost:80 on mac or on linux the container ip http://HTTP_CONTAINER_IP. You use `docker ps` or the program kitematic to find it. )

## How to Build custom PHP image

1. Adjust the Dockerfile to your likings
2. Build the image. Replace the tag and php version `docker build -t ctsmedia/php:7.2 --build-arg PHP_VERSION=7.2 .`


`:wq`
