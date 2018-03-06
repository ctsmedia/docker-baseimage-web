#!/bin/sh
set -e

# inspired by https://github.com/helderco/docker-php/blob/master/versions/7.2/init.d/mapuid.sh

if [ -d "${PROJECT_PATH}" ] && [ "$PHP_FPM_USER_FIX" = "true" ]; then

    # We read out the ownership as www-data because of https://github.com/docker/for-mac/issues/2657
    uid=$(gosu www-data stat -c '%u' "$PROJECT_PATH")
    gid=$(gosu www-data stat -c '%g' "$PROJECT_PATH")
    www_data_uid=$(gosu www-data id -u)

    echo "Adjusting www-data user and group id if necessary"

    if [ "$www_data_uid" != "$uid" ]
        then
            echo "Changing www-data id to the one from docker host"
            usermod -u "$uid" www-data
            groupmod -g "$gid" www-data
        else
            echo "www-data has same uid like the host user. No need to change it."
    fi

fi