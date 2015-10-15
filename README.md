[![](https://badge.imagelayers.io/ctsmedia/baseimage-web:latest.svg)](https://imagelayers.io/?images=ctsmedia/baseimage-web:latest 'Get your own badge on imagelayers.io')
[![](https://img.shields.io/docker/pulls/ctsmedia/baseimage-web.svg?style=flat-square)](https://hub.docker.com/r/ctsmedia/baseimage-web/)
[![](https://img.shields.io/docker/stars/ctsmedia/baseimage-web.svg?style=flat-square)](https://hub.docker.com/r/ctsmedia/baseimage-web/)
[![](https://img.shields.io/github/license/ctsmedia/docker-baseimage-web.svg?style=flat-square)](https://github.com/ctsmedia/docker-baseimage-web)

# CTS Base Docker Image

Configurable Base image for web projects. Some highlights are:
 - LAMP Stack (PHP 5.5 by default, other versions via phpbrew)
 - SSH & SFTP Access
 - Projekt Blueprint
 - Composer
 - Phing
 - phpMyAdmin
 - crons
 - Mail (postfix)

This image is for imitating the usual web server your pages and apps run on.
It preconfigures a vhost and project sceleton for you with a local domain.
You can then just deploy your files via SFTP like on your rented web server.
Perfect for local development and feature branch based environments

To spice it up the image comes with some features for auto deployment and continues integration

**Do not use for production environments or environments with security playing a role**
Things like phpmyadmin, mysql etc are not password protected and just setup to get rolling quickly. For environments running on your local development machine this is fine.

**Why using this image?**
Why not :) We are using docker for some month now at www.cts-media.eu and  did build our own reusable base image.
This took a lot of hours (=> days) to setup and was only be able to do with the help of many blogs about docker, linux and so on.
So no reason to keep this private. Maybe it can save you some time or give you some ideas for your own base image.

Thanks to the [phusion guys](http://phusion.github.io/baseimage-docker/) for providing the ubuntu base image.

**Docker Pullname:** `ctsmedia/baseimage-web`  
**Find on Docker:** <https://hub.docker.com/r/ctsmedia/baseimage-web/>


## Create the base image

This base image is not an abstract one but does nothing (because it's an baseimage). To run it simply do:
`docker pull ctsmedia/baseimage-web`  
`docker run -d ctsmedia/baseimage-web`  
To get some info on what it's doing, start it not detached  
`docker run -d ctsmedia/baseimage-web`  

When running the container without the -d option or when connecting via ssh
your always get a message showing the ip and hostname which you can put into local hosts file
to be able to connect to your container via url.

Example output when running the container:
```
---------------------------------------------------
| 172.17.0.1 dev.ctsmedia.local                   |
---------------------------------------------------
```
You can browse your container now with the IP http://172.17.0.1

Run this command on your linux shell to make the container accessible via dev.ctsmedia.local
`sudo echo "172.17.0.1 dev.ctsmedia.local" >> /etc/hosts`

### phpmyadmin
You can access the phpmyadmin installation always via `phpmyadmin` f.e. http://172.17.0.1/phpmyadmin


## Modify the base image
`git clone git@github.com:ctsmedia/docker-baseimage-web.git`  
Modify the Dockerfile or its scripts and then build your own base image  
`docker build -t yourcompany/yourimage .`


## Create a web project using the base image

Creating develop enviroments fast. That's what this image is about

Go to your project directory which you want to add a preconfigured docker image
and then create the dockerfile `Dockerfile`

The simplest one would like:
```
FROM ctsmedia/baseimage-web

ENV DOCKER_DOMAIN urlsafe_projectname.local
```

Then run  
`docker build -t yourcompany/urlsafe_projectname:VERSION .`  
`VERSION` is optional. If not set *latest* will be used.

You can now run your container with `docker run yourcompany/urlsafe_projectname` and connect to it via ssh and sftp.
Deploy the files to the  document root found in: `/var/www/share/urlsafe_projectname.local/htdocs`


#### Additional Functionality

Put a project init script in your project dockerfile to get you automatically startet.  
Git, composer and phing come pre installed. So you easy setup a init script:

`scripts/init-env.sh`
```
#!/bin/bash
echo "Running init script for setting up feature docker environment"
cd /var/www/share/${DOCKER_DOMAIN}/repos
echo "Getting repos via ssh"
git clone git@gitlab.com:foo/bar.git
echo "Switching to develop branch"
cd bar
git checkout develop
echo "Running Deployment Script via phing"
phing docker-env-init
```

Use
```
ADD scripts/init-env.sh /etc/my_init.d/99_init-env.sh
```
to make it the init script run on container setup automatically (docker run )  
or use
```
ADD scripts/init-env.sh /var/www/share/99_init-env.sh
```
to manually run the script when logged in via ssh with `sh /var/www/share/99_init-env.sh`

*NOTE:*
You can use variable defined in your dockerfile in the container itself like `${DOCKER_DOMAIN}`

### Install another php version

We've build a installer script which make it easy to preinstall another php versin and use it (via phpbrew)
```
FROM ctsmedia/baseimage-web
ENV DOCKER_DOMAIN test.local

RUN install_php 5.4
```

### Custom php ini settings

You can add several custom ini files which are also used when switching to another php version (via install_php)
```
FROM ctsmedia/baseimage-web
ENV DOCKER_DOMAIN test.local

RUN install_php 5.4
ADD config/php-additional.ini /etc/php5/cgi/conf.d/cts-project.ini
ADD config/php-additional-2.ini /etc/php5/cgi/conf.d/cts-project-more.ini
```

*Note:*
Format of the name needs to be something like `cts-[.*].ini` und should not be `cts-default.ini` (only if you want to override out custom ini)
The file `config/php-additional.ini` must be accessible under this path when building you docker file

### Example of a fictionary Magento Store
```
FROM ctsmedia/base:latest
ENV DOCKER_DOMAIN acme-store.local

RUN install_php 5.4

ADD config/php-acmestore.ini /etc/php5/cgi/conf.d/cts-acmestore.ini
ADD scripts/init-env.sh /var/www/share/init-env.sh
```

The additional ini could like:
`config/php-acmestore.ini`
```
memory_limit = 512M
post_max_size = 200M
```

### SSH access
This image is based on the [phusion/baseimage](https://github.com/phusion/baseimage-docker)
Here you can read how to access your container: https://github.com/phusion/baseimage-docker#login_ssh
*SSH Access is by default enabled in this image compared to  [phusion/baseimage](https://github.com/phusion/baseimage-docker)*

### Use your own ssh keys instead of
We recommend to use your own key(s). Add this to you project dockerfile
```
### Add ssh keys
COPY config/authorized_keys /tmp/authorized_keys
RUN cat /tmp/authorized_keys >> /root/.ssh/authorized_keys && rm -f /tmp/authorized_keys
```
*Note*
Make sure `config/authorized_keys` is accessible and contains your ssh key(s)

### Mount project folder
You can also mount you project folder into the container via `-v PATH/TO/PRJECT` in your docker run command.

*We recomennt to use ssh for deploy / ci because the docker container should be a replica of your production server which you usually access via sftp oder build tools (using ssh)*

### Add Container SSH Key for deployment tools and ssh access (git)
Probably you're running a git repository for your project and maybe use CI Tools aswell. If so it's good to have a fixed SSH Keypair so your docker container can access your private git repositories
at gitlab or github with only one deploy key.
Otherwise you'd to have enable lots of keys namely for each time you or your team does a `docker run`

```
COPY config/id_rsa /root/.ssh/id_rsa
ADD config/id_rsa.pub /root/.ssh/id_rsa.pub
```

Create one using this command: `ssh-keygen -t rsa -C "docker@yourcompany.local"`

### Composer
When using composer in your projects you most likely already stumbled over the github API Rate limit.
You can get around it already in your dockerfile, by providing the token beforehand.
So you do not have to get one everytime you run your project in a new fresh dockerinstance
```
RUN composer config -g github-oauth.github.com TOKEN
```

### Mailing
This image comes with postfix installed. On development environments you often work with data from a production systems.
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

###  tl;dr Full Example
So if you made down here you maybe want to have a full example of how to use this image for your company and your projects
As already mentioned we at ctsmedia are running a company base image which inherits that one here.
Our Dockerfile for the company images looks like this:
```
FROM ctsmedia/baseimage-web:latest
MAINTAINER ctsmedia <info@cts-media.eu>

################################################################################
# CTS Config
################################################################################

### Add employee ssh keys
COPY config/authorized_keys /tmp/authorized_keys
RUN cat /tmp/authorized_keys >> /root/.ssh/authorized_keys && rm -f /tmp/authorized_keys

### Add fixed ssh key to docker machine for our deployment tools
COPY config/id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
ADD config/id_rsa.pub /root/.ssh/id_rsa.pub

# No strict host key check for our own repostiories
RUN touch /root/.ssh/config
RUN printf "Host gitlab.cts-media.eu\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

### composer api rate limit token
RUN composer config -g github-oauth.github.com <tokenreplacedwithplaceholder>

### postfix: default block all recipient_domains but only allow for whitelisted
RUN echo "smtpd_recipient_restrictions = check_recipient_access hash:/etc/postfix/recipient_domains, reject" >> /etc/postfix/main.cf
RUN echo "transport_maps = hash:/etc/postfix/transport"  >> /etc/postfix/main.cf
ADD config/postfix_recipient_domains /etc/postfix/recipient_domains
ADD config/postfix_transport /etc/postfix/transport
RUN postmap /etc/postfix/recipient_domains
RUN postmap /etc/postfix/transport
```

Our projects Dockerfile than inherit the company one and look like this:
```
FROM ctsmedia/baseimage-web-intern:1.0.0
ENV DOCKER_DOMAIN magentoshop.local

# Maxcluster Server run max. 5.4 atm
RUN install_php 5.4

ADD .docker-init-env.sh /etc/my_init.d/99_init-env.sh
RUN chmod +x /etc/my_init.d/99_init-env.sh
```

The init script itself looks quite the same in most of our projects `.docker-init-env.sh`:
```
#!/bin/bash
echo "Running init script for setting up feature docker environment"
cd /var/www/share/${DOCKER_DOMAIN}/repos
echo "Getting repos via ssh"
git clone git@privatereposserver:groupname/magentostore.git
echo "Switching to develop branch"
cd magentostore
git checkout develop
echo "Running Deployment Script via phing"
phing docker-env-init
```

The phing build will then build and deploy the application.

`:wq`
