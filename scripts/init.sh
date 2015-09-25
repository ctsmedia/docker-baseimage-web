#!/bin/sh
printf "\n"
printf "###################################################################\n"
printf "# Container and Init Info\n"
printf "###################################################################\n"
ipaddress=$(hostname -i)
printf "[info] Container IP Address: $ipaddress \n"
printf "[info] Use for your hosts file the domain: $DOCKER_DOMAIN \n"
echo    "---------------------------------------------------"
printf  "| $ipaddress $DOCKER_DOMAIN                       | \n"
echo    "---------------------------------------------------"
printf "\n"
printf    "Adding Domain to etc hosts\n"
lcHostEntry=$(grep -c $DOCKER_DOMAIN /etc/hosts)
printf "Test if Entry was already added. Counts: $lcHostEntry \n"

if [ 0 -eq  $lcHostEntry ]
then
        printf "Entry not Found. Appending to /etc/hosts \n"
        echo "$ipaddress $DOCKER_DOMAIN" >> /etc/hosts
else
        printf "Entry already set. nothing to do\n"
fi
printf "All done\n"

printf    "Starting Apache\n"
service apache2 start
printf    "Starting Postfix (Mail)\n"
service postfix start
#service mysql start

printf "\n\n"
